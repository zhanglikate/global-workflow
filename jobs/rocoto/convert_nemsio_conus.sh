#!/bin/ksh -x

echo ROTDIR=$ROTDIR
echo CDATE=$CDATE
echo CDUMP=$CDUMP
echo PDY=$PDY
echo cyc=$cyc
echo fcst=$fcst

# load modules
. /etc/profile.d/modules.sh
module purge
module use -a /scratch1/BMC/gmtb/software/modulefiles/generic
module load intel/18.0.5.274 cdo/1.9.5 nemsio2nc4/1.0
# optional, but useful for working with the netCDF files later
module load netcdf/4.6.1 ncview/2.1.7
module load nco

# convert to netCDF
RUNDIR=$ROTDIR/$CDUMP.$PDY/$cyc
NEMSIO_FILE=${CDUMP}.t${cyc}z.atmf${fcst}.nemsio
cd $RUNDIR
echo "converting $RUNDIR/$NEMSIO_FILE....."
nemsio2nc4.py -f $NEMSIO_FILE -v
if [ -f ${NEMSIO_FILE}_select.nc4 ]; then 
  rm  ${NEMSIO_FILE}_select.nc4
fi
ncks --4 -v pressfc,hgtsfc,ugrdmidlayer,vgrdmidlayer,dpresmidlayer,tmpmidlayer,spfhmidlayer,delzmidlayer,rwmrmidlayer,icmrmidlayer -d lat,10.0,70.0 -d lon,180.0,320.0 ${NEMSIO_FILE}.nc4 ${NEMSIO_FILE}_select.nc4

# delete files
echo "removing ${NEMSIO_FILE}.nc4"
rm ${NEMSIO_FILE}.nc4
echo "removing ${NEMSIO_FILE}.ctl"
rm ${NEMSIO_FILE}.ctl
