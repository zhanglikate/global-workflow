#!/bin/sh
set -x

echo "Load modules first"
source /usr/Modules/3.2.10/init/sh
module load rocoto
module load hpss

CWD=`pwd`

# ./setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR

# $PSLOT is the name of your experiment
PSLOT=c384_test

# $COMROT is the path to your experiment output directory. DO NOT include PSLOT folder at end of path, it’ll be built for you.
COMROT=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/COMFV3
mkdir -p $COMROT

# $CONFIGDIR is the path to the /config folder under the copy of the system you're using (i.e. ../parm/config/)
CONFIGDIR=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/new.fv3gfs/parm/config

# do not export ICSDIR, causes error in py script
ICSDIR=$COMROT/FV3ICS

# Link the existing FV3ICS folder to here, I prefer this directory to be in main directory, but changing in script can cause issues
mkdir -p $COMROT
cd $COMROT
mkdir -p ../FV3ICS
ln -s ../FV3ICS .

cd $CWD

# $IDATE is the initial start date of your run (first cycle CDATE, YYYYMMDDCC)
IDATE=2016100300
#IDATE=2015040100

# $EDATE is the ending date of your run (YYYYMMDDCC) and is the last cycle that will complete
EDATE=2016100300
#EDATE=2015040100

# $RES is the resolution of the forecast (i.e. 768 for C768)
RES=384

# $GFS_CYC is the forecast frequency (0 = none, 1 = 00z only [default], 2 = 00z & 12z, 4 = all cycles)
GFS_CYC=1

# $EXPDIR is the path to your experiment directory where your configs will be placed and where you will find your workflow monitoring files (i.e. rocoto database and xml file). DO NOT include PSLOT folder at end of path, it will be built for you.

EXPDIR=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/EXPFV3
mkdir -p $EXPDIR

./setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR

# Edit base.config
# Change noscrub dirs from global to climate
# Change account to CFS-T20

# Copy ICs : can put in a loop if running multiple cycles

YMD=`echo $IDATE | cut -c1-8`
HH=`echo $IDATE | cut -c9-10`
mkdir -p $COMROT/$PSLOT/gfs.$YMD/$HH/INPUT
cd $COMROT/$PSLOT/gfs.$YMD/$HH/INPUT

# Copy the ICs if they exist, otherwise the workflow will generate them from EMC_ugcs ICs
if [ -d $ICSDIR/$IDATE/gfs/C$RES/INPUT ] ; then
  cp -p $ICSDIR/$IDATE/gfs/C$RES/INPUT/* .
fi

# Come back to this folder
cd $CWD

# Setup workflow
./setup_workflow_fcstonly.py --expdir $EXPDIR/$PSLOT

# Copy rocoto_viewer.py tp EXPDIR
cp rocoto_viewer.py $EXPDIR/$PSLOT
