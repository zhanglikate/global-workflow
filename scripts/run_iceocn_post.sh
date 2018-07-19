#!/bin/sh
set -euxa

ulimit -s unlimited
ulimit -c unlimited

export NPROC=$NPROC_ICEOCN_POST

if [[ $MACHINE == "wcoss" ]]; then
  source /usrx/local/Modules/default/init/sh
  module unload ics
  module load ics/12.1

  module unload ncarg
  module use -a /nems/save/Patrick.Tripp/modulefiles
  module load ncarg/v6.4.0

  module unload ESMF
  module load ESMF/630rp1

  export exec=$BASE_SRC/exec
  export mppnccombine=${mppnccombine:-$exec/cfs_mppnccombine}
  export iceocnpostdir=${iceocnpostdir:-/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost}
  export execdir=${execdir:-/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost/exec}
  export MPMDRUN="$MPIRUN -pgmmodel mpmd -cmdfile cmdfile -stdoutmode ordered"
  export MPIRUN=$MPIRUN

  # The folling is added for MOM6 support - is in user.config.in now
  # export OCNFIXDIR=/nems/noscrub/Patrick.Tripp/FIXDIR/ocnfix

elif [[ $MACHINE == "wcoss.cray" ]]; then
  source /opt/modules/default/init/sh
  #module swap craype-sandbridge craype-haswell
  module swap craype-haswell craype-sandbridge 
  module load cfp-intel-sandybridge
  export exec=$BASE_SRC/exec
  export mppnccombine=${mppnccombine:-$BASE_SRC/MOM5/bin/mppnccombine.wcoss_cray}
  export iceocnpostdir=${iceocnpostdir:-/gpfs/hps3/emc/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost}
  export execdir=${execdir:-/gpfs/hps3/emc/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost/exec}
  export MPMDRUN="$MPIRUN -n$NPROC -N$TPN -d 1 cfp cmdfile"
  export MPIRUN="$MPIRUN -n$NPROC -N$TPN"
  
elif [[ $MACHINE == "theia" ]]; then
  source /usr/Modules/3.2.10/init/bash
  export exec=$BASE_SRC/exec
  export mppnccombine=${mppnccombine:-$exec/cfs_mppnccombine}
  export iceocnpostdir=${iceocnpostdir:-/scratch3/NCEPDEV/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost}
  export execdir=${execdir:-/scratch3/NCEPDEV/climate/save/Xingren.Wu/svn/sis2/trunk/iceocnpost/exec}
  export NPROC=1   # Need to debug why it spawns too many processes for MPMD
  export MPMDRUN="$MPIRUN -np $NPROC -ordered-output -configfile cmdfile"
  export MPIRUN="$MPIRUN -np $NPROC_ICEOCN_POST"
else
  echo "UNKNOWN MACHINE ID. STOP."
  exit 99
fi

#  --------------------------------------
#  setup parameters for ocn post run
#  --------------------------------------

export ENSMEM=${ENSMEM:-01}

export fhr0=$fhr
export FHINI=$fhr
export FHMAX=$fhr

export FCST_LAUNCHER=${MPIRUN}
export OMP_NUM_THREADS=$NTHREADS

#  --------------------------------------
#  cp cice data with COMOUT directory
#  --------------------------------------

cd $RUNDIR

YYYY0=`echo $IDATE | cut -c1-4`
MM0=`echo $IDATE | cut -c5-6`
DD0=`echo $IDATE | cut -c7-8`
HH0=`echo $IDATE | cut -c9-10`
SS0=$((10#$HH0*3600))

VDATE=$($NDATE $fhr $IDATE)
YYYY=`echo $VDATE | cut -c1-4`
MM=`echo $VDATE | cut -c5-6`
DD=`echo $VDATE | cut -c7-8`
HH=`echo $VDATE | cut -c9-10`
SS=$((10#$HH*3600))

DDATE=$($NDATE -$FHOUT $VDATE)

if [[ 10#$fhr -eq 0 ]]; then
  cp -p history/iceh_ic.${YYYY0}-${MM0}-${DD0}-`printf "%5.5d" ${SS0}`.nc $COMOUT/iceic$VDATE.$ENSMEM.$IDATE.nc
  echo "fhr is 0, only copying ice initial conditions... exiting"
  exit 0 # only copy ice initial conditions.
else
  cp -p history/iceh_`printf "%0.2d" $FHOUT`h.${YYYY}-${MM}-${DD}-`printf "%5.5d" ${SS}`.nc $COMOUT/ice$VDATE.$ENSMEM.$IDATE.nc
fi

hh_inc_m=$((10#$FHOUT/2))
hh_inc_o=$((10#$FHOUT  ))

# ------------------------------------------------------
#  adjust the dates on the mom filenames and save
# ------------------------------------------------------

m_date=$($NDATE $hh_inc_m $DDATE)
p_date=$($NDATE $hh_inc_o $DDATE)

set +x
until [ $p_date -gt $VDATE ] ; do
   year=`echo $m_date | cut -c1-4`
  month=`echo $m_date | cut -c5-6`
    day=`echo $m_date | cut -c7-8`
     hh=`echo $m_date | cut -c9-10`

  export ocnfile=ocn_${year}_${month}_${day}_${hh}.nc

   year=`echo $p_date | cut -c1-4`
  month=`echo $p_date | cut -c5-6`
    day=`echo $p_date | cut -c7-8`
     hh=`echo $p_date | cut -c9-10`

  echo "cp -p $ocnfile $COMOUT/ocn$p_date.$ENSMEM.$IDATE.nc"
  cp -p $ocnfile $COMOUT/ocn$p_date.$ENSMEM.$IDATE.nc

  m_date=$($NDATE $hh_inc_o $m_date)
  p_date=$($NDATE $hh_inc_o $p_date)
done
set -x


#  --------------------------
#  make the ocn grib files 
#  --------------------------

export jlogfile=jlogfile
export DATA=$COMOUT/DATApost.ocnice.$fhr
rm -rf $DATA
mkdir -p $DATA
cd $DATA

#  Regrid the MOM6 files

export CDATE=$VDATE

# Regrid the MOM6 and CICE5 output from tripolar to regular grid via NCL
# This can take .25 degree input and convert to .5 degree - other opts avail

export MOM6REGRID=$BASE_SRC/post/mom6_regrid
$MOM6REGRID/run_regrid.sh
errval=$?


# Convert the .nc files to grib2
export executable=$MOM6REGRID/exec/reg2grb2.x
$MOM6REGRID/run_reg2grb2.sh
errval=$?

mv ocnr$CDATE.$ENSMEM.${IDATE}_0p5x0p5_MOM6.grb2 $COMOUT/ocnh$CDATE.$ENSMEM.${IDATE}.grb2

# clean up working folder
rm -rf $DATA
exit 0
