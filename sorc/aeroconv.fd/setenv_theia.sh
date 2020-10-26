#!/bin/bash

module load intel/18.0.1.163
module load intelpython/2.7.14
module load nco/4.7.0
module load cdo/1.7.2
module load ncl/6.3.0
export LD_PRELOAD=$PWD/thirdparty/lib/libjpeg.so
export PYTHONPATH=$PWD/thirdparty/lib/python2.7/site-packages:$PYTHONPATH

