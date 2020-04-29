#!/bin/sh 
echo "*** Running gen_vx_mask ***"

export MET_PATH=/scratch4/BMC/dtc/MET/met-5.2
export MET_BASE=$MET_PATH/share/met/
PATH=$PATH:$MET_PATH/bin
export PATH

echo PATH = $PATH
echo MET_BASE = $MET_BASE
export MASKS=$MET_BASE/poly

analFile="/scratch3/BMC/amb-verif/mv_retro_data/grib/gfs_full/7/0/81/0_259920_0/1700100000000"
gridFile="forecast.GFS.G2.nc"
maskFile="gfs_NH.poly"
outFile="gfs_NH_G2.nc"

echo "Files:"
echo "input: $gridFile"
echo "mask:  $maskFile"
echo "out:   $outFile"

#gen_vx_mask $gridFile $maskFile $outFile
maskFile="gfs_NH_G2.box"
outFile="gfs_NH_G2.nc"
# if height is from center point to box edge
#gen_vx_mask $gridFile $maskFile $outFile -type box -height 12.167 -width 145
# if height is form bottom of box to top of box
gen_vx_mask $gridFile $maskFile $outFile -type box -height 25 -width 145 -name NH_G2_box

maskFile="gfs_SH.poly"
outFile="gfs_SH_G2.nc"

echo "Files:"
echo "input: $gridFile"
echo "mask:  $maskFile"
echo "out:   $outFile"

#gen_vx_mask $gridFile $maskFile $outFile
maskFile="gfs_SH_G2.box"
outFile="gfs_SH_G2.nc"
gen_vx_mask $gridFile $maskFile $outFile -type box -height 25 -width 145 -name SH_G2_box
