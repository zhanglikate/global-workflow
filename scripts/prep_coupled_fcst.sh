#!/bin/ksh
set -xa

if [ $# -ne 1 ] ; then
  echo "Usage: $0 [ cold | warm | restart ]"
  exit -1
fi

inistep=$1   # cold warm restart

# Directories
DATA=${DATA:-$pwd/fv3tmp$$}    # temporary running directory
ROTDIR=${ROTDIR:-$pwd}         # rotating archive directory
ICSDIR=${ICSDIR:-$pwd}         # cold start initial conditions

if [ ! -d $ROTDIR ]; then mkdir -p $ROTDIR; fi
if [ ! -d $DATA ]; then mkdir -p $DATA ;fi
mkdir -p $DATA/RESTART $DATA/INPUT
mkdir -p $DATA/restart $DATA/history $DATA/OUTPUT
mkdir -p $DATA/MOM6_OUTPUT $DATA/MOM6_RESTART
cd $DATA || exit 8

# Copy CICE5 IC - pre-generated from CFSv2
cp -p $ICSDIR/$CDATE/cice5_cfsv2/cice5_model_0.25.res_$CDATE.nc ./cice5_model.res_$CDATE.nc

# Copy CICE5 fixed files, and namelists
cp -p $FIXcice/kmtu_cice_NEMS_mx025.nc .
cp -p $FIXcice/grid_cice_NEMS_mx025.nc .

cd INPUT

# Copy MOM6 ICs
cp -p $ICSDIR/$CDATE/mom6_cfsv2/* .

# Copy MOM6 fixed files
cp -p $FIXmom/INPUT/* .

# Copy grid_spec and mosaic files
cp -pf $FIXgrid/$CASE/* .

#cp -p diag_table ..
#cp -p data_table ..
#cp -p MOM_input ..
#cp -p MOM_override ..
#cp -p MOM_memory.h ..
#cp -p MOM_layout ..
#cp -p MOM_saltrestore ..

cd ..

# Setup namelists

# PT DEBUG - temporarily setting this to the same as DELTIM until CICE is connected
# FAILED at C96 with DELTIM=450 and OCNTIM=1800, OCNTIM=DELTIM works, see config.fv3
export OCNTIM=${OCNTIM:-1800}
export DELTIM=${DELTIM:-1800}

# Setup nems.configure
DumpFields=${NEMSDumpFields:-false}

if [[ $inistep = "cold" ]]; then
  restart_interval=0
  coldstart=true     # this is the correct setting
else
  restart_interval=${restart_interval:-1296000}    # Interval in seconds to write restarts
  coldstart=false
fi

# Clean up un-needed files after cold start
if [[ $inistep = "warm" ]]; then
  rm -f init_field*.nc
  rm -f field_med_*.nc
  rm -f array_med_*.nc
  rm -f atmos_*.tile*.nc
fi

if [ $CASE = "C96" ] ; then
  MED_petlist_bounds=${MED_petlist_bounds:-'0 149'}
  ATM_petlist_bounds=${ATM_petlist_bounds:-'0 149'}
  OCN_petlist_bounds=${OCN_petlist_bounds:-'150 389'}
  ICE_petlist_bounds=${ICE_petlist_bounds:-'390 509'}
elif [ $CASE = "C384" ] ; then
  # This is 4x8 layout * 6 - worked
  #MED_petlist_bounds=${MED_petlist_bounds:-'0 263'}
  #ATM_petlist_bounds=${ATM_petlist_bounds:-'0 263'}    #192+wrtgrps(72)
  #OCN_petlist_bounds=${OCN_petlist_bounds:-'264 503'}  #240
  #ICE_petlist_bounds=${ICE_petlist_bounds:-'504 623'}  #120
  MED_petlist_bounds=${MED_petlist_bounds:-'0 215'}
  ATM_petlist_bounds=${ATM_petlist_bounds:-'0 215'}    #192+wrtgrps(24)
  OCN_petlist_bounds=${OCN_petlist_bounds:-'216 455'}  #240
  ICE_petlist_bounds=${ICE_petlist_bounds:-'456 479'}  #24

  # This is 6x12 layout * 6 = 432 + 72 # didn't work
  #MED_petlist_bounds=${MED_petlist_bounds:-'0 503'}
  #ATM_petlist_bounds=${ATM_petlist_bounds:-'0 503'}    #432+wrtgrps(72)
  #OCN_petlist_bounds=${OCN_petlist_bounds:-'504 743'}  #240
  #ICE_petlist_bounds=${ICE_petlist_bounds:-'744 863'}  #120
else
  echo "$CASE not supported for coupled yet"
  exit -1
fi

cat > nems.configure <<eof
#############################################
####  NEMS Run-Time Configuration File  #####
#############################################

# EARTH #
EARTH_component_list: MED ATM OCN ICE
EARTH_attributes::
  Verbosity = 0
::

# MED #
MED_model:                      nems
MED_petlist_bounds:             $MED_petlist_bounds
MED_attributes::
  Verbosity = 0
  DumpFields = $DumpFields
  DumpRHs = $DumpFields
  coldstart = $coldstart
  restart_interval = $restart_interval
::

# ATM #
ATM_model:                      fv3
ATM_petlist_bounds:             $ATM_petlist_bounds
ATM_attributes::
  Verbosity = 0
  DumpFields = $DumpFields
::

# OCN #
OCN_model:                      mom6
OCN_petlist_bounds:             $OCN_petlist_bounds
OCN_attributes::
  Verbosity = 0
  DumpFields = $DumpFields
  restart_interval = $restart_interval
::

# ICE #
ICE_model:                      cice
ICE_petlist_bounds:             $ICE_petlist_bounds
ICE_attributes::
  Verbosity = 0
  DumpFields = $DumpFields
::
eof


# Add the runsequence
if [ $inistep = "cold" ] ; then

cat >> nems.configure <<eof
# Coldstart Run Sequence #
runSeq::
  @1800.0
    @1800.0
      MED MedPhase_prep_atm
      MED -> ATM :remapMethod=redist
      ATM
      ATM -> MED :remapMethod=redist
      MED MedPhase_prep_ice
      MED -> ICE :remapMethod=redist
      ICE
      ICE -> MED :remapMethod=redist
      MED MedPhase_atm_ocn_flux
      MED MedPhase_accum_fast
    @
    MED MedPhase_prep_ocn
    MED -> OCN :remapMethod=redist
    OCN
    OCN -> MED :remapMethod=redist
  @
::
eof

else   # NOT a coldstart

cat >> nems.configure <<eof
# Forecast Run Sequence #
runSeq::
  @1800.0
    MED MedPhase_prep_ocn
    MED -> OCN :remapMethod=redist
    OCN
    @1800.0
      MED MedPhase_prep_ice
      MED MedPhase_prep_atm
      MED -> ATM :remapMethod=redist
      MED -> ICE :remapMethod=redist
      ATM
      ICE
      ATM -> MED :remapMethod=redist
      ICE -> MED :remapMethod=redist
      MED MedPhase_atm_ocn_flux
      MED MedPhase_accum_fast
    @
    OCN -> MED :remapMethod=redist
    MED MedPhase_write_restart
  @
::
eof
fi  # nems.configure

export histfreq_n=$FHOUT

# Create ice_in file

if [ $inistep = "restart" ] ; then
  runtyp=continue
  restim=.true.
else
  runtyp=initial
  restim=.false.
fi

iceic=cice5_model.res_$CDATE.nc
year=$(echo $CDATE|cut -c 1-4)
#stepsperhr=$((3600/$DELTIM))
stepsperhr=${stepsperhr:-2}
nhours=$($NHOUR $CDATE ${year}010100)
steps=$((nhours*stepsperhr))
npt=$((FHMAX*$stepsperhr))      # Need this in order for dump_last to work

histfreq_n=${histfreq_n:-6}
restart_interval=${restart_interval:-1296000}    # restart write interval in seconds, default 15 days
#dumpfreq="'s'"
dumpfreq_n=$restart_interval                     # restart write interval in seconds

#BL2018
#npt=999
dumpfreq="'y'"
histfreq_n=6
#histfreq_n=0

cat > ice_in <<eof  
&setup_nml
    days_per_year  = 365
  , use_leap_years = .true.
  , year_init      = $year
  , istep0         = $steps
  , dt             = 1800.0
  , npt            = $npt
  , ndtd           = 1
  , runtype        = '$runtyp' 
  , ice_ic         = '$iceic'
  , restart        = .true.
  , restart_ext    = .false.
  , use_restart_time = $restim
  , restart_format = 'nc'
  , lcdf64         = .false.
  , restart_dir    = './restart/'
  , restart_file   = 'iced'
  , pointer_file   = './restart/ice.restart_file'
  , dumpfreq       = d
  , dumpfreq_n     = 40
  , dump_last      = .false.
  , diagfreq       = 6
  , diag_type      = 'stdout'
  , diag_file      = 'ice_diag.d'
  , print_global   = .true.
  , print_points   = .true.
  , latpnt(1)      =  90.
  , lonpnt(1)      =   0.
  , latpnt(2)      = -65.
  , lonpnt(2)      = -45.
  , dbug           = .false.
  , histfreq       = 'm','d','h','x','x'
  , histfreq_n     =  1 , 0 , 6,  1 , 1
  , hist_avg       = .true.
  , history_dir    = './history/'
  , history_file   = 'iceh'
  , write_ic       = .true.
  , incond_dir     = './history/'
  , incond_file    = 'iceh_ic'
/

&grid_nml
    grid_format  = 'nc'
  , grid_type    = 'displaced_pole'
  , grid_file    = 'grid_cice_NEMS_mx025.nc'
  , kmt_file     = 'kmtu_cice_NEMS_mx025.nc'
  , kcatbound    = 0
/

&domain_nml
    nprocs = 24 
  , processor_shape   = 'slenderX2'
  , distribution_type = 'cartesian'
  , distribution_wght = 'latitude'
  , ew_boundary_type  = 'cyclic'
  , ns_boundary_type  = 'tripole'
  , maskhalo_dyn      = .false.
  , maskhalo_remap    = .false.
  , maskhalo_bound    = .false.
/

&tracer_nml
    tr_iage      = .true.
  , restart_age  = .false.
  , tr_FY        = .false.
  , restart_FY   = .false.
  , tr_lvl       = .true.
  , restart_lvl  = .false.
  , tr_pond_cesm = .false.
  , restart_pond_cesm = .false.
  , tr_pond_topo = .false.
  , restart_pond_topo = .false.
  , tr_pond_lvl  = .true.
  , restart_pond_lvl  = .false.
  , tr_aero      = .false.
  , restart_aero = .false.
/

&thermo_nml
    kitd              = 1
  , ktherm            = 1
  , conduct           = 'MU71'
  , a_rapid_mode      =  0.5e-3
  , Rac_rapid_mode    =    10.0
  , aspect_rapid_mode =     1.0
  , dSdt_slow_mode    = -5.0e-8
  , phi_c_slow_mode   =    0.05
  , phi_i_mushy       =    0.85
/

&dynamics_nml
    kdyn            = 1
  , ndte            = 120
  , revised_evp     = .false.
  , advection       = 'remap'
  , kstrength       = 1
  , krdg_partic     = 1
  , krdg_redist     = 1
  , mu_rdg          = 3
/

&shortwave_nml
    shortwave       = 'dEdd'
  , albedo_type     = 'default'
  , albicev         = 0.78
  , albicei         = 0.36
  , albsnowv        = 0.98
  , albsnowi        = 0.70 
  , ahmax           = 0.3
  , R_ice           = 0.
  , R_pnd           = 0.
  , R_snw           = 1.5
  , dT_mlt          = 1.5
  , rsnw_mlt        = 1500.
/

&ponds_nml
    hp1             = 0.01
  , hs0             = 0.
  , hs1             = 0.03
  , dpscale         = 1.e-3
  , frzpnd          = 'hlid'
  , snowinfil       = .true.
  , rfracmin        = 0.15
  , rfracmax        = 1.
  , pndaspect       = 0.8
/

&zbgc_nml
    tr_brine        = .false.
  , restart_hbrine  = .false.
  , skl_bgc         = .false.
  , bgc_flux_type   = 'Jin2006'
  , restart_bgc     = .false.
  , restore_bgc     = .false.
  , bgc_data_dir    = 'unknown_bgc_data_dir'
  , sil_data_type   = 'default'
  , nit_data_type   = 'default'
  , tr_bgc_C_sk     = .false.
  , tr_bgc_chl_sk   = .false.
  , tr_bgc_Am_sk    = .false.
  , tr_bgc_Sil_sk   = .false.
  , tr_bgc_DMSPp_sk = .false.
  , tr_bgc_DMSPd_sk = .false.
  , tr_bgc_DMS_sk   = .false.
  , phi_snow        = 0.5
/

&forcing_nml
    formdrag        = .false.
  , atmbndy         = 'default'
  , fyear_init      = 1997
  , ycycle          = 1
  , atm_data_format = 'bin'
  , atm_data_type   = 'none'
  , atm_data_dir    = '/home/Fei.Liu/noscrub/lanl_cice_data/'
  , calc_strair     = .true.
  , calc_Tsfc       = .true.
  , precip_units    = 'mm_per_month'
  , ustar_min       = 0.0005
  , update_ocn_f    = .false.
  , oceanmixed_ice  = .false.
  , ocn_data_format = 'bin'
  , sss_data_type   = 'default'
  , sst_data_type   = 'default'
  , ocn_data_dir    = 'unknown_ocn_data_dir'
  , oceanmixed_file = 'unknown_oceanmixed_file'
  , restore_sst     = .false.
  , trestore        =  90
  , restore_ice     = .false.
/
&icefields_nml
    f_tmask        = .true.
  , f_tarea        = .true.
  , f_uarea        = .true.
  , f_dxt          = .false.
  , f_dyt          = .false.
  , f_dxu          = .false.
  , f_dyu          = .false.
  , f_HTN          = .false.
  , f_HTE          = .false.
  , f_ANGLE        = .true.
  , f_ANGLET       = .true.
  , f_NCAT         = .true.
  , f_VGRDi        = .false.
  , f_VGRDs        = .false.
  , f_VGRDb        = .false.
  , f_bounds       = .false.
  , f_aice         = 'mdhxx' 
  , f_hi           = 'mdhxx'
  , f_hs           = 'mdhxx' 
  , f_Tsfc         = 'mdhxx' 
  , f_sice         = 'm' 
  , f_uvel         = 'mdhxx' 
  , f_vvel         = 'mdhxx' 
  , f_fswdn        = 'mdhxx' 
  , f_flwdn        = 'mdhxx'
  , f_snow         = 'x' 
  , f_snow_ai      = 'm' 
  , f_rain         = 'x' 
  , f_rain_ai      = 'm' 
  , f_sst          = 'mdhxx' 
  , f_sss          = 'mdhxx' 
  , f_uocn         = 'm' 
  , f_vocn         = 'm' 
  , f_frzmlt       = 'mdhxx'
  , f_fswfac       = 'm'
  , f_fswabs       = 'x' 
  , f_fswabs_ai    = 'm' 
  , f_albsni       = 'mdhxx' 
  , f_alvdr        = 'x'
  , f_alidr        = 'x'
  , f_albice       = 'x'
  , f_albsno       = 'x'
  , f_albpnd       = 'x'
  , f_coszen       = 'x'
  , f_flat         = 'x' 
  , f_flat_ai      = 'm' 
  , f_fsens        = 'x' 
  , f_fsens_ai     = 'm' 
  , f_flwup        = 'x' 
  , f_flwup_ai     = 'm' 
  , f_evap         = 'x' 
  , f_evap_ai      = 'm' 
  , f_Tair         = 'mdhxx' 
  , f_Tref         = 'x' 
  , f_Qref         = 'x'
  , f_congel       = 'mdhxx' 
  , f_frazil       = 'mdhxx' 
  , f_snoice       = 'mdhxx' 
  , f_dsnow        = 'x' 
  , f_melts        = 'mdhxx'
  , f_meltt        = 'mdhxx'
  , f_meltb        = 'mdhxx'
  , f_meltl        = 'mdhxx'
  , f_fresh        = 'x'
  , f_fresh_ai     = 'm'
  , f_fsalt        = 'x'
  , f_fsalt_ai     = 'm'
  , f_fhocn        = 'x' 
  , f_fhocn_ai     = 'm' 
  , f_fswthru      = 'x' 
  , f_fswthru_ai   = 'm' 
  , f_fsurf_ai     = 'x'
  , f_fcondtop_ai  = 'x'
  , f_fmeltt_ai    = 'x' 
  , f_strairx      = 'm' 
  , f_strairy      = 'm' 
  , f_strtltx      = 'x' 
  , f_strtlty      = 'x' 
  , f_strcorx      = 'x' 
  , f_strcory      = 'x' 
  , f_strocnx      = 'm' 
  , f_strocny      = 'm' 
  , f_strintx      = 'x' 
  , f_strinty      = 'x'
  , f_strength     = 'x'
  , f_divu         = 'x'
  , f_shear        = 'x'
  , f_sig1         = 'x' 
  , f_sig2         = 'x' 
  , f_dvidtt       = 'x' 
  , f_dvidtd       = 'x' 
  , f_daidtt       = 'x'
  , f_daidtd       = 'x' 
  , f_mlt_onset    = 'm'
  , f_frz_onset    = 'm'
  , f_hisnap       = 'x'
  , f_aisnap       = 'x'
  , f_trsig        = 'm'
  , f_icepresent   = 'm'
  , f_iage         = 'm'
  , f_FY           = 'x'
  , f_aicen        = 'x'
  , f_vicen        = 'x'
  , f_Tinz         = 'x'
  , f_Sinz         = 'x'
  , f_Tsnz         = 'x'
  , f_fsurfn_ai    = 'x'
  , f_fcondtopn_ai = 'x'
  , f_fmelttn_ai   = 'x'
  , f_flatn_ai     = 'x'
/

&icefields_mechred_nml
    f_alvl         = 'm'
  , f_vlvl         = 'm'
  , f_ardg         = 'm'
  , f_vrdg         = 'm'
  , f_dardg1dt     = 'x'
  , f_dardg2dt     = 'x'
  , f_dvirdgdt     = 'x'
  , f_opening      = 'x'
  , f_ardgn        = 'x'
  , f_vrdgn        = 'x'
  , f_dardg1ndt    = 'x'
  , f_dardg2ndt    = 'x'
  , f_dvirdgndt    = 'x'
  , f_krdgn        = 'x'
  , f_aparticn     = 'x'
  , f_aredistn     = 'x'
  , f_vredistn     = 'x'
  , f_araftn       = 'x'
  , f_vraftn       = 'x'
/

&icefields_pond_nml
    f_apondn       = 'x'
  , f_apeffn       = 'x'
  , f_hpondn       = 'x'
  , f_apond        = 'mdhxx'
  , f_hpond        = 'mdhxx'
  , f_ipond        = 'mdhxx'
  , f_apeff        = 'mdhxx'
  , f_apond_ai     = 'm'
  , f_hpond_ai     = 'm'
  , f_ipond_ai     = 'm'
  , f_apeff_ai     = 'm'
/

&icefields_bgc_nml
    f_faero_atm    = 'x'
  , f_faero_ocn    = 'x'
  , f_aero         = 'x'
  , f_fNO          = 'x'
  , f_fNO_ai       = 'x'
  , f_fNH          = 'x'
  , f_fNH_ai       = 'x'
  , f_fN           = 'x'
  , f_fN_ai        = 'x'
  , f_fSil         = 'x'
  , f_fSil_ai      = 'x'
  , f_bgc_N_sk     = 'x'
  , f_bgc_C_sk     = 'x'
  , f_bgc_chl_sk   = 'x'
  , f_bgc_Nit_sk   = 'x'
  , f_bgc_Am_sk    = 'x'
  , f_bgc_Sil_sk   = 'x'
  , f_bgc_DMSPp_sk = 'x'
  , f_bgc_DMSPd_sk = 'x'
  , f_bgc_DMS_sk   = 'x'
  , f_bgc_Nit_ml   = 'x'
  , f_bgc_Am_ml    = 'x'
  , f_bgc_Sil_ml   = 'x'  
  , f_bgc_DMSP_ml  = 'x'
  , f_bTin         = 'x'
  , f_bphi         = 'x' 
  , f_fbri         = 'm'    
  , f_hbri         = 'm'
  , f_grownet      = 'x'
  , f_PPnet        = 'x'
/

&icefields_drag_nml
    f_drag         = 'x'
  , f_Cdn_atm      = 'x'
  , f_Cdn_ocn      = 'x'
/
eof

#rtype=${rtype:-"n"}

# specify restart
#if [ $inistep = 'restart' ] ; then
  #rtype="r"
#fi

#cat >> input.nml <<EOF
#&nam_stochy
#  lon_s=768,
#  lat_s=384,
#  ntrunc=382,
#  SKEBNORM=1,
#  SKEB_NPASS=30,
#  SKEB_VDOF=5,
#  SKEB=-999.0,
#  SKEB_TAU=2.16E4,
#  SKEB_LSCALE=1000.E3,
#  SHUM=-999.0,
#  SHUM_TAU=21600,
#  SHUM_LSCALE=500000,
#  SPPT=-999.0,
#  SPPT_TAU=21600,
#  SPPT_LSCALE=500000,
#  SPPT_LOGIT=.TRUE.,
#  SPPT_SFCLIMIT=.TRUE.,
#  ISEED_SHUM=1,
#  ISEED_SKEB=2,
#  ISEED_SPPT=3,
#/
#EOF

# normal exit
# -----------

#exit 0

