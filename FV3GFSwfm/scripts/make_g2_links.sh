#!/bin/sh

## this script makes links to FV3 0.5 grib2 files
##     gfs.t00z.pgrb2.0p50.f###

# check for correct number of parameters
if [ $# -lt 4 ]; then
  echo "   Usage:  $0  RUNDIR PSLOT YYYYMMDD HH "
  exit 1
fi

rundir=$1
pslot=$2
yyyymmdd=$3
hh=$4
#comrot=/scratch4/BMC/gmtb/jhender/NCEPDEV/global/noscrub/Judy.K.Henderson/fv3gfs/comrot/${pslot}
cdump=gfs
gdir=${rundir}/${pslot}/${cdump}.${yyyymmdd}/${hh}

if [ ! -d ${gdir}/post/fim ]
then
  echo "creating ${gdir}/post" 
  mkdir -p ${gdir}/post/fim
fi

cd ${gdir}/post/fim
fhrs=`seq -f %03g 0 6 120`
for fhr in $fhrs
do
  file=${gdir}/${cdump}.t${hh}z.pgrb2.0p50.f${fhr}
  yyddd=`date +%y%j -u -d $yyyymmdd`
  echo creating link for $fhr....
  ln -s $file ${yyddd}${hh}000${fhr}.g2
done
