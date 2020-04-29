#!/bin/ksh --login

## this script submit ncl jobs for each domain listed in GRID_NAMES 
##
##   J. Henderson    07/2014
##   J. Henderson    03/2018 - modified for FV3

# Print out value of required environment variables
date
echo "FV3GFS_HOME      = ${FV3GFS_HOME}"
echo "FV3GFS_RUN       = ${FV3GFS_RUN}"
echo "SCRIPTS          = ${SCRIPTS}"
echo "PSLOT            = ${PSLOT}"
echo "ATCFNAME         = ${ATCFNAME}"
echo "yyyymmdd         = ${yyyymmdd}"
echo "H                = ${H}"
echo "yyjjjhhmm        = ${yyjjjhhmm}"
echo "T                = ${T}"
echo "FCST_TIME        = ${FCST_TIME}"
echo "FCST_LENGTH      = ${FCST_LENGTH}"
echo "CDUMP            = ${CDUMP}"
echo "RES              = ${RES}"
echo "GRID_NAMES       = ${GRID_NAMES}"
echo "NCL_HOME         = ${NCL_HOME}"
echo "MODL             = ${MODL}"

# initialize
LOGDIR=${FV3GFS_HOME}/FV3GFSwfm/log_${PSLOT}/ncl/

# make post directory if doesn't exist
postDir=${FV3GFS_RUN}/post/fim
echo "postDir:  $postDir"
if [ ! -d ${postDir} ]
then
  echo "creating ${postDir} "
  mkdir -p ${postDir}
fi

#parse out domains
for domain in $(echo $GRID_NAMES | tr "D" " ")
do
  date
  export GRID_NAME=$domain 
  echo "in nclfv3_driver, FCST_LENGTH = ${FCST_LENGTH}"
  echo "$jobs: Running ncl: $T:$GRID_NAME"
  ${SCRIPTS}/batchTemplate-ncl-FV3 >> ${LOGDIR}/ncl_${GRID_NAME}_${T}_${yyyymmdd}${hh}00.log 2>&1 
  date
  status=$?
  if [ ${status} -ne 0 ]; then
    echo "ncl for ${GRID_NAME} failed!  Exit status=${status}"
    echo "See log at  ${LOGDIR}/ncl_${GRID_NAME}_${T}_${yyyymmdd}${hh}00.log "
    return ${status}
  fi
done
