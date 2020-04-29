#!/bin/ksh -l

# Set the SGE queueing options
#$ -S /bin/ksh
#$ -pe comp 1
#$ -l h_rt=00:30:00
#$ -N GFSfile
#$ -j y
#$ -V

# Set up paths to shell commands
RM=/bin/rm
MKDIR=/bin/mkdir
GUNZIP=/bin/gunzip
GTAR=/bin/gtar
TAR=/bin/tar
CP=/bin/cp
LN=/bin/ln
HSI=/apps/hpss/hsi

# . ${FIM_HOME}/FIMrun/functions.ksh # Most function definitions can be found here.
# load_modules

# Print out value of required environment variables
echo
echo "GLOBAL_RUN     = ${GLOBAL_RUN}"
echo "CNVGRIB      = ${CNVGRIB}"
echo "yyyymmddhhmm = ${yyyymmddhhmm}"
echo "ANX_MODEL    = ${ANX_MODEL}"
echo "HPSS_DIR    = ${HPSS_DIR}"
echo "HPSS_FILE    = ${HPSS_FILE}"
echo "GFS_VERIF_RETRO_DIR    = ${GFS_VERIF_RETRO_DIR}"
echo

yyyymmddhhmm=${yyyymmddhhmm}

yr=$(expr substr $yyyymmddhhmm 1 4)
mm=$(expr substr $yyyymmddhhmm 5 2)
dd=$(expr substr $yyyymmddhhmm 7 2)
hh=$(expr substr $yyyymmddhhmm 9 2)

# Set up a work directory and cd into it
workDir=${GLOBAL_RUN}/gfs.${yr}${mm}${dd}/${hh}/verif/${ANX_MODEL}
# ${RM} -rf ${workDir}
${MKDIR} -p ${workDir}
cd ${workDir}

echo `pwd`

fileYYMMDDHH=`date +%Y%m%d%H -u -d "$mm/$dd/$yr $hh:00" `
fileYYJDYHR=`date +%y%j%H -u -d "$mm/$dd/$yr $hh:00" `
fileDateInSeconds=`date +%s -u -d "$mm/$dd/$yr $hh:00" `

# Grab file from mass store if not available on-line
if [[ ! -s "${GFS_VERIF_RETRO_DIR}/${fileYYJDYHR}000000" ]] ; then
  cmd="${HSI} get ${HPSS_DIR}/${HPSS_FILE}"
  echo "${cmd}"
  ${cmd}
  
  cmd="unzip -o ${HPSS_FILE}"
  echo "${cmd}"
  ${cmd}
else
  cmd="${LN} -fs ${GFS_VERIF_RETRO_DIR}/${fileYYJDYHR}000000"
  echo "${cmd}"
  ${cmd}
fi

#JKHoutName="${workDir}/${fileYYJDYHR}000000.grib1"
#JKH# call will return 0 or 1
#JKHgrib1size=`ls -l ${outName} 2>/dev/null | wc -l`
#JKHecho outName: ${outName} grib1size: ${grib1size}
#JKHif [ ${grib1size} -eq 1 ] ; then
#JKH  exit;
#JKHfi
#JKH
#JKHanxDir="${ANX_DIR}"
#JKHfName=${fileYYJDYHR}000000
#JKHfile=${fName}.grib1
#JKHif [[ ! -s "${workDir}/${file}" ]] ; then
#JKH        cmd="${CNVGRIB} -g21 ${workDir}/${fName} ${workDir}/${file} "
#JKH        echo "CNVGRIBCMD: ${cmd}"
#JKH        ${cmd}
#JKHelse
#JKH  exit 1;
#JKHfi
exit $?

