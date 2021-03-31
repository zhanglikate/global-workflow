#!/bin/ksh -x

###############################################################
## Abstract:
## Create biomass burning emissions for FV3-CHEM
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
if [ $CDATE -ge "2021030100" ]; then
    $HOMEgfs/jobs/rocoto/fv3ic_gfsv16.sh
else
    $HOMEgfs/jobs/rocoto/fv3ic_gfsv15.sh
fi
echo "error fv3ic $rc "
     exit $rc


###############################################################

###############################################################
# Exit cleanly

