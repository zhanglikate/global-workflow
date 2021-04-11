#!/bin/ksh -x

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
if [ $CDATE -ge "2021032212" ]; then
    $HOMEgfs/jobs/rocoto/getic_fv3gfsv16.sh
else
    $HOMEgfs/jobs/rocoto/getic_fv3gfsv15.sh
fi
rc=$?
if [ $rc -ne 0 ]; then
    echo "error getic $rc "
    exit $rc
fi 

###############################################################

###############################################################
# Exit cleanly

