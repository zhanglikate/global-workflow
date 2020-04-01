#!/bin/ksh
set -x

###################################################
# Fanglin Yang, 20180318
# --create bunches of files to be archived to HPSS
# -- modified by Judy Henderson for GMTB test
###################################################

CDATE=${CDATE:-2018010100}
PDY=$(echo $CDATE | cut -c 1-8)
cyc=$(echo $CDATE | cut -c 9-10)

rm -f gfs_trk.txt
touch gfs_trk.txt

dirpath="gfs.${PDY}/${cyc}/"
dirname="./${dirpath}"
echo  "${dirname}avno.t${cyc}z.cyclone.trackatcfunix     " >>gfs_trk.txt
echo  "${dirname}avnop.t${cyc}z.cyclone.trackatcfunix    " >>gfs_trk.txt
