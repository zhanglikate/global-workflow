#!/bin/bash

module load intel/18.0.5.274
module load hdf5/1.10.5
module load netcdf/4.7.0
module load grib_api/1.26.1
module load contrib
module load anaconda/2.3.0
module load nco/4.7.0
module load ncl/6.5.0

module use -a /scratch1/BMC/gmtb/software/modulefiles/intel-18.0.5.274/impi-2018.0.4
module load cdo/1.7.2

export LD_PRELOAD=$PWD/thirdparty/lib/libjpeg.so
export PYTHONPATH=$PWD/thirdparty/lib/python2.7/site-packages:$PYTHONPATH

