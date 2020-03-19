#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  #JKHexport MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
  export MOD_PATH=/scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

if [ $target = hera ]; then target=hera.intel ; fi

cd fv3gfs_ccpp.fd/
FV3=$( pwd -P )
cd tests/
#./compile.sh "$FV3" "$target" "NCEP64LEV=Y HYDRO=N 32BIT=Y" 1 YES YES
./compile_cmake.sh "$FV3" "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_v16beta" 1 NO NO
mv -f fv3_1.exe ../NEMS/exe/global_fv3gfs_ccpp.x