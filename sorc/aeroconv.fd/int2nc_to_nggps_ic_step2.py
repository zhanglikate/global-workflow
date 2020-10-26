#!/usr/bin/env python

import calendar
import datetime
import numpy
import os
from PyNIO import Nio
import sys

if len(sys.argv)<2:
    raise Exception("Provide interpolation date for Thompson aerosol climatology in format YYYYmmdd")
intdate = datetime.datetime.strptime(sys.argv[1], "%Y%m%d")

INFILE = 'INTERMEDIATE/QNWFA_QNIFA_SIGMA_MONTHLY.step1.out.nc'
OUTFILE = 'INTERMEDIATE/QNWFA_QNIFA_SIGMA_DATEINT.step2.out.nc'

def add_months(date, months):
    year = date.year
    month = date.month + months + 1
    dyear, month = divmod(month - 1, 12)
    rdate = datetime.datetime(year + dyear, month + 1, 1, date.hour) - datetime.timedelta(1)
    return rdate.replace(day = min(rdate.day, date.day))

print "Interpolating {infile} to date {intdate} and writing to {outfile}".format(
                                 infile=INFILE, intdate=intdate, outfile=OUTFILE)

f = Nio.open_file(INFILE)

nmon = f.dimensions['month']
nlev = f.dimensions['plev']
nlat = f.dimensions['lat']
nlon = f.dimensions['lon']

months = f.variables['month'][:]
prs    = f.variables['prs'][:]
nwfa   = f.variables['nwfa'][:]
nifa   = f.variables['nifa'][:]

filedates = []
for i in xrange(nmon):
    month = months[i]
    if (calendar.monthrange(intdate.year, month)[1]) == 28:
        day_of_month = 14
        hour_of_day  = 12
    elif (calendar.monthrange(intdate.year, month)[1]) == 29:
        day_of_month = 15
        hour_of_day  = 0
    elif (calendar.monthrange(intdate.year, month)[1]) == 30:
        day_of_month = 15
        hour_of_day  = 12
    elif (calendar.monthrange(intdate.year, month)[1]) == 31:
        day_of_month = 16
        hour_of_day  = 0
    filedates.append(datetime.datetime(intdate.year, month, day_of_month, hour_of_day))

# Add one month before and after the filedates and create an index lookup table
prev_date = add_months(filedates[0], -1)
next_date = add_months(filedates[-1], 1)
extdates = [prev_date] + filedates + [next_date]
extindices = [nmon-1] + range(nmon) + [0]

for i in xrange(len(extdates)):
    if intdate==extdates[i]:
        idx_lo = i
        wgt_lo = 1
        idx_up = i
        wgt_up = 0
        break
    elif intdate>extdates[i] and intdate<extdates[i+1]:
        idx_lo = i
        idx_up = i+1
        sec_lo = (intdate-extdates[i]).total_seconds()
        sec_up = (extdates[i+1]-intdate).total_seconds()
        sec_to = (extdates[i+1]-extdates[i]).total_seconds()
        wgt_lo = sec_up/sec_to
        wgt_up = sec_lo/sec_to
        break

print "    surrounding dates (weights) are {datelo} ({weightlo}) and {dateup} ({weightup})".format(
                datelo=extdates[idx_lo], weightlo=wgt_lo, dateup=extdates[idx_up], weightup=wgt_up)

# Translate indices
idx_lo = extindices[idx_lo]
idx_up = extindices[idx_up]

intprs  = wgt_lo*prs[idx_lo]  + wgt_up*prs[idx_up]
intnwfa = wgt_lo*nwfa[idx_lo] + wgt_up*nwfa[idx_up]
intnifa = wgt_lo*nifa[idx_lo] + wgt_up*nifa[idx_up]

if os.path.isfile(OUTFILE):
    os.remove(OUTFILE)

g = Nio.open_file(OUTFILE, mode='c')
g.create_dimension('plev',  nlev)
g.create_dimension('lat',   nlat)
g.create_dimension('lon',   nlon)

g.create_variable('prs',   'f', ('plev', 'lat', 'lon')         )
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

g.create_variable('nwfa',  'f', ('plev', 'lat', 'lon')                                           )
setattr(g.variables['nwfa'],  'standard_name', 'number_concentration_of_water_friendly_aerosols' )
setattr(g.variables['nwfa'],  'long_name',     'number concentration of water friendly aerosols' )
setattr(g.variables['nwfa'],  'units',         'kg-1'                                            )

g.create_variable('nifa',  'f', ('plev', 'lat', 'lon')                                           )
setattr(g.variables['nifa'],  'standard_name', 'number_concentration_of_ice_friendly_aerosols'   )
setattr(g.variables['nifa'],  'long_name',     'number concentration of ice friendly aerosols'   )
setattr(g.variables['nifa'],  'units',         'kg-1'                                            )

g.variables['lat'][:]  = f.variables['lat'][:]
g.variables['lon'][:]  = f.variables['lon'][:]
g.variables['prs'][:]  = intprs
g.variables['nwfa'][:] = intnwfa
g.variables['nifa'][:] = intnifa

g.close()
