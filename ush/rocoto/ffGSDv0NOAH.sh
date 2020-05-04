USER=Judy.K.Henderson
PTMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp3/$USER               ## default PTMP directory
STMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp4/$USER               ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3-dev/$USER/test/gsd-ccpp-dev         ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS

# make links for config.fcst and config.base.emc.dyn
#  comment the next 2 lines if you want to run with RUCLSM
ln -fs $GITDIR/parm/config/config.fcst_GSDsuite_noah $GITDIR/parm/config/config.fcst
ln -fs $GITDIR/parm/config/config.base.emc.dyn_GSDsuite_noah $GITDIR/parm/config/config.base.emc.dyn

# uncomment the next 2 lines if you want to run with RUCLSM
#ln -fs $GITDIR/parm/config/config.fcst_GSDsuite $GITDIR/parm/config/config.fcst
#ln -fs $GITDIR/parm/config/config.base.emc.dyn_GSDsuite $GITDIR/parm/config/config.base.emc.dyn

cp $GITDIR/parm/config/config.base.emc.dyn $GITDIR/parm/config/config.base

PSLOT=ffGSDv0_NOAH
IDATE=2019010100
EDATE=2019010100
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 1 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR


#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd_aeroic.py --expdir $EXPDIR/$PSLOT

# call jobs/rocoto/makefv3ic_link.sh for fv3ic task
sed -i "s/fv3ic.sh/makefv3ic_link.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# call jobs/rocoto/arch_gsd.sh for gfsarch task
sed -i "s/arch.sh/arch_gsd.sh/" $EXPDIR/$PSLOT/$PSLOT.xml


