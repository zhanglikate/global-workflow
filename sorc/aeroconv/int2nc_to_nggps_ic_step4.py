#!/usr/bin/env python

import calendar
import datetime
import numpy
import os
from PyNIO import Nio
import sys
from tempfile import mktemp

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
INFILE1 = 'INPUT/gfs_data.tile{nt}.nc'
INFILE2 = 'INTERMEDIATE/QNWFA_QNIFA_SIGMA_DATEINT.step2.out.nc'
INFILE3 = 'INTERMEDIATE/nggps_grid.step3.tile{nt}.out.nc'
#OUTFILE = 'OUTPUT/aero_data.tile{nt}.nc'
OUTFILE = 'OUTPUT/gfs_data.tile{nt}.nc'

print "Interpolating time-interpolated Thompson aerosol climatology in {infile2} onto NGGPS IC grid in {infile3}".format(infile2=INFILE2, infile3=INFILE3.format(nt='?'))
print "and adding result to {outfile} (copies of {infile1}".format(outfile=OUTFILE.format(nt='?'), infile1=INFILE1.format(nt='?'))
print "---"

def execute(cmd):
    print "Executing {0}".format(cmd)
    status = os.system(cmd)
    if not status==0:
        raise Exception("ERROR executing {0}".format(cmd))

nt = FIRST
while nt <= LAST:
    tile_original = INFILE1.format(nt=nt)
    tile_infile   = INFILE3.format(nt=nt)
    tile_outfile  = OUTFILE.format(nt=nt)
    if os.path.isfile(tile_outfile):
        os.remove(tile_outfile)

    tmp_regrid        = mktemp()
    tmp_prs           = mktemp()
    tmp_prs_stripped  = mktemp()
    tmp_aero          = mktemp()
    tmp_aero_stripped = mktemp()
    tmp_dst_vgrid     = mktemp()
    tmp_output        = mktemp()
    tmp_rename        = mktemp()
    tmp_strip         = mktemp()
    tmp_history       = mktemp()

    cmd = "ncremap -a bilinear -i {infile} -d {dstgrid} -o {outfile}".format(dstgrid=tile_infile, infile=INFILE2, outfile=tmp_regrid)
    execute(cmd)
    # Extract pressure
    cmd = "ncks -v prs -C {infile} {outfile}".format(infile=tmp_regrid, outfile=tmp_prs)
    execute(cmd)
    # Remove unwanted attributes from ncremap process from tmp_prs
    cmd = """ncatted -h \
-a 'cell_measures',prs,d,, \
-a 'history',global,d,, \
-a 'remap_script',global,d,, \
-a 'remap_command',global,d,, \
-a 'remap_hostname',global,d,, \
-a 'remap_version',global,d,, \
-a 'NCO',global,d,, \
-a 'nco_openmp_thread_number',global,d,, \
-a 'map_file',global,d,, \
-a 'input_file',global,d,, \
{infile} {outfile}""".format(infile=tmp_prs, outfile=tmp_prs_stripped)
    execute(cmd)
    # Extract aerosols
    cmd = "ncks -v nwfa,nifa -C {infile} {outfile}".format(infile=tmp_regrid, outfile=tmp_aero)
    execute(cmd)
    # Remove unwanted attributes from ncremap process from tmp_aero
    cmd = """ncatted -h \
-a 'cell_measures',nifa,d,, \
-a 'cell_measures',nwfa,d,, \
-a 'history',global,d,, \
-a 'remap_script',global,d,, \
-a 'remap_command',global,d,, \
-a 'remap_hostname',global,d,, \
-a 'remap_version',global,d,, \
-a 'NCO',global,d,, \
-a 'nco_openmp_thread_number',global,d,, \
-a 'map_file',global,d,, \
-a 'input_file',global,d,, \
{infile} {outfile}""".format(infile=tmp_aero, outfile=tmp_aero_stripped)
    execute(cmd)
    # Create netCDF file with destination vertical grid only
    cmd = "ncks -h -v prs -C {tile_infile} {tmp_dst_vgrid}".format(tile_infile=tile_infile, tmp_dst_vgrid=tmp_dst_vgrid)
    execute(cmd)
    # Interpolate vertical levels of aerosol climatology onto vertical levels of NGGPS initial conditions
    cmd = "cdo intlevelx3d,{srcvgrid} {infile} {dstvgrid} {outfile}".format(srcvgrid=tmp_prs_stripped, infile=tmp_aero_stripped,
                                                                            dstvgrid=tmp_dst_vgrid, outfile=tmp_output)
    execute(cmd)
    cmd = "ncrename -v nwfa,liq_aero -v nifa,ice_aero {infile} {outfile}".format(infile=tmp_output, outfile=tmp_rename)
    execute(cmd)
    cmd = "ncks -7 -C -v liq_aero,ice_aero {infile} {outfile}".format(infile=tmp_rename, outfile=tmp_strip)
    execute(cmd)
    cmd = "ncatted -h -a Conventions,global,d,, -a NCO,global,d,, -a CDO,global,d,,  -a CDI,global,d,, -a history,global,d,, {infile} {outfile}".format(infile=tmp_strip, outfile=tmp_history)
    execute(cmd)
    cmd = "cp {infile} {outfile}".format(infile=tile_original, outfile=tile_outfile)
    execute(cmd)
    cmd = "ncks -h -A {infile} {outfile}".format(infile=tmp_history, outfile=tile_outfile)
    execute(cmd)

    #os.remove(tmp_regrid)
    #os.remove(tmp_prs)
    #os.remove(tmp_prs_stripped)
    #os.remove(tmp_aero)
    #os.remove(tmp_aero_stripped)
    #os.remove(tmp_dst_vgrid)
    #os.remove(tmp_output)
    #os.remove(tmp_rename)
    #os.remove(tmp_strip)
    #os.remove(tmp_history)
    nt = nt+1