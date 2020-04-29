#!/bin/sh 
echo "*** Running gen_vx_mask for TRO and NA ***"

export MET_PATH=/scratch4/BMC/dtc/MET/met-5.2
export MET_BASE=$MET_PATH/share/met/
PATH=$PATH:$MET_PATH/bin
export PATH

echo PATH = $PATH
echo MET_BASE = $MET_BASE
export MASKS=$MET_BASE/poly

gridFile="forecast.GFS.G2.nc"

#gen_vx_mask $gridFile $maskFile $outFile
maskFile="gfs_TRO_G2.box"
outFile="gfs_TRO_G2.nc"

echo "Files:"
echo "input: $gridFile"
echo "mask:  $maskFile"
echo "out:   $outFile"
# height is form bottom of box to top of box
gen_vx_mask $gridFile $maskFile $outFile -type box -height 17 -width 145 -name TRO_G2_box

maskFile="gfs_NA_G2.box"
outFile="gfs_NA_G2.nc"

echo "Files:"
echo "input: $gridFile"
echo "mask:  $maskFile"
echo "out:   $outFile"

gen_vx_mask $gridFile $maskFile $outFile -type box -height 23 -width 56 -name NA_G2_box
