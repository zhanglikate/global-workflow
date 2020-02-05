USER=$USER
PTMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp3/$USER                       ## default PTMP directory
STMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp4/$USER                       ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3-dev/$USER/test/gsd-ccpp-dev
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS
#         if different, add parameter to script setup_expt_fcstonly.py

# make links for config.fcst and config.base.emc.dyn
ln -fs $GITDIR/parm/config/config.fcst_GSDsuite_nothmp $GITDIR/parm/config/config.fcst
ln -fs $GITDIR/parm/config/config.base.emc.dyn_GSDsuite_nothmp $GITDIR/parm/config/config.base.emc.dyn

PSLOT=GSDv0_nothmp
IDATE=2020010700
EDATE=2020010700
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 1 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR


#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT

# call jobs/rocoto/makefv3ic_link.sh for fv3ic task
sed -i "s/fv3ic.sh/makefv3ic_link.sh/" $EXPDIR/$PSLOT/$PSLOT.xml

