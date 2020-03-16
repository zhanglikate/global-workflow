#!/bin/ksh -x

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

## JKH
##module unload hdf5/1.10.5
##module unload esmf/8.0.0bs48

##module use -a /scratch1/BMC/gmtb/software/modulefiles/intel-18.0.5.274/impi-2018.0.4
##module load NCEPlibs/1.0.0beta02

###############################################################
# Execute the JJOB
$HOMEgfs/jobs/JGLOBAL_FORECAST
status=$?
exit $status
