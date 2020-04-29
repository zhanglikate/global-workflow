#!/bin/ksh -l

# Set up paths to shell commands
RM=/bin/rm
MKDIR=/bin/mkdir
module load intel
module load szip
module load hdf5
module load wgrib2
module load netcdf

export WGRIB2=$(which wgrib2)

# Print out value of required environment variables
echo
echo "FV3GFS_HOME      = ${FV3GFS_HOME}"
echo "FV3GFS_WFM      = ${FV3GFS_WFM}"
echo "FV3GFS_LOG      = ${FV3GFS_LOG}"
echo "FV3GFS_RUN      = ${FV3GFS_RUN}"
echo "FV3GFS_SURFACE = ${FV3GFS_SURFACE}"
echo "SCRIPTS_DIR   = ${SCRIPTS_DIR}"
echo "yyjjjhh        = ${yyjjjhh}"
echo "FILENAME      = ${FILENAME}"
echo "WORK_DIR      = ${WORK_DIR}"
echo "MODEL         = ${MODEL}"
echo "DBI_USER = ${DBI_USER}"
echo "DBI_PASS = ${DBI_PASS}"
echo "DBI_DSN_MADIS = ${DBI_DSN_MADIS}"
echo "DBI_DSN_SURFACE = ${DBI_DSN_SURFACE}"
echo "FILENAME        = ${FILENAME}"
echo

${MKDIR} -p -m 777 ${WORK_DIR}
#cd ${workdir}

# Run the Perl script that does the verification
#./retro.pl FV3GFSRETRO_r4720 1381104000 1381104000
#${SCRIPTS_DIR}/surface.pl $MODEL $yyjjjhh $yyjjjhh

#echo "/home/rtfim/surface_verif/surface.pl $MODEL $yyjjjhh $yyjjjhh"
#/home/rtfim/surface_verif/surface.pl $MODEL $yyjjjhh $yyjjjhh

#${SCRIPTS_DIR}/surface.pl $MODEL $yyjjjhh $yyjjjhh

echo "${SCRIPTS_DIR}/surface.pl  $MODEL $yyjjjhh $yyjjjhh $SCRIPTS_DIR $FV3GFS_LOG $FV3GFS_RUN $FV3GFS_SURFACE $PSLOT $CDUMP"

${SCRIPTS_DIR}/surface.pl  $MODEL $yyjjjhh $yyjjjhh $SCRIPTS_DIR $FV3GFS_LOG $FV3GFS_RUN $FV3GFS_SURFACE $PSLOT $CDUMP
exit $?
