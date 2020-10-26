#!/bin/bash

set -e

if [ $# -lt 1 ]; then
  echo "ERROR, need to specify interpolation date YYYYMMDD as first argument"
  exit 1
fi
INTDATE=$1

if [ $# -lt 2 ]; then
  echo "WARNING, no case/setup provided assuming a global run with six tiles"
  CASE=global
else
  CASE=$2
fi

if [ ! -f INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc ]; then
  echo "File INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc not found."
  echo "Go to INPUT and run 'int2nc.exe QNWFA_QNIFA_SIGMA_MONTHLY.dat'"
  exit 1
fi

rm -fr INTERMEDIATE && mkdir -p INTERMEDIATE
rm -fr OUTPUT       && mkdir -p OUTPUT

./int2nc_to_nggps_ic_step1.py

# Argument is interpolation date for Thompson aerosol climatology in format YYYYmmdd
./int2nc_to_nggps_ic_step2.py $INTDATE

# Argument is case (global, regional, nested) that determines the number/name of tiles
./int2nc_to_nggps_ic_step3.py $CASE

# Argument is case (global, regional, nested) that determines the number/name of tiles
./int2nc_to_nggps_ic_step4.py $CASE
