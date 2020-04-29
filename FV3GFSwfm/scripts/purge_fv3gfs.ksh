#!/bin/ksh --login

# this script removes *master* grib2 and *nemsio binary files from the output directory

echo entering purge_fv3gfs.ksh....
echo "FV3GFS_RUN     =  ${FV3GFS_RUN}"
echo "PSLOT          =  ${PSLOT}"
echo "CDUMP          =  ${CDUMP}"
echo "yyyymmdd       =  ${yyyymmdd}"
echo "hh             =  ${hh}"
echo "T              =  ${T}"

# initialize
dir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${hh}
RM=/bin/rm

# delete *nemsio files and master grib2 file for specified cycle
cd $dir
echo "** processing $dir"
echo removing nemsio files....
$RM ${CDUMP}.t${hh}z.*f${T}.nemsio
echo removing Gaussian grid files....
$RM ${CDUMP}.t${hh}z.master*f${T}
