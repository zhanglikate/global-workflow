#!/bin/ksh -l

## this script zips all *png files in ncl/domain directories
##
##    expects these arguments
##         FV3GFS_RUN
##         yyyymmdd
##         hh
##
##   J. Henderson                   03/24/2014
##     modified for FV3             12/06/2017
##     added a1, a2 sub-domains     04/04/2018
##

# initialize
GRID_NAMES=fimD201D130D244D236D224D242Dtaiwan

# Print out value of required environment variables
echo entering fv3_nclzip.ksh...
echo "FV3GFS_RUN  = ${FV3GFS_RUN}"
echo "PSLOT       = ${PSLOT}"
echo "CDUMP       = ${CDUMP}"
echo "yyyymmdd    = ${yyyymmdd}"
echo "hh          = ${hh}"
echo "GRID_NAMES  = ${GRID_NAMES}"
echo
grids=$(echo $GRID_NAMES|sed 's/D/ /g')

# create files.zip file in each domain directory
# domains 242, 130, and 174 have other sub-domains
#     -n  no compression
for GRID_NAME in $grids
do

  echo processing ${GRID_NAME}...

  if [[ "$GRID_NAME" = "242" ]]; then
    for SUB_DIR in 242 a1 a2 
    do
      dir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${hh}/ncl/$SUB_DIR
      echo "dir is $dir" 
      if [[ -d ${dir} ]]; then
        echo "zipping  $GRID_NAME"
        cd ${dir} 
        if [ -f *.png ]; then zip -n .png files.zip * -i \*.png; fi
      else
        echo "$dir not found!"
      fi
    done
  fi

  if [[ "$GRID_NAME" = "130" ]]; then
    for SUB_DIR in 130 t1 t2 t3 t4 t5 t6 t7
    do
      dir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${hh}/ncl/$SUB_DIR
      echo "dir is $dir" 
      if [[ -d ${dir} ]]; then
        echo "zipping  $GRID_NAME"
        cd ${dir} 
        if [ -f *.png ]; then zip -n .png files.zip * -i \*.png; fi
      else
        echo "$dir not found!"
      fi
    done
  fi

  if [[ "$GRID_NAME" = "174" ]]; then
    for SUB_DIR in africa e_pacific europe floating w_pacific cambodia
    do
      dir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${hh}/ncl/$SUB_DIR
      echo "dir is $dir" 
      if [[ -d ${dir} ]]; then
        echo "zipping  $GRID_NAME"
        cd ${dir} 
        if [ -f *.png ]; then zip -n .png files.zip * -i \*.png; fi
      else
        echo "$dir not found!"
      fi
    done
  fi

  if [[ "$GRID_NAME" != "130" && "$GRID_NAME" != "174" && "$GRID_NAME" != "242" ]]; then
    dir=${FV3GFS_RUN}/${PSLOT}/${CDUMP}.${yyyymmdd}/${hh}/ncl/${GRID_NAME}
    echo "dir is $dir" 
    if [[ -d ${dir} ]]; then
      echo "zipping  $GRID_NAME"
      cd ${dir} 
      if [ -f *.png ]; then zip -n .png files.zip * -i \*.png; fi
    else
      echo "$dir not found!"
    fi
  fi

done
