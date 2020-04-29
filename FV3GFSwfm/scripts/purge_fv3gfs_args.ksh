#!/bin/ksh

# this file removes *nc files, *nemsio, pgrbm* files, and the RESTART directory.

dir=$1
RM=/bin/rm
RMDIR=/bin/rmdir

cd $dir
echo "** processing $dir"
echo removing sflux grib files....
$RM *sfluxgrb*
echo removing nemsio files....
$RM *.nemsio
echo removing Gaussian grid files....
$RM gfs*master*
