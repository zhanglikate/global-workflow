#!/bin/bash 

## this script makes links to GFS nemsio files under /public and copies over GFS analysis file for verification
##   /scratch4/BMC/rtfim/rtfuns/FV3GFS/FV3ICS/YYYYMMDDHH/gfs
##     sfcanl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.sfcanl.nemsio
##     siganl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.atmanl.nemsio

###############################################################
## Abstract:
## Get GFS intitial conditions
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
###############################################################

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done


###############################################################
# Set script and dependency variablesyyyymmdd=`echo $CDATE | cut -c1-8`
yyyymmdd=$(echo $CDATE | cut -c1-8)
hh=$(echo $CDATE | cut -c9-10)
yyyy=$(echo $CDATE | cut -c1-4)
mm=$(echo $CDATE | cut -c5-6)
dd=$(echo $CDATE | cut -c7-8)
yyddd=$(date +%y%j -u -d $yyyymmdd)


echo
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "ICSDIR = $ICSDIR"
echo "PUBDIR = $PUBDIR"
echo "RETROGDAS = $RETROGDAS"
echo "GDASDIR = $GDASDIR"
echo "ROTDIR = $ROTDIR"
echo "PSLOT = $PSLOT"
echo

## initialize
fv3ic_dir=$ICSDIR/${CDATE}/${CDUMP}/$CDUMP.$yyyymmdd/$hh

mkdir -p $fv3ic_dir
cd $fv3ic_dir

echo "YYYYMMDDHH:  ${yyyymmdd}${hh}"

gdasfile=$GDASDIR/${yyddd}${hh}00.gdas.t${hh}z.atmanl.nemsio
ls  $gdasfile  #ESRL
status=$?
if [[ $status -ne 0 ]]; then
  echo "missing $gdasfile on /public; check in $RETROGDAS..."
  ls  $gdasfile  #ESRL
  status=$?
elif [[ $status -ne 0 ]]; then

  echo "missing $gdasfile in $RETROGDAS; check on mass store..."

  # Operational archive
  #    /NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyy}${mm}${dd}/
  #      {$nameprefix}_gfs_prod_gdas.${yyyy}${mm}${dd}_${hh}.gdas_nemsio.tar
  #  
  #     where nameprefix=com                           00Z 02/26/2020
  #                      gpfs_dell1_nco_ios_com        12Z 06/12/2019
  #
 
  HPSSDIR="/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyy}${mm}/${yyyy}${mm}${dd}"
  gdasfile="${HPSSDIR}/com_gfs_prod_gdas.${yyyy}${mm}${dd}_${hh}.gdas_nemsio.tar"
  hsi -q list $gdasfile
  status=$?
  if [[ $status -ne 0 ]]; then
    ### 12Z 12Jun2019 -- FV3GFS operational
    echo "missing $gdasfile on mass store...; try gpfs_dell1 filename!"
    gdasfile=${HPSSDIR}/gpfs_dell1_nco_ops_com_gfs_prod_gdas.${yyyy}${mm}${dd}_${hh}.gdas_nemsio.tar
    hsi -q list $gdasfile
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "missing $gfsfile on mass store..."
      exit 1
    fi
  else
    cd $fv3ic_dir
    htar xvf ${gdasfile} ./gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nemsio 
    mv gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nemsio ./
    echo removing gdas.${yyyymmdd}/${hh}....
    rmdir gdas.${yyyymmdd}/${hh} gdas.${yyyymmdd}
    touch gdas_available
  fi
else
  touch gdas_available
fi
