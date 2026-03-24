USER=Kate.Zhang


#module use -a /contrib/anaconda/modulefiles
#module load anaconda/anaconda3-5.3.1
#module load rocoto

BASEDIR=/scratch4/BMC/gsd-fv3-dev/lzhang/UFS-dev/global-workflow-DRSA
STMP=/scratch3/NCEPDEV/stmp2/$USER/RUNDIRS
IDATE=2016071500
EDATE=2016071500
APP=ATM
PSLOT=ACAT_C384_CCPP
RES=384
GFS_CYC=1
START=cold
COMROT=/scratch3/BMC/gsd-fv3-dev/NCEPDEV/global/$USER/fv3gfs/comrot
EXPDIR=/scratch4/BMC/gsd-fv3-dev/NCEPDEV/global/$USER/fv3gfs/expdir
ICSDIR=$COMROT/$PSLOT


#./setup_expt.py gfs forecast-only --idate $IDATE --edate $EDATE --app $APP --gfs_cyc $GFS_CYC --resdetatmos $RES --pslot $PSLOT --comroot $COMROT --expdir $EXPDIR 

./setup_expt.py gfs forecast-only --app $APP --pslot $PSLOT --idate $IDATE --edate $EDATE --resdetatmos $RES --gfs_cyc $GFS_CYC --comroot $COMROT --expdir $EXPDIR 


./setup_xml.py $EXPDIR/$PSLOT

