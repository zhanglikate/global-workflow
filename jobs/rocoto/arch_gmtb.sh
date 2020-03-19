#!/bin/ksh -x

###############################################################
## Abstract:
## Archive driver script
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current analysis date (YYYYMMDDHH)
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
configs="base arch"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

###############################################################
# Archive online for verification and diagnostics
###############################################################

COMIN="$ROTDIR/$CDUMP.$PDY/$cyc"
cd $COMIN

[[ ! -d $ARCDIR ]] && mkdir -p $ARCDIR

if [ -s avno.t${cyc}z.cyclone.trackatcfunix ]; then
    PLSOT4=`echo $PSLOT|cut -c 1-4 |tr '[a-z]' '[A-Z]'`
    cat avno.t${cyc}z.cyclone.trackatcfunix | sed s:AVNO:${PLSOT4}:g  > ${ARCDIR}/atcfunix.${CDUMP}.$CDATE
    cat avnop.t${cyc}z.cyclone.trackatcfunix | sed s:AVNO:${PLSOT4}:g  > ${ARCDIR}/atcfunixp.${CDUMP}.$CDATE
fi

if [ $CDUMP = "gfs" ]; then
    $NCP storms.gfso.atcf_gen.$CDATE      ${ARCDIR}/.
    $NCP storms.gfso.atcf_gen.altg.$CDATE ${ARCDIR}/.
    $NCP trak.gfso.atcfunix.$CDATE        ${ARCDIR}/.
    $NCP trak.gfso.atcfunix.altg.$CDATE   ${ARCDIR}/.

    cp -rp tracker                        ${ARCDIR}/tracker.$CDATE
fi

###############################################################
# Archive data to HPSS
if [ $HPSSARCH = "YES" ]; then
###############################################################

  ARCH_LIST="$COMIN/archlist"
  [[ -d $ARCH_LIST ]] && rm -rf $ARCH_LIST
  mkdir -p $ARCH_LIST
  cd $ARCH_LIST
  
  $HOMEgfs/ush/hpssarch_gen_gmtb.sh $CDUMP
  status=$?
  if [ $status -ne 0  ]; then
      echo "$HOMEgfs/ush/hpssarch_gen_gmtb.sh $CDUMP failed, ABORT!"
      exit $status
  fi
  
  cd $ROTDIR
  
  htar -P -cvf $ATARDIR/$CDATE/gfs_pgrb2b.tar `cat $ARCH_LIST/gfs_pgrb2b.txt`
  status=$?
  if [ $status -ne 0  -a $CDATE -ge $firstday ]; then
    echo "HTAR $CDATE gfs_pgrb2b.tar failed"
    exit $status
  fi
    
###############################################################
fi  ##end of HPSS archive
###############################################################

exit 0
