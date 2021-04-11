#!/bin/bash 

## this script makes links to GFS netcdf files under /public and copies over GFS analysis file for verification
##   /scratch4/BMC/rtfim/rtfuns/FV3GFS/FV3ICS/YYYYMMDDHH/gfs
##     sfcanl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/netcdf/YYDDDHH00.gfs.tHHz.sfcanl.nc
##     siganl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/netcdf/YYDDDHH00.gfs.tHHz.atmanl.nc

###############################################################
## Abstract:
## Copy GDAS atmanl file
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## COMPONENT : component directory (atmos)
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
configs="base checkgdas"
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
echo "COMPONENT = $COMPONENT"
echo "ICSDIR = $ICSDIR"
echo "PUBDIR = $PUBDIR"
echo "RETROGDAS = $RETROGDAS"
echo "EMCDIR = $EMCDIR"
echo "GDASDIR = $GDASDIR"
echo "ROTDIR = $ROTDIR"
echo "PSLOT = $PSLOT"
echo

## initialize
fv3ic_dir=$ICSDIR/$CDATE/$CDUMP

mkdir -p $fv3ic_dir
cd $fv3ic_dir

echo "****JKH*****"
echo " fv3ic_dir:  $fv3ic_dir "
echo "YYYYMMDDHH:  ${yyyymmdd}${hh}"

gdasbase=gdas.t${hh}z.atmanl.nc
gdasfile=$GDASDIR/${yyddd}${hh}00.${gdasbase}
ls  $gdasfile  #ESRL
status=$?
if [[ $status -ne 0 ]]; then
  echo "missing $gdasfile; check in $RETROGDAS..."
  gdasfile=$RETROGDAS/${yyddd}${hh}00.${gdasbase}
  ls  $gdasfile  #ESRL
  status=$?
  echo "JKH status RETROGDAS:  $status"
  if [[ $status -ne 0 ]]; then

    echo "missing $gdasfile; check in $EMCDIR..."
    gdasfile=$EMCDIR/gdas.${yyyymmdd}/${hh}/${COMPONENT}/${gdasbase}
    echo "JKH EMCDIR gdasfile :  $gdasfile"
    ls  $gdasfile
    status=$?
    echo "JKH status EMCGDAS:  $status"
    if [[ $status -ne 0 ]]; then
      echo "missing $gdasfile; check on mass store..."
      exit 1
##JKH  echo "missing $gdasfile in $RETROGDAS; check on mass store..."
##JKH
##JKH  # /5year/NCEPDEV/emc-global/emc.glopara/WCOSS_C/Q1FY19/prfv3rt1/gdas.2018041100/gdas.tar 
##JKH  #      ./gdas.20180411/00/gdas.t00z.atmanl.nc
##JKH  #      ./gdas.20180411/00/gdas.t00z.sfcanl.nc
##JKH  # /5year/NCEPDEV/emc-global/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1/2018041100/gdas.tar 
##JKH  #      changed 26 May 2018
##JKH  #
##JKH
##JKH  HPSSDIR="/5year/NCEPDEV/emc-global/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1/"
##JKH  gdasfile=$HPSSDIR/${yyyymmdd}${hh}/gdas.tar
##JKH  hsi -q list $gdasfile
##JKH  status=$?
##JKH  if [[ $status -ne 0 ]]; then
##JKH    echo "missing $gdasfile on mass store..."
##JKH    exit 1
##JKH  else
##JKH    cd $fv3ic_dir
##JKH    htar xvf ${gdasfile} ./gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nc 
##JKH    mv gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nc ./
##JKH    echo removing gdas.${yyyymmdd}/${hh}....
##JKH    rmdir gdas.${yyyymmdd}/${hh} gdas.${yyyymmdd}
##JKH    touch gdas_available
##JKH  fi
    fi 
  fi
fi
echo "JKH creating gdas_available!!"
echo "JKH $fv3ic_dir"
echo "JKH $gdasbase"
touch ${fv3ic_dir}/gdas_available

## create link
if [[ ! -f ${fv3ic_dir}/$gdasbase ]]; then
  echo linking $gdasfile....
  ln -fs $gdasfile ${fv3ic_dir}/gdas.t${hh}z.atmanl.nc
else
  echo ${fv3ic_dir}/$gdasbase already exists!
fi
