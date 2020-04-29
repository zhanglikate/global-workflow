#!/bin/sh 

# check for correct number of parameters
#   /scratch4/BMC/rtfim/exp/CCPPsuite-FV3/FV3GFSrun//suite/gfs.20180901/00/gfs.t00z.pgrb2.0p50.f000
if [ $# -lt 2 ]; then
  echo "   Usage:  $0  suite4D suite4D"
  exit 1
fi

# initialize
runDir=/scratch4/BMC/rtfim/exp/CCPPsuite-FV3/FV3GFSrun/

dummyDir=$1
pslot=$2

for day in `seq -f %02g 1 8`
do

  date=201809${day}
  echo "processing $date...."
  dateDir=${runDir}/${dummyDir}/gfs.${date}/00
  mkdir -p $dateDir
  
  srcDir=${runDir}/${pslot}/gfs.$date/00
  echo "$dateDir  $runDir  srcDir=$srcDir"
  
  cd $dateDir
  for file in ${srcDir}/gfs*0p50.f*
  do
    echo $file
    ln -sf $file
  done
  
done
