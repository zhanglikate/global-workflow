#!/bin/ksh -l

## this interactive script zips all *png files in ncl/domain directories
##
##    ./fv3_nclzip_args.ksh /scratch4/BMC/rtfim/rtruns/FV3GFS/FV3GFSrun/rt_fv3gfs_ff yyyymmdd  hh GRID_NAMES
##
##   J. Henderson                   03/24/2014
##     modified for FV3             11/30/2017
##     added a1, a2 sub-domains     04/04/2018
##     modified for jet             05/15/2018
##

# check for correct number of parameters
if [ $# -lt 4 ]; then
  curdir=`cd ../../FV3GFSr*/rt*emc; pwd`
  echo "Usage:  $0 $curdir yyyymmdd hh fimD201D130D244D236D224D242Dtaiwan"
  exit 1
fi

# initialize
FV3GFS_RUN=$1
yyyymmdd=$2
hh=$3
GRID_NAMES=$4
#GRID_NAMES=fimD201D130D244D236D224D242
#GRID_NAMES=fim
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
      dir=${FV3GFS_RUN}/gfs.${yyyymmdd}/${hh}/ncl/$SUB_DIR
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
      dir=${FV3GFS_RUN}/gfs.${yyyymmdd}/${hh}/ncl/$SUB_DIR
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
      dir=${FV3GFS_RUN}/gfs.${yyyymmdd}/${hh}/ncl/$SUB_DIR
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
    dir=${FV3GFS_RUN}/gfs.${yyyymmdd}/${hh}/ncl/${GRID_NAME}
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
