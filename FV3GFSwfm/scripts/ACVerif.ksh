#!/bin/ksh -l 

# Set the SGE queueing options
#$ -S /bin/ksh
#$ -pe comp 1
#$ -l h_rt=00:20:00
#$ -N ACVerif
#$ -j y
#$ -V

module load intel
module use ${MET_MODULE}
module load ${MET_VERSION}

# Print out value of required environment variables
echo
echo "GLOBAL_HOME     = ${GLOBAL_HOME}"
echo "GLOBAL_RUN     = ${GLOBAL_RUN}"
echo "GLOBAL_POST_DIR     = ${GLOBAL_POST_DIR}"
echo "GLOBAL_TYPE     = ${GLOBAL_TYPE}"
echo "yyyymmddhhmm = ${yyyymmddhhmm}"
echo "MODEL        = ${MODEL}"
echo "ANX_VERIF_DIR     = ${ANX_VERIF_DIR}"
echo "VARIABLES =         ${VARIABLES}";
echo "LEVELS =         ${LEVELS}";
echo "DBI_USER =         ${DBI_USER}";
echo "DBI_PASS =         ${DBI_PASS}";
echo "CLIMATE_FILE =         ${CLIMATE_FILE}";
echo "SCRIPTS =        ${SCRIPTS}";
echo "CFG_FILE           = ${CFG_FILE}";
echo "LOG_DIR            = ${LOG_DIR}";
echo

# Set up paths to shell commands
RM=/bin/rm
MKDIR=/bin/mkdir
GUNZIP=/bin/gunzip
GTAR=/bin/gtar
TAR=/bin/tar
CP=/bin/cp
LN=/bin/ln

yr=$(expr substr $yyyymmddhhmm 1 4)
mm=$(expr substr $yyyymmddhhmm 5 2)
dd=$(expr substr $yyyymmddhhmm 7 2)
hh=$(expr substr $yyyymmddhhmm 9 2)

# Set up a work directory and cd into it
if [ "$GLOBAL_TYPE" = FV3 ]; then
   workDir=${GLOBAL_RUN}/gfs.${yr}${mm}${dd}/${hh}/verif
   verifDir=${GLOBAL_RUN}/gfs.${yr}${mm}${dd}/${hh}/verif/stats
else
   workDir=${GLOBAL_RUN}/${yyyymmddhhmm}/verif
   verifDir=${GLOBAL_RUN}/${yyyymmddhhmm}/verif/stats
fi
# ${RM} -rf ${workDir}
${MKDIR} -p ${workDir}
${MKDIR} -p ${verifDir}

##JKHfcstsArr="000 012 024 036 048 060 072 084 096 108 120 "
fcstsArr="000 012 024 036 048 060 072 084 096 108 120 132 144 156 168 180 192 204 216 228 240"

# make sure post directory exists and links to run directory exist
if [ "$GLOBAL_TYPE" = FV3 ] ; then
   runDir=${GLOBAL_RUN}/gfs.${yr}${mm}${dd}/${hh}
   postDir=${runDir}/${GLOBAL_POST_DIR}
   if [ ! -d ${postDir} ] ; then
     echo "creating ${postDir}" 
     mkdir -p ${postDir}
   fi
   cd ${postDir}
   for fcst in $fcstsArr ; do
     g2Name=${runDir}/gfs.t${hh}z.pgrb2.0p50.f${fcst}
     yyddd=`date +%y%j -u -d ${yr}${mm}${dd}`
     fName=${yyddd}${hh}000${fcst}.g2
     if [ ! -f ${fName} ] ; then
       echo creating link for ${postDir}/$fcst...
       ln -s $g2Name $fName
     fi
   done
fi

createGlobalFileNames()
{
yyyymmddhhmm=${yyyymmddhhmm}

yr=$(expr substr $yyyymmddhhmm 1 4)
mm=$(expr substr $yyyymmddhhmm 5 2)
dd=$(expr substr $yyyymmddhhmm 7 2)
hh=$(expr substr $yyyymmddhhmm 9 2)
echo in createGlobalFileNames yyyymmddhhmm: $yyyymmddhhmm

fileNames=""
now=`date +%s`

anx_time=`date +%y%j%H -u -d "$mm/$dd/$yr $hh:00 000 hours ago" `
anxFileName=${ANX_VERIF_DIR}/${anx_time}000000
echo SETTING anxFileName $anxFileName

for fcst in $fcstsArr ; do
    echo IN LOOP FCST $fcst
    dirDate=`date +%Y%m%d%H -u -d "$mm/$dd/$yr $hh:00 $fcst hours ago" `
    dateInSeconds=`date +%s -u -d "$mm/$dd/$yr $hh:00 $fcst hours ago" `
    diff=$(($now - $dateInSeconds))
    year=$(expr substr ${dirDate} 1 4)
    month=$(expr substr ${dirDate} 5 2)
    day=$(expr substr ${dirDate} 7 2)
    hour=$(expr substr ${dirDate} 9 2)
    if [ "$GLOBAL_TYPE" = EXP ]; then
       dataDir=${GLOBAL_RUN}/${dirDate}/${GLOBAL_POST_DIR}
    elif [ "$GLOBAL_TYPE" = OPS ]; then
       dataDir="${GLOBAL_DATA_DIR}"
    elif [ "$GLOBAL_TYPE" = FV3 ]; then
       dataDir=${GLOBAL_RUN}/gfs.${year}${month}${day}/${hour}/${GLOBAL_POST_DIR}
    else
       echo "ERROR: GLOBAL_TYPE not properly set! Exiting"
       exit
    fi
    name=`date +%y%j%H -u -d "$mm/$dd/$yr $hh:00 ${fcst} hours ago" `
    if [ "$GLOBAL_TYPE" = FV3 ]; then
       fName=${name}000${fcst}.g2
    else
       fName=${name}000${fcst}
    fi
    file=${workDir}/${fName}

    echo "${LN} -s ${dataDir}/${fName} ${file}"
    ${LN} -sf ${dataDir}/${fName} ${file}

    echo IN LOOP ${file}
    #len=`printf $fileNames | wc -c`
    len=`echo $fileNames | wc -c`
    if [ ${len} -gt 5 ] ; then
       fileNames=$fileNames" "$file
    else
       fileNames=$file
    fi
    
done
}

createGlobalFileNames
echo fileNames: $fileNames

# validTime=`date +%Y-%m-%d -u -d "$mm/$dd/$yr $hh:00"`
validTime=$(expr substr $yyyymmddhhmm 1 8)
validHour=$(expr substr $yyyymmddhhmm 9 2)

echo validHour $validHour
echo "after call"
echo IN MAIN fileNames:  ${fileNames}

export MODEL_FILE_NAMES=${fileNames}
export VALID_TIME=${validTime}
export VALID_HOUR=${validHour}
export ANX_FILE_NAME=${anxFileName}
export ANX_DIR=${workDir}

logfile=${LOG_DIR}/anomalycorr.${validTime}${validHour}_${MODEL}.log

export MASKS=${SCRIPTS}/masks_G2_box
export CLIMO_MEAN_FILE=${CLIMATE_FILE}
export MET_MODEL=${MODEL}

# Run MET for each file in order to get verification output
for file in ${fileNames}
do
  echo "fcst file: $file"
  echo "analysis file: ${anxFileName}"
  echo "cfg file: ${CFG_FILE}"
  echo "outdir: ${verifDir}"
  echo "logfile: ${logfile}"
  echo "grid_stat $file ${anxFileName} ${CFG_FILE} -v 2 -outdir ${verifDir} -log $logfile"
  grid_stat \
     $file \
     ${anxFileName} \
     ${CFG_FILE} -v 2 \
     -outdir ${verifDir} \
     -log $logfile

done

loadStatFiles()
{
yyyymmddhhmm=${yyyymmddhhmm}

yr=$(expr substr $yyyymmddhhmm 1 4)
mm=$(expr substr $yyyymmddhhmm 5 2)
dd=$(expr substr $yyyymmddhhmm 7 2)
hh=$(expr substr $yyyymmddhhmm 9 2)
echo in loadStatFiles yyyymmddhhmm: $yyyymmddhhmm


fileNames=""
now=`date +%s`
for fcst in $fcstsArr ; do
    echo IN LOOP FCST $fcst
    if [ $fcst -ne 000 ] ; then
      fh=$((10#$fcst))
    else
      fh=00
    fi
    statFileName=${verifDir}/grid_stat_${MODEL}_${fh}0000L_${yr}${mm}${dd}_${hh}0000V_cnt.txt
    
    echo "stat file for $fcst : ${statFileName}"

    export STAT_FILE=${statFileName}    
    export STATISTIC="ANOM_CORR"    
    export FCST_LEN=$fh    
 
    ${SCRIPTS}/pop_ac_tables.py
done
}

loadStatFiles

exit 0

