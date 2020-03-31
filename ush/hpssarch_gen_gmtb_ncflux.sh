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

rm -f gfs_flux.txt
rm -f gfs_ncf.txt
touch gfs_flux.txt
touch gfs_ncf.txt

dirpath="gfs.${PDY}/${cyc}/"
dirname="./${dirpath}"
fh=0
head="gfs.t${cyc}z."
while [ $fh -le $FHMAX_GFS ]; do
  fhr=$(printf %03i $fh)

  echo  "${dirname}${head}sfluxgrbf${fhr}.grib2           " >>gfs_flux.txt
  echo  "${dirname}${head}sfluxgrbf${fhr}.grib2.idx       " >>gfs_flux.txt

  rem=`expr $fhr % 12`
  if [ $rem -eq 0 ]; then
    echo  "${dirname}${head}atmf${fhr}.nemsio_select.nc4       " >>gfs_ncf.txt
  fi

  inc=$FHOUT_GFS
  if [ $FHMAX_HF_GFS -gt 0 -a $FHOUT_HF_GFS -gt 0 -a $fh -lt $FHMAX_HF_GFS ]; then
   inc=$FHOUT_HF_GFS
  fi

  fh=$((fh+inc))
done
