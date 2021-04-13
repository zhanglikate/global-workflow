#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

if [ $target = hera ]; then target=hera.intel ; fi

cd fv3gfs.fd/
cd tests/
#JKH./compile.sh "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_v15,FV3_GSD_v0,FV3_GSD_noah,FV3_GFS_v16beta" 2 NO NO
#./compile.sh  "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_v15" 2 NO NO
#./compile.sh  "$target" "CCPP=Y 32BIT=Y STATIC=Y DEBUG=Y SUITES=FV3_GFS_v15" 2 NO NO  #minimum 
#./compile.sh "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_v15" 2 YES YES  #clean everything and recompile
#./compile.sh "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_2017_gfdlmp_gsd_chem" 2 YES YES  #clean everything and recompile
./compile.sh "$target" "CCPP=Y 32BIT=Y STATIC=Y SUITES=FV3_GFS_v15,FV3_GFS_v15_gsd_chem" 2 YES YES  #clean everything and recompile
#./compile.sh "$target" "REPRO=Y CCPP=Y STATIC=Y SUITES=FV3_GFS_v15" 2 YES YES  #clean everything and recompile (regression test way)
mv -f fv3_2.exe ../NEMS/exe/global_fv3gfs_ccpp.x
