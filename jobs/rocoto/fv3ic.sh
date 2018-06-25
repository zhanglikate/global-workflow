#!/bin/ksh -x

###############################################################
## Abstract:
## Create FV3 initial conditions from GFS intitial conditions
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
configs="base fv3ic"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

###############################################################
# Source machine runtime environment
. $BASE_ENV/${machine}.env fv3ic
status=$?
[[ $status -ne 0 ]] && exit $status

# Temporary runtime directory
export DATA="$RUNDIR/$CDATE/$CDUMP/fv3ic$$"
[[ -d $DATA ]] && rm -rf $DATA

# Input GFS initial condition files
export INIDIR="$ICSDIR/$CDATE/$CDUMP"
export ATMANL="$ICSDIR/$CDATE/$CDUMP/siganl.${CDUMP}.$CDATE"
export SFCANL="$ICSDIR/$CDATE/$CDUMP/sfcanl.${CDUMP}.$CDATE"
if [ -f $ICSDIR/$CDATE/$CDUMP/nstanl.${CDUMP}.$CDATE ]; then
    export NSTANL="$ICSDIR/$CDATE/$CDUMP/nstanl.${CDUMP}.$CDATE"
fi

# Output FV3 initial condition files
export OUTDIR="$ICSDIR/$CDATE/$CDUMP/$CASE/INPUT"

export OMP_NUM_THREADS_CH=$NTHREADS_CHGRES
export APRUNC=$APRUN_CHGRES

# Call global_chgres_driver.sh
$HOMEgfs/ush/global_chgres_driver.sh
status=$?
if [ $status -ne 0 ]; then
    echo "global_chgres_driver.sh returned with a non-zero exit code, ABORT!"
    exit $status
fi

# Stage the FV3 initial conditions to ROTDIR
COMOUT="$ROTDIR/$CDUMP.$PDY/$cyc"
[[ ! -d $COMOUT ]] && mkdir -p $COMOUT
cd $COMOUT || exit 99
rm -rf INPUT
#PT since INPUT directory is also used by MOM6 ICs, do not link, copy instead
#$NLN $OUTDIR .
mkdir INPUT
cd INPUT
$NCP $OUTDIR/* .

# If coupled, copy mom6 and cice initial conditions
#PT need to figure out how to handle coldstart COMOUT, separate directory or same directory with overwrite during warmstart.
#It can get hacky if design is not thought out well
# This is currently in prep script called from exglobal - move to here eventually
#if [ $cpl = ".true." ] ; then
#
  #cd $COMOUT/INPUT 
  #$NCP $ICSDIR/$CDATE/mom6/MOM6_restart_$CDATE.tar .
  #tar -xvf MOM6_restart_$CDATE.tar  
#
  #cd $COMOUT
  #$NCP $ICSDIR/$CDATE/cice5/cice5_model_0.25.res_$CDATE.nc .
#
#fi

###############################################################
# Exit cleanly
exit 0
