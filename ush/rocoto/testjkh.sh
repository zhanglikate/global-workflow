USER=Judy.K.Henderson
PTMP=/scratch1/BMC/gmtb/NCEPDEV/stmp2/$USER               ## default PTMP directory
STMP=/scratch1/BMC/gmtb/NCEPDEV/stmp4/$USER               ## default STMP directory
GITDIR=/scratch1/BMC/gmtb/$USER/dtc_aop_2019/gmtb_v16beta ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                  ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                  ## default EXPDIR directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS

PSLOT=testjkh
IDATE=2019101712
EDATE=2019101712
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 1 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR


#for running chgres, forecast, and post 
./setup_workflow_fcstonly_wave.py --expdir $EXPDIR/$PSLOT
