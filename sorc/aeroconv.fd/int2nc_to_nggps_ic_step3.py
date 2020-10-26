#!/usr/bin/env python

import numpy
import os
from PyNIO import Nio
import sys

# List of supported cases/setups
CASES = {
    'global'   : { 'first' : 1, 'last' : 6 },
    'regional' : { 'first' : 7, 'last' : 7 },
    'nested'   : { 'first' : 1, 'last' : 7 },
    }

if len(sys.argv)<2:
    raise Exception("No case provided, possible choces are: {0}".format(
                                               ', '.join(CASES.keys())))
else:
    case = sys.argv[1].lower().strip()
if not case in CASES.keys():
    raise Exception("Invalid case/setup '{0}', possible choices are: {1}".format(case,
                                                             ', '.join(CASES.keys())))
FIRST = CASES[case]['first']
LAST  = CASES[case]['last']
INFILE1 = 'INPUT/grid_spec.tile{nt}.nc'
INFILE2 = "INPUT/gfs_ctrl.nc"
OUTFILE = 'INTERMEDIATE/nggps_grid.step3.tile{nt}.out.nc'

print "Creating 3-dim. grid information for NGGPS ICs from {infile1} and {infile2}".format(
                                           infile1=INFILE1.format(nt='?'), infile2=INFILE2)

# Horizontal grid
tiles = {}
nt = FIRST
while nt <= LAST:
    tile_infile = INFILE1.format(nt=nt)
    f1 = Nio.open_file(tile_infile)
    tiles[nt] = {}
    tiles[nt]['lat'] = f1.variables['grid_latt'][:]
    tiles[nt]['lon'] = f1.variables['grid_lont'][:]
    f1.close()
    nt = nt+1
nlat = tiles[FIRST]['lat'].shape[0]
nlon = tiles[FIRST]['lon'].shape[0]
print "    horizontal grid resolution of NGGPS ICs: nlat x nlon =", nlat, "x", nlon

# Vertical pressure level grid. Note that GFS vertical levels run from TOA (level 0)
# to surface (level 64), but that these levels get flipped in FV3/GFS physics!
p0 = 101325 # Pa
f2 = Nio.open_file(INFILE2)
vcoord = f2.variables['vcoord']
ak = vcoord[0,:]
bk = vcoord[1,:]
nlev = ak.shape[0] - 1
plev = numpy.zeros((nlev,))
for j in xrange(nlev):
    i = j+1
    plev[j] = ak[i] + p0*bk[i]
f2.close()
print "    vertical grid resolution of NGGPS ICs: nlev =", nlev

nt = FIRST
while nt <= LAST:
    tiles[nt]['prs'] = numpy.zeros((nlev, nlat, nlon), dtype=tiles[nt]['lon'].dtype)
    for i in xrange(nlon):
        for j in xrange(nlat):
            tiles[nt]['prs'][:,j,i] = plev[:]
    tile_outfile = OUTFILE.format(nt=nt)
    if os.path.isfile(tile_outfile):
        os.remove(tile_outfile)
    g = Nio.open_file(tile_outfile, mode='c')
    g.create_dimension('plev', nlev)
    g.create_dimension('lat',  nlat)
    g.create_dimension('lon',  nlon)

    g.create_variable('prs',   'f', ('plev', 'lat', 'lon')         )
    setattr(g.variables['prs'],   'standard_name', 'air_pressure'  )
    setattr(g.variables['prs'],   'long_name',     'air pressure'  )
    setattr(g.variables['prs'],   'units',         'Pa'            )
    setattr(g.variables['prs'],   'axis',          'Z'             )
    setattr(g.variables['prs'],   'positive',      'down'          )

    g.create_variable('lat',   'f', ('lat','lon'))
    setattr(g.variables['lat'],   'standard_name', 'latitude'      )
    setattr(g.variables['lat'],   'long_name',     'latitude'      )
    setattr(g.variables['lat'],   'units',         'degrees_north' )
    setattr(g.variables['lat'],   'axis',          'Y'             )

    g.create_variable('lon',   'f', ('lat','lon'))
    setattr(g.variables['lon'],   'standard_name', 'longitude'     )
    setattr(g.variables['lon'],   'long_name',     'longitude'     )
    setattr(g.variables['lon'],   'units',         'degrees_east'  )
    setattr(g.variables['lon'],   'axis',          'X'             )

    g.variables['prs'][:] = tiles[nt]['prs'][:]
    g.variables['lat'][:] = tiles[nt]['lat'][:]
    g.variables['lon'][:] = tiles[nt]['lon'][:]
    g.close()
    print "    creating {0}".format(tile_outfile)
    nt = nt+1
