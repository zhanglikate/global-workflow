#!/bin/bash

module load newdefaults  intel/15.0.2.164  mvapich2/1.8
#module load nco/4.1.0
#module load cdo/1.6.7
module load ncl/6.5.0
module load contrib
module load anaconda/2.0.1
module load szip hdf5 netcdf4/4.2.1.1
module load udunits/2.1.24
module load esmf/7.0.0
export NETCDF=$NETCDF4
export LD_PRELOAD=$PWD/thirdparty/lib/libjpeg.so
export PATH=$PWD/thirdparty/bin:$PATH
export LD_LIBRARY_PATH=$PWD/thirdparty/lib:$PWD/thirdparty/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=$PWD/thirdparty/lib/python2.7/site-packages:$PYTHONPATH

