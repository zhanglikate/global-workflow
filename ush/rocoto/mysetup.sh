#!/bin/sh

echo "Load modules first"
module load rocoto
module load hpss

CWD=`pwd`

# ./setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR

# $PSLOT is the name of your experiment
PSLOT=fv3test1

# $CONFIGDIR is the path to the /config folder under the copy of the system you're using (i.e. ../parm/config/)
#CONFIGDIR=/gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/fv3gfs/parm/config
CONFIGDIR=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/fv3gfs/parm/config

ICSDIR=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/ICS/FV3GFS

# $IDATE is the initial start date of your run (first cycle CDATE, YYYYMMDDCC)
#IDATE=2017073118
IDATE=2016100300

# $EDATE is the ending date of your run (YYYYMMDDCC) and is the last cycle that will complete
#EDATE=2017073118
EDATE=2016100300

# $RES is the resolution of the forecast (i.e. 768 for C768)
RES=96

# $GFS_CYC is the forecast frequency (0 = none, 1 = 00z only [default], 2 = 00z & 12z, 4 = all cycles)
GFS_CYC=1

# $COMROT is the path to your experiment output directory. DO NOT include PSLOT folder at end of path, it’ll be built for you.

#COMROT=/gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/COMFV3
COMROT=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/COMFV3
mkdir -p $COMROT

# $EXPDIR is the path to your experiment directory where your configs will be placed and where you will find your workflow monitoring files (i.e. rocoto database and xml file). DO NOT include PSLOT folder at end of path, it will be built for you.

#EXPDIR=/gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/EXPFV3
EXPDIR=/scratch4/NCEPDEV/nems/noscrub/Patrick.Tripp/EXPFV3
mkdir -p $EXPDIR

./setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR

# Edit base.config
# Change noscrub dirs from global to climate
# Change account to CFS-T20

# Link ICs
# mkdir -p /gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/COMFV3/fvtest1/gdas.20170731/18
# cd /gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/COMFV3/fvtest1/gdas.20170731/18
# ln -s /gpfs/hps3/emc/climate/noscrub/Patrick.Tripp/ICSDIR/2017073118/gfs/C96/INPUT INPUT
YMD=`echo $IDATE | cut -c1-8`
HH=`echo $IDATE | cut -c9-10`
mkdir -p $COMROT/$PSLOT/gfs.$YMD/$HH
cd $COMROT/$PSLOT/gfs.$YMD/$HH
ln -s $ICSDIR/$IDATE/gfs/C$RES/control/INPUT INPUT

# Come back to this folder
cd $CWD

# Setup workflow
./setup_workflow_fcstonly.py --expdir $EXPDIR/$PSLOT/

# Copy rocoto_viewer.py tp EXPDIR
cp rocoto_viewer.py $EXPDIR/$PSLOT
