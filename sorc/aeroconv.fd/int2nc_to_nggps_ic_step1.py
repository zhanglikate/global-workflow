#!/usr/bin/env python

import numpy
import os
from PyNIO import Nio
import sys


INFILE = 'INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc'
OUTFILE = 'INTERMEDIATE/QNWFA_QNIFA_SIGMA_MONTHLY.step1.out.nc'

MONTHS = [ 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC' ]

f = Nio.open_file(INFILE)

nmon = 12
nlev = 30
nlat = int(f.variables['QNWFA_JAN__01'].ny)
nlon = int(f.variables['QNWFA_JAN__01'].nx)

slat = float(f.variables['QNWFA_JAN__01'].startlat)
slon = float(f.variables['QNWFA_JAN__01'].startlon)
dlat = float(f.variables['QNWFA_JAN__01'].deltalat)
dlon = float(f.variables['QNWFA_JAN__01'].deltalon)

print "Converting raw output of int2nc on Thompson aerosol climatology WPS files to netCDF CF-compliant format: {infile} -> {outfile}".format(
    infile=INFILE, outfile=OUTFILE)

if os.path.isfile(OUTFILE):
    os.remove(OUTFILE)

g = Nio.open_file(OUTFILE, mode='c')
g.create_dimension('month', nmon)
g.create_dimension('plev',  nlev)
g.create_dimension('lat',   nlat)
g.create_dimension('lon',   nlon)

g.create_variable('month', 'i', ('month',)                     )
setattr(g.variables['month'], 'standard_name', 'month'         )
setattr(g.variables['month'], 'long_name',     'month of year' )
setattr(g.variables['month'], 'units',         ''              )
setattr(g.variables['month'], 'axis',          'T'             )

g.create_variable('prs',   'f', ('month', 'plev', 'lat', 'lon'))
setattr(g.variables['prs'],   'standard_name', 'air_pressure'  )
setattr(g.variables['prs'],   'long_name',     'air pressure'  )
setattr(g.variables['prs'],   'units',         'Pa'            )
setattr(g.variables['prs'],   'axis',          'Z'             )
setattr(g.variables['prs'],   'positive',      'down'          )

g.create_variable('lat',   'f', ('lat',))
setattr(g.variables['lat'],   'standard_name', 'latitude'      )
setattr(g.variables['lat'],   'long_name',     'latitude'      )
setattr(g.variables['lat'],   'units',         'degrees_north' )
setattr(g.variables['lat'],   'axis',          'Y'             )

g.create_variable('lon',   'f', ('lon',))
setattr(g.variables['lon'],   'standard_name', 'longitude'     )
setattr(g.variables['lon'],   'long_name',     'longitude'     )
setattr(g.variables['lon'],   'units',         'degrees_east'  )
setattr(g.variables['lon'],   'axis',          'X'             )

g.create_variable('nwfa',  'f', ('month', 'plev', 'lat', 'lon')                                  )
setattr(g.variables['nwfa'],  'standard_name', 'number_concentration_of_water_friendly_aerosols' )
setattr(g.variables['nwfa'],  'long_name',     'number concentration of water friendly aerosols' )
setattr(g.variables['nwfa'],  'units',         'kg-1'                                            )

g.create_variable('nifa',  'f', ('month', 'plev', 'lat', 'lon')                                  )
setattr(g.variables['nifa'],  'standard_name', 'number_concentration_of_ice_friendly_aerosols'   )
setattr(g.variables['nifa'],  'long_name',     'number concentration of ice friendly aerosols'   )
setattr(g.variables['nifa'],  'units',         'kg-1'                                            )

mon = numpy.zeros((nmon,), dtype=numpy.int32)
lat = numpy.zeros((nlat,), dtype=numpy.float32)
lon = numpy.zeros((nlon,), dtype=numpy.float32)

for i in xrange(nmon):
    mon[i] = i+1
g.variables['month'][:] = mon

for i in xrange(nlat):
    lat[i] = slat + i*dlat
g.variables['lat'][:] = lat

for i in xrange(nlon):
    lon[i] = slon + i*dlon
g.variables['lon'][:] = lon

prs  = numpy.zeros((nmon, nlev, nlat, nlon), dtype=numpy.float32)
nwfa = numpy.zeros((nmon, nlev, nlat, nlon), dtype=numpy.float32)
nifa = numpy.zeros((nmon, nlev, nlat, nlon), dtype=numpy.float32)

for i in xrange(nmon):
    month = MONTHS[i]
    for k in xrange(nlev):
        # Flip vertical direction
        j = nlev-k-1
        lev = k+1
        prs_var_name  = 'P_WIF_{month}__0{lev}'.format(month=month, lev=lev)
        nwfa_var_name = 'QNWFA_{month}__0{lev}'.format(month=month, lev=lev)
        nifa_var_name = 'QNIFA_{month}__0{lev}'.format(month=month, lev=lev)
        prs[i,j]  = numpy.copy(f.variables[prs_var_name][:,:])
        nwfa[i,j] = numpy.copy(f.variables[nwfa_var_name][:,:])
        nifa[i,j] = numpy.copy(f.variables[nifa_var_name][:,:])

g.variables['prs'][:]  = prs
g.variables['nwfa'][:] = nwfa
g.variables['nifa'][:] = nifa

f.close()
g.close()
