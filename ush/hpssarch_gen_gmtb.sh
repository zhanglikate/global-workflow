#!/bin/ksh
set -x

###################################################
# Fanglin Yang, 20180318
# --create bunches of files to be archived to HPSS
# -- modified by Judy Henderson for GMTB test
###################################################

CDATE=${CDATE:-2018010100}
PDY=$(echo $CDATE | cut -c 1-8)
cyc=$(echo $CDATE | cut -c 9-10)
OUTPUT_FILE=${OUTPUT_FILE:-"netcdf"}
OUTPUT_HISTORY=${OUTPUT_HISTORY:-".true."}
SUFFIX=${SUFFIX:-".nc"}
if [ $SUFFIX = ".nc" ]; then
  format="netcdf"
else
  format="nemsio"
fi

FHMIN_GFS=${FHMIN_GFS:-0}
FHMAX_GFS=${FHMAX_GFS:-384}
FHOUT_GFS=${FHOUT_GFS:-3}
FHMAX_HF_GFS=${FHMAX_HF_GFS:-120}
FHOUT_HF_GFS=${FHOUT_HF_GFS:-1}

rm -f gfs_pgrb2b.txt
touch gfs_pgrb2b.txt

dirpath="gfs.${PDY}/${cyc}/"
dirname="./${dirpath}"
echo  "${dirname}avno.t${cyc}z.cyclone.trackatcfunix     " >>gfs_pgrb2b.txt
echo  "${dirname}avnop.t${cyc}z.cyclone.trackatcfunix    " >>gfs_pgrb2b.txt
fh=0
head="gfs.t${cyc}z."
while [ $fh -le $FHMAX_GFS ]; do
  fhr=$(printf %03i $fh)
  echo  "${dirname}${head}pgrb2.0p25.f${fhr}             " >>gfs_pgrb2b.txt
  echo  "${dirname}${head}pgrb2.0p25.f${fhr}.idx         " >>gfs_pgrb2b.txt

  inc=$FHOUT_GFS
  if [ $FHMAX_HF_GFS -gt 0 -a $FHOUT_HF_GFS -gt 0 -a $fh -lt $FHMAX_HF_GFS ]; then
   inc=$FHOUT_HF_GFS
  fi

  fh=$((fh+inc))
done
