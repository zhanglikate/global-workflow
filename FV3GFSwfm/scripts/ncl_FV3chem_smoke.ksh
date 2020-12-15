#!/bin/ksh --login
#
# variables sent via xml

echo "entering ncl_FV3chem_smoke.ksh...."
echo "FIXfv3=$FIXfv3"
echo "CASE=$CASE"

# initialize
module load intel
module load ncl
module load imagemagick

# Make sure we are using GMT time zone for time computations
# export DATAROOT="/scratch2/BMC/public/data/grids/sdsu/emissions/"  # for testing
# export START_TIME=20200114  # for testing
# export FCST_TIME=00  # for testing
export DATAHOME="${DATAROOT}/"  # for testing
export TZ="GMT"
export NCL_HOME="/home/rtrr/HRRR_smoke/bin/NCL/ncl"
export UDUNITS2_XML_PATH=$NCARG_ROOT/lib/ncarg/udunits/udunits2.xml
export MAGICK_THREAD_LIMIT=1
export FIXfv3=${FIXfv3}
export CASE=${CASE}

# Set up paths to shell commands
LS=/bin/ls
LN=/bin/ln
RM=/bin/rm
MKDIR=/bin/mkdir
CP=/bin/cp
MV=/bin/mv
ECHO=/bin/echo
CAT=/bin/cat
GREP=/bin/grep
CUT=/bin/cut
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date
BC=/usr/bin/bc
XARGS=${XARGS:-/usr/bin/xargs}
BASH=${BASH:-/bin/bash}
NCL=`which ncl`
CTRANS=`which ctrans`
PS2PDF=/usr/bin/ps2pdf
CONVERT=`which convert`
${ECHO} "convert is ${CONVERT}"
MONTAGE=`which montage`
# CONVERT=/home/Mike.Page/ImageMagick-7.0.5-10/bin/convert
# MONTAGE=/home/Mike.Page/ImageMagick-7.0.5-10/bin/montage
PATH=${NCARG_ROOT}/bin:${PATH}

#ulimit -s 5120000

#JKHNCL_ROOT=${FV3GFS_HOME}/FV3GFSwfm/ncl/

# Print run parameters
${ECHO}
${ECHO} "ncl_FV3chem_smoke.ksh started at `${DATE}`"
${ECHO}
${ECHO} "     DATAROOT = ${DATAROOT}"
${ECHO} "     NCL_ROOT = ${NCL_ROOT}"

# Check to make sure the NCL_ROOT var was specified
if [ ! -d ${NCL_ROOT} ]; then
  ${ECHO} "ERROR: NCL_ROOT, '${NCL_ROOT}', does not exist"
  exit 1
fi

# Print out times
# ${ECHO} "   START TIME = "`${DATE} +%Y%m%d%H -d "${START_TIME}"`
${ECHO} "   START_TIME = ${START_TIME}"
${ECHO} "   FCST_TIME = ${FCST_TIME}"

# Set up the work directory and cd into it
workdir=${OUTPUT_ROOT}/${START_TIME}/nclprd/${FCST_TIME}   # for testing
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
cd ${workdir}
pwd

# Link to input file
${ECHO} "${START_TIME}" > start_time.txt
ls -al

ncl_error=0

# Run the NCL scripts for each plot

${ECHO} "Starting plot_GB_${CASE}.ncl at `${DATE}`"
${NCL} < ${NCL_ROOT}/plot_GB_${CASE}.ncl
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: plot_GB_${CASE}.ncl crashed!  Exit status=${error}"
  ncl_error=${error}
fi
${ECHO} "Finished plot_GB_${CASE}.ncl at `${DATE}`"

${ECHO} "Starting plot_GB_OC_${CASE}.ncl at `${DATE}`"
${NCL} < ${NCL_ROOT}/plot_GB_OC_${CASE}.ncl
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: plot_GB_OC_${CASE}.ncl crashed!  Exit status=${error}"
  ncl_error=${error}
fi
${ECHO} "Finished plot_GB_OC_${CASE}.ncl at `${DATE}`"

# Copy png files to their proper names
i=0
#
OUTPUT_DIR=${OUTPUT_ROOT}/gfs.${START_TIME}/00/ncl/fim
pngfile=mfrp_sfc_f000.png
${CONVERT} -trim ${pngfile} ${pngfile}
${CONVERT} -colors 255 -border 25 -bordercolor white ${pngfile} ${pngfile}
fulldir=${OUTPUT_DIR}
${MKDIR} -p ${fulldir}
webfile=${fulldir}/${pngfile}
echo "moving ${pngfile} to ${webfile}"
${MV} ${pngfile} ${webfile}
pngfile=ocemi_sfc_f000.png
${CONVERT} -trim ${pngfile} ${pngfile}
${CONVERT} -colors 255 -border 25 -bordercolor white ${pngfile} ${pngfile}
# fulldir=${OUTPUT_DIR}
# ${MKDIR} -p ${fulldir}
webfile=${fulldir}/${pngfile}
echo "moving ${pngfile} to ${webfile}"
${MV} ${pngfile} ${webfile}

# Remove the workdir
${RM} -rf ${workdir}

${ECHO} "ncl_FV3chem_smoke.ksh completed at `${DATE}`"

exit ${ncl_error}
