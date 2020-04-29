#!/bin/sh 
echo "*** Running gen_vx_mask ***"

export MET_PATH=/scratch4/BMC/dtc/MET/met-5.2
export MET_BASE=$MET_PATH/share/met/
PATH=$PATH:$MET_PATH/bin
export PATH

echo PATH = $PATH
echo MET_BASE = $MET_BASE
export MASKS=$MET_BASE/poly

toGrid="G002"

# Regrid a forecast file from 1.0-deg to G2 (2.5 deg)as a grid template
#inFile="/scratch3/BMC/amb-verif/mv_retro_data/grib/gfs_full/7/0/96/0_259920_0/1703100000165"
#outFile="forecast.GFS.G2.nc"
#regrid_data_plane $inFile $toGrid $outFile -field 'name="TMP"; level="P500";'

inFile="gfs_NH.poly"
outFile="gfs_NH_G2.nc"
regrid_data_plane $inFile $toGrid $outFile  -field 'name="TMP"; level="P500";'

#inFile="gfs_SH_G4.nc"
#outFile="gfs_SH_G2.nc"
#regrid_data_plane $inFile $toGrid $outFile -field 'name="TMP"; level="P500";'

