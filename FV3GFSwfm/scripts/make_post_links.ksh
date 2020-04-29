#!/bin/ksh -l 

# check for correct number of arguments
if [ $# != 5 ]
then
  echo "creates links in post directory under gfs.YYYYMMDD/HH"
  echo "Usage:  $0 FV3GFS_RUN PSLOT YYYYMMDD HH link_GFS_anal [T,F]"
  exit 1
fi

# initialize
#FV3GFS_RUN=/scratch4/BMC/rtfim/rtruns/FV3GFS_GF/FV3GFSrun
#PSLOT=rt_fv3gfs_gf
FV3GFS_RUN=$1
PSLOT=$2
yyyymmdd=$3
validHour=$4
link_gfs_anal=$5
CDUMP=gfs
GFS_VERIF_DIR=/scratch4/BMC/public/data/grids/gfs/0p5deg/grib
GFS_VERIF_RETRO_DIR=/scratch4/BMC/fim/GFS_RETRO_VERIF_FILES
RES=0p50
CNVGRIB=/apps/cnvgrib/1.4.0/bin/cnvgrib
yydddhh=`date --date="$yyyymmdd $validHour:00" +%y%j%H`
ANX_FILE_NAME=${yydddhh}000000.grib1

echo
echo "FV3GFS_RUN         = ${FV3GFS_RUN}"
echo "GFS_VERIF_DIR      = ${GFS_VERIF_DIR}"
echo "GFS_VERIF_RETRO_DIR= ${GFS_VERIF_RETRO_DIR}"
echo "PSLOT              = ${PSLOT}"
echo "CDUMP              = ${CDUMP}"
echo "RES                = ${RES}"
echo "yyyymmdd           = ${yyyymmdd}"
echo "validHour          = ${validHour}"
echo "CNVGRIB            = ${CNVGRIB}"
echo "yyddhh             =${yydddhh}"
echo "ANX_FILE_NAME      = ${ANX_FILE_NAME}"

# make post directory if doesn't exist
outDir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${validHour}
postDir=${outDir}/post/fim
echo "outDir:  $outDir;  postDir:  $postDir"
if [ ! -d ${postDir} ]
then
  echo "creating ${postDir} " 
  mkdir -p ${postDir}
fi

cd $postDir

##replace with converting grib2 to grib1
##    cmd="${CNVGRIB} -g21  gfs.t00z.pgrb2.0p50.f006 ${yyddd}${validHour}0000${fhr}


# create links to grib1 files   (need 2 sections due to naming inconsistency!)
##     hours 00 - 96
echo creating links/files for fhr 0-96
fhrs=`seq -f %02g 0 6 96`
for fhr in $fhrs
do
  echo    fhr=$fhr
  file=${outDir}/${CDUMP}.t${validHour}z.pgrbh${fhr}   ## gfs.t12z.pgrbh06
  yyddd=`date +%y%j -u -d $yyyymmdd`
  if [[ -f $file ]]
  then
    if [[ ! -f ${yyddd}${validHour}0000${fhr} ]]; then ln -sf $file ${yyddd}${validHour}0000${fhr}; fi
  else
    if [[ ! -f ${yyddd}${validHour}0000${fhr} ]]; 
    then 
      cmd="${CNVGRIB} -g21  $outDir/gfs.t${validHour}z.pgrb2.0p50.f0${fhr} ${yyddd}${validHour}0000${fhr}"
      ${cmd}
    fi
  fi
done
##     hours 102 108 114 168
fhrs=`seq 102 6 168`
echo creating links/files for fhr 102-168
for fhr in $fhrs
do
  echo    fhr=$fhr
  file=${outDir}/${CDUMP}.t${validHour}z.pgrbh${fhr}   ## gfs.t12z.pgrbh168  (merge_update naming convention)
  yyddd=`date +%y%j -u -d $yyyymmdd`
  if [[ -f $file ]]
  then 
    if [[ ! -f ${yyddd}${validHour}000${fhr} ]]; then ln -sf $file ${yyddd}${validHour}0000${fhr}; fi
  else
    if [[ ! -f ${yyddd}${validHour}000${fhr} ]]; then 
      cmd="${CNVGRIB} -g21  $outDir/gfs.t${validHour}z.pgrb2.0p50.f${fhr} ${yyddd}${validHour}000${fhr}"
      ${cmd}
    fi
  fi
done

# create link to GFS analysis grib2 file and convert to grib1
if [ $link_gfs_anal = "T" ]
then
  echo converting GFS analysis grib2 file to grib1....

  if [[ ! -f $ANX_FILE_NAME ]]
  then
   
    echo $ANX_FILE_NAME does not exist!!
  
    # convert GFS analysis grib2 file to grib1
    g2file=`echo ${ANX_FILE_NAME} | cut -f 1 -d .`
    if [[ -f ${GFS_VERIF_DIR}/${g2file} ]]             
    then
      echo ${GFS_VERIF_DIR}/${g2file} exists!!
      yydddhh=`date --date=${yyyymmdd} +%y%j`${validHour}
      cmd="${CNVGRIB} -g21 ${GFS_VERIF_DIR}/${g2file} ${ANX_FILE_NAME} "
      echo "CNVGRIBCMD: ${cmd}"
      ${cmd}
    else
      yyyy=$(expr substr $yyyymmdd 1 4)
      echo making link to $GFS_VERIF_RETRO_DIR!!
      ln -sf ${GFS_VERIF_RETRO_DIR}_${yyyy}/GFS//${ANX_FILE_NAME}
    fi
    
  fi
fi
