#!/bin/sh 

## this script makes links to GFS nemsio files under /public and copies over GFS analysis file for verification
##   /scratch4/BMC/rtfim/rtfuns/FV3GFS/FV3ICS/YYYYMMDDHH/gfs
##     sfcanl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.sfcanl.nemsio
##     siganl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.atmanl.nemsio
##     nstanl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.nstanl.nemsio


echo
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "ICSDIR = $ICSDIR"
echo "PUBDIR = $PUBDIR"
echo "RETRODIR = $RETRODIR"
echo "ROTDIR = $ROTDIR"
echo "PSLOT = $PSLOT"
echo

## initialize
yyyymmdd=`echo $CDATE | cut -c1-8`
hh=`echo $CDATE | cut -c9-10`
yyddd=`date +%y%j -u -d $yyyymmdd`
fv3ic_dir=$ICSDIR/${CDATE}/${CDUMP}

## create links in FV3ICS directory
mkdir -p $fv3ic_dir
cd $fv3ic_dir
echo "making link to nemsio files under $fv3ic_dir"
if [[ -f $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio ]]
then
  ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio sfcanl.gfs.${CDATE}
  ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.atmanl.nemsio siganl.gfs.${CDATE}
  if [[ -f $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.nstanl.nemsio ]] 
  then 
    ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.nstanl.nemsio nstanl.gfs.${CDATE}
  fi
else 
  if [[ -f $RETRODIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio ]]
  then
    ln -fs $RETRODIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio sfcanl.gfs.${CDATE}
    ln -fs $RETRODIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.atmanl.nemsio siganl.gfs.${CDATE}
    if [[ -f $RETRODIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.nstanl.nemsio ]] 
    then
      ln -fs $RETRODIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.nstanl.nemsio nstanl.gfs.${CDATE}
    fi 
  fi
fi
