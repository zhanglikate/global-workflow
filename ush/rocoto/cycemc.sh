USER=Judy.K.Henderson
PTMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp3/$USER               ## default PTMP directory
STMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp4/$USER               ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3-dev/$USER/test/gsd-ccpp-dev         ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS

# make links for config.fcst and config.base.emc.dyn
ln -fs $GITDIR/parm/config/config.fcst_v16beta $GITDIR/parm/config/config.fcst
ln -fs $GITDIR/parm/config/config.base.emc.dyn_v16beta  $GITDIR/parm/config/config.base.emc.dyn

cp $GITDIR/parm/config/config.base.emc.dyn $GITDIR/parm/config/config.base

PSLOT=cycemc
IDATE=2019093018
EDATE=2019100200

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

### note default RESDET=384 RESEND=192
###./setup_expt.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR [ --icsdir $ICSDIR --resdet $RESDET --resens $RESENS --nens $NENS --gfs_cyc $GFS_CYC ]
#       --icsdir $ICSDIR --idate $IDATE --edate $EDATE \

./setup_expt.py --pslot $PSLOT  \
       --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow.py --expdir $EXPDIR/$PSLOT

