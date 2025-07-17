USER=Kate.Zhang


BASEDIR=/scratch2/BMC/gsd-fv3-dev/lzhang/Rocky8/global-workflow
STMP=/scratch1/NCEPDEV/stmp2/$USER/RUNDIRS
IDATE=2016080100
EDATE=2016080100
APP=ATM
PSLOT=AHR3_C384_CCPP
RES=384
GFS_CYC=1
START=cold
COMROT=/scratch2/NCEPDEV/naqfc/Kate.Zhang/fv3gfs/comrot
EXPDIR=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/global/$USER/fv3gfs/expdir
ICSDIR=$COMROT/$PSLOT


#./setup_expt.py gfs forecast-only --idate $IDATE --edate $EDATE --app $APP --gfs_cyc $GFS_CYC --resdetatmos $RES --pslot $PSLOT --comroot $COMROT --expdir $EXPDIR 

./setup_expt.py gfs forecast-only --app $APP --pslot $PSLOT --idate $IDATE --edate $EDATE --resdetatmos $RES --gfs_cyc $GFS_CYC --comroot $COMROT --expdir $EXPDIR 


./setup_xml.py $EXPDIR/$PSLOT

