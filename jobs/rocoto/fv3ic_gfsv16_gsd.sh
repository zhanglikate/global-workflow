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
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs16_modules.sh
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
###############################################################
res=`echo $CASE | cut -c2-4`

export envir=${envir:-dev}
export RUN_ENVIR=${RUN_ENVIR:-dev}
export total_tasks=${GEFS_NTASKS:-36}
export OMP_NUM_THREADS=${GEFS_TPP:-1}
export taskspernode=${GEFS_PPN:-36}

export CRES=$res
export APRUN="srun --export=ALL"
###############################################################

# Temporary runtime directory
export DATA="$RUNDIR/$CDATE/$CDUMP/fv3ic$$"
[[ -d $DATA ]] && rm -rf $DATA

# Input GFS initial condition files
export INIDIR="$ICSDIR/$CDATE/$CDUMP"
export COMIN="$ICSDIR/$CDATE/$CDUMP"
#export ATMANL="$ICSDIR/$CDATE/$CDUMP/siganl.${CDUMP}.$CDATE"
#export SFCANL="$ICSDIR/$CDATE/$CDUMP/sfcanl.${CDUMP}.$CDATE"
if [ -f $ICSDIR/$CDATE/$CDUMP/nstanl.${CDUMP}.$CDATE ]; then
    export NSTANL="$ICSDIR/$CDATE/$CDUMP/nstanl.${CDUMP}.$CDATE"
fi

# Output FV3 initial condition files
export OUTDIR="$ICSDIR/$CDATE/$CDUMP/$CASE/INPUT"
[[ ! -d $OUTDIR ]] && mkdir -p $OUTDIR

export HOMEufs=$HOMEgfs
export INPUT_TYPE=gaussian_netcdf
export ATM_FILES_INPUT=${CDUMP}.t00z.atmanl.nc
export SFC_FILES_INPUT=${CDUMP}.t00z.sfcanl.nc
#export ATM_FILES_INPUT=siganl.${CDUMP}.${PDY}${cyc}
#export SFC_FILES_INPUT=sfcanl.${CDUMP}.${PDY}${cyc}


# Call chgres_cube.sh
$HOMEgfs/ush/chgres_cube.sh
status=$?
if [ $status -ne 0 ]; then
    echo "chgres_cube.sh returned with a non-zero exit code, ABORT!"
    exit $status
fi

# Move files to the nwges directory
for tile in tile1 tile2 tile3 tile4 tile5 tile6; do
	mv ${DATA}/out.atm.${tile}.nc $OUTDIR/gfs_data.${tile}.nc
	mv ${DATA}/out.sfc.${tile}.nc $OUTDIR/sfc_data.${tile}.nc
done
mv ${DATA}/gfs_ctrl.nc $OUTDIR/.


# Stage the FV3 initial conditions to ROTDIR
COMOUT="$ROTDIR/$CDUMP.$PDY/$cyc"
[[ ! -d $COMOUT ]] && mkdir -p $COMOUT
cd $COMOUT || exit 99
rm -rf INPUT
$NLN $OUTDIR .

###############################################################
# Exit cleanly
exit 0
