# Aerosol conversion utility for Thompson microphysis

This tool provides functionality to convert the aerosol climatology used by the Thompson aerosol-aware microphysics into a format that can be read by FV3. The repository contains the Python scripts that are wrapped with the batch script int2nc\_to\_nggps\_ic\_batch.sh. This script takes one argument, namely the date to which to interpolate the monthly climatology to in format _YYYYMMDD_.

In order to run the script, certain utilities and libraries must be present on the system. On NOAA's Theia HPC, the setenv.sh script can be source to load the modules and set the paths to the libraries in the thirdparty folder.

Instructions (on Theia, analogous for Jet):

* clone this repository
* extract thirdparty_theia.tar.gz
```
tar -xvzf thirdparty_theia.tar.gz
```
* extract INPUT.tar.??.gz (provides INPUT/QNWFA\_QNIFA\_SIGMA\_MONTHLY.dat.nc)
```
for file in INPUT.tar.??.gz; do gunzip $file; done
for file in INPUT.tar.??; do cat $file >> INPUT.tar; done
tar -xvf INPUT.tar
```
* add the required input data (see below) to the folder INPUT
* source setenv_theia.sh:
```
. setenv_theia.sh
```
* run the script:
```
./int2nc_to_nggps_ic_batch.sh YYYYMMDD [CASE]
```

Arguments to `./int2nc_to_nggps_ic_batch.sh`:
* _YYYYMMDD_: date to which the aerosol climatology should be interpolated (date of the initial conditions)
* _CASE_: optional argument for the case/setup to determine the number and names of the tiles. Possible choices:
    * 'global' (default): six tiles running from tile1 to tile6
    * 'regional': one tile called tile7
    * 'nested': seven tiles running from tile1 to tile7

Required input data in INPUT directory:

* gfs\_cntrl.nc - vertical level information for GFS initial conditions
* gfs\_data.tileX.nc - GFS initial conditions for date _YYYYMMDD_
* grid\_spec.tileX.nc - lat/lon information for FV3 mesh to interpolate to
* QNWFA\_QNIFA\_SIGMA\_MONTHLY.dat.nc - this is the output of the WPS utility int2nc running over "QNWFA_QNIFA_SIGMA_MONTHLY.dat" from Greg Thompson, contained in INPUT.tar
