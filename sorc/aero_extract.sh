#!/bin/sh

##
## this script creates the INPUT and thirdparty sub-directories
##    ./aero_extract.sh 
##

if [[ -d /scratch2 ]] ; then
  machine=hera
elif [[ -d /lfs4 ]] ; then
  machine=jet
else
  echo "Can't run on this platform!"
  exit 1
fi
cd aeroconv.fd

# thirdparty directory
echo "extracting thirdparty directory..."
tar -xvzf thirdparty_${machine}.tar.gz

# create IPUT.tar file
for file in INPUT*
do
  gunzip $file
done
touch INPUT.tar
for file in INPUT.tar.?? 
do
  cat $file >> INPUT.tar
done

# get netcdf file
echo "extracting INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc..."
tar -xvf INPUT.tar
