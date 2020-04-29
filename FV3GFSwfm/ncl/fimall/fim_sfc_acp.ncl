;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
modl = getenv("MODL")
interval = getenv("FCST_INTERVAL")
interval = 6
fcstln = getenv("FCST_LENGTH")
;
load "$NCL_HOME/obj/cmap1_track2.ncl"
;
begin
;
airport_id = asciiread("$NCL_HOME/Airports_id.txt",-1,"string")
airport_loc = asciiread("$NCL_HOME/Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
;
domainname = asciiread("domain.txt",-1,"string")
;
load "$NCL_HOME/obj/fim_grib_names.ncl"
;
isolev = 500
load "$NCL_HOME/obj/get_iso_level_indexes.ncl"
;
if (isfilevar(grb_file,TSFC)) then
  intm = grb_file->$TSFC$@initial_time
  print("intm = "+intm)
  fctm = grb_file->$TSFC$@forecast_time
  print("fctm = "+fctm)
  fctmunits = grb_file->$TSFC$@forecast_time_units
  if (fctmunits .ne. "hours") then
    fctm = fctm * tointeger(fctmunits)
  end if
else  ; for grid 129
  intm = grb_file->$TPACC$@initial_time
  fctm = grb_file->$TPACC$@forecast_time
  fctmunits = grb_file->$TPACC$@forecast_time_units
  if (fctmunits .ne. "hours") then
    fctm = fctm * tointeger(fctmunits)
  end if
end if
;
if (fctm .ge. 6) then
  back6fname = asciiread("back6_file.txt",-1,"string")
  print("back6fname is "+back6fname)
  back6_grb_file = addfile(back6fname,"r")
  if (isfilevar(back6_grb_file,TSFC)) then
    back6fctm = back6_grb_file->$TSFC$@forecast_time
    back6fctmunits = back6_grb_file->$TSFC$@forecast_time_units
    if (back6fctmunits .ne. "hours") then
      back6fctm = back6fctm * tointeger(back6fctmunits)
    end if
  else  ; for grid 129
    back6fctm = back6_grb_file->$TPACC$@forecast_time
    back6fctmunits = back6_grb_file->$TPACC$@forecast_time_units
    if (back6fctmunits .ne. "hours") then
      back6fctm = back6fctm * tointeger(back6fctmunits)
    end if
  end if
else
  exit
end if
;
if (domainname .eq. "fim") then
;
  if (modl .eq. "MPAS") then
    ny = filevardimsizes(grb_file,"g0_lat_0")
    nx = filevardimsizes(grb_file,"g0_lon_1")
;
    intm = grb_file->PRES_GDS0_SFC@initial_time
    fctm = grb_file->PRES_GDS0_SFC@forecast_time
    lat = grb_file->g0_lat_0(:)
    lon = grb_file->g0_lon_1(:)
    if ( fctm .ge. 6 ) then
      tvar = grb_file->ACPCP_GDS0_SFC(::-1,:) + grb_file->NCPCP_GDS0_SFC(::-1,:)
      back6fname = asciiread("back6_file.txt",-1,"string")
      back6_grb_file = addfile(back6fname,"r")
      back6fctm = back6_grb_file->PRES_GDS0_SFC@forecast_time
      back6tvar = back6_grb_file->ACPCP_GDS0_SFC(::-1,:) + back6_grb_file->NCPCP_GDS0_SFC(::-1,:)
      tvar = tvar - back6tvar
      tvar = tvar * 0.03937 ; convert to inches
      tvar = lonFlip(tvar)
    else
      exit
    end if
  else
    ny = filevardimsizes(grb_file,LAT)
    nx = filevardimsizes(grb_file,LON)
;
    lon = grb_file->$LON$(:)
    if (fv3) then
      lat = grb_file->$LAT$(::-1)
      if ( fctm .gt. 0 ) then
        if (isfilevar(grb_file,TPACC)) then
          zz = TPACC
        else
          zz = TPACC + fctm + "h"
        end if
        tvar = grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
      else
        exit
      end if
      if (isfilevar(back6_grb_file,TPACC)) then
        zz = TPACC
      else
        zz = TPACC + back6fctm + "h"
      end if
      if (back6fctm .eq. 0) then
        back6tvar = tvar * 0
      else
        back6tvar = back6_grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
      end if
      tvar = tvar - back6tvar
      t32 = grb_file->$T2M$(0,::-1,:) - 273.15
      t32 = t32 * 9/5 + 32 ; Convert to F
      mvar = grb_file->$MSLP$(::-1,:) / 100. ; convert from Pa to mb
      mint = 8
      mdens = 0.8
      mlinethick = 1.0
;
      h5 = grb_file->$GHISBL$(level500,::-1,:) / 10. ; use decameters
      h10 = grb_file->$GHISBL$(level1000,::-1,:) / 10. ; use decameters
      thick = h5 - h10
      thint = 6
      thdens = 0.1
      thlinethick = 1.0
    else
      lat = grb_file->$LAT$(:)
      if ( fctm .gt. 0 ) then
        if (isfilevar(grb_file,TPACC)) then
          zz = TPACC
        else
          zz = TPACC + fctm + "h"
        end if
        tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
      else
        exit
      end if
      if (isfilevar(back6_grb_file,TPACC)) then
        zz = TPACC
      else
        zz = TPACC + back6fctm + "h"
      end if
      if (back6fctm .eq. 0) then
        back6tvar = tvar * 0
      else
        back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
      end if
      tvar = tvar - back6tvar
      t32 = grb_file->$T2M$(:,:) - 273.15
      t32 = t32 * 9/5 + 32 ; Convert to F
      mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
      mint = 8
      mdens = 0.8
      mlinethick = 1.0
;
      h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
      h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
      thick = h5 - h10
      thint = 6
      thdens = 0.1
      thlinethick = 1.0
    end if
  end if
;
end if
;
if (domainname .eq. "129") then
;
  ny = filevardimsizes(grb_file,LAT)
  nx = filevardimsizes(grb_file,LON)
;
  zz = TPACC
  tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  lat = grb_file->$LAT$(:)
  lon = grb_file->$LON$(:)
  zz = TPACC
  if (back6fctm .ne. 6) then
    back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  else
    back6tvar = 0
  end if
  tvar = tvar - back6tvar
;
end if
;
if (domainname .eq. "83") then
;
  fimsizes = filevardimsizes(grb_file,LAT)
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  lat = grb_file->$LAT$(:,:)
  lon = grb_file->$LON$(:,:)
  if ( fctm .gt. 0 ) then
    if (isfilevar(grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + fctm + "h"
    end if
    tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  else
    exit
  end if
  if (isfilevar(back6_grb_file,TPACC)) then
    zz = TPACC
  else
    zz = TPACC + back6fctm + "h"
  end if
  if (back6fctm .eq. 0) then
    back6tvar = tvar * 0
  else
    back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  end if
  tvar = tvar - back6tvar
;
  if (fv3) then
    t32 = grb_file->$T2M$(0,:,:) - 273.15
  else
    t32 = grb_file->$T2M$(:,:) - 273.15
  end if
  t32 = t32 * 9/5 + 32 ; Convert to F
;
  mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
  mint = 8
  mdens = 0.8
  mlinethick = 1.0
;
  h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
  h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
  thick = h5 - h10
  thint = 6
  thdens = 0.1
  thlinethick = 1.0
;
end if
;
if (domainname .eq. "130") then
;
  fimsizes = filevardimsizes(grb_file,LAT)
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  lat = grb_file->$LAT$(:,:)
  lon = grb_file->$LON$(:,:)
  latin1 = grb_file->$LON$@Latin1
  latin2 = grb_file->$LON$@Latin2
  lov = grb_file->$LON$@Lov
  if ( fctm .gt. 0 ) then
    if (isfilevar(grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + fctm + "h"
    end if
    tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  else
    exit
  end if
  if (isfilevar(back6_grb_file,TPACC)) then
    zz = TPACC
  else
    zz = TPACC + back6fctm + "h"
  end if
  if (back6fctm .eq. 0) then
    back6tvar = tvar * 0
  else
    back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  end if
  tvar = tvar - back6tvar
;
  if (fv3) then
    t32 = grb_file->$T2M$(0,:,:) - 273.15
  else
    t32 = grb_file->$T2M$(:,:) - 273.15
  end if
  t32 = t32 * 9/5 + 32 ; Convert to F
;
  mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
  mint = 8
  mdens = 0.5
  mlinethick = 1.0
;
  h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
  h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
  thick = h5 - h10
  thint = 6
  thdens = 0.5
  thlinethick = 1.0
;
end if
;
if (domainname .eq. "174") then
;
  ny = filevardimsizes(grb_file,LAT)
  nx = filevardimsizes(grb_file,LON)
;
  lat = grb_file->$LAT$(::-1)
  lon = grb_file->$LON$(:)
  lonorig = lon
  fliplon = lonFlip(lon)
  if ( fctm .gt. 0 ) then
    if (isfilevar(grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + fctm + "h"
    end if
    tvar = grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
  else
    exit
  end if
  if (isfilevar(back6_grb_file,TPACC)) then
    zz = TPACC
  else
    zz = TPACC + back6fctm + "h"
  end if
  if (back6fctm .eq. 0) then
    back6tvar = tvar * 0
  else
    back6tvar = back6_grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
  end if
  tvar = tvar - back6tvar
  tvarorig = tvar
  fliptvar = lonFlip(tvar)
;
  tvarorig = tvar
  fliptvar = lonFlip(tvar)
;
  if (fv3) then
    t32 = grb_file->$T2M$(0,::-1,:) - 273.15
  else
    t32 = grb_file->$T2M$(::-1,:) - 273.15
  end if
  t32 = t32 * 9/5 + 32 ; Convert to F
  t32orig = t32
  flipt32 = lonFlip(t32)
;
  mvar = grb_file->$MSLP$(::-1,:) / 100. ; convert from Pa to mb
  mvarorig = mvar
  flipmvar = lonFlip(mvar)
  mint = 8
  mdens = 1.0
  mlinethick = 1.0
;
  h5 = grb_file->$GHISBL$(level500,::-1,:) / 10. ; use decameters
  h10 = grb_file->$GHISBL$(level1000,::-1,:) / 10. ; use decameters
  thick = h5 - h10
  thickorig = thick
  flipthick = lonFlip(thick)
  thint = 6
  thdens = 1.0
  thlinethick = 1.0
;
end if
;
if (domainname .eq. "236") then
;
  fimsizes = filevardimsizes(grb_file,LAT)
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  lat = grb_file->$LAT$(:,:)
  lon = grb_file->$LON$(:,:)
  latin1 = grb_file->$LON$@Latin1
  latin2 = grb_file->$LON$@Latin2
  lov = grb_file->$LON$@Lov
  if ( fctm .gt. 0 ) then
    if (isfilevar(grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + fctm + "h"
    end if
    tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  else
    exit
  end if
  if (isfilevar(back6_grb_file,TPACC)) then
    zz = TPACC
  else
    zz = TPACC + back6fctm + "h"
  end if
  if (back6fctm .eq. 0) then
    back6tvar = tvar * 0
  else
    back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  end if
  tvar = tvar - back6tvar
;
  if (fv3) then
    t32 = grb_file->$T2M$(0,:,:) - 273.15
  else
    t32 = grb_file->$T2M$(:,:) - 273.15
  end if
  t32 = t32 * 9/5 + 32 ; Convert to F
;
  mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
  mint = 8
  mdens = 0.5
  mlinethick = 1.0
;
  h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
  h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
  thick = h5 - h10
  thint = 6
  thdens = 0.5
  thlinethick = 1.0
;
end if
;
if (domainname .eq. "201" .or. domainname .eq. "224" .or. domainname .eq. "242") then
;
  fimsizes = filevardimsizes(grb_file,LAT)
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  lat = grb_file->$LAT$(:,:)
  lon = grb_file->$LON$(:,:)
  if ( fctm .gt. 0 ) then
    if (isfilevar(grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + fctm + "h"
    end if
    tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  else
    exit
  end if
  if (isfilevar(back6_grb_file,TPACC)) then
    zz = TPACC
  else
    zz = TPACC + back6fctm + "h"
  end if
  if (back6fctm .eq. 0) then
    back6tvar = tvar * 0
  else
    back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
  end if
  tvar = tvar - back6tvar
;
  if (fv3) then
    t32 = grb_file->$T2M$(0,:,:) - 273.15
  else
    t32 = grb_file->$T2M$(:,:) - 273.15
  end if
  t32 = t32 * 9/5 + 32 ; Convert to F
;
  mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
  mint = 8
  mdens = 0.5
  mlinethick = 1.0
;
  h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
  h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
  thick = h5 - h10
  thint = 6
  thdens = 0.5
  thlinethick = 1.0
;
end if
;
if (domainname .eq. "244") then
;
  ny = filevardimsizes(grb_file,LAT)
  nx = filevardimsizes(grb_file,LON)
;
  lon = grb_file->$LON$(:)
;
  if (fv3) then
    lat = grb_file->$LAT$(::-1)
    if ( fctm .gt. 0 ) then
      if (isfilevar(grb_file,TPACC)) then
        zz = TPACC
      else
        zz = TPACC + fctm + "h"
      end if
      tvar = grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
    else
      exit
    end if
    if (isfilevar(back6_grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + back6fctm + "h"
    end if
    if (back6fctm .eq. 0) then
      back6tvar = tvar * 0
    else
      back6tvar = back6_grb_file->$zz$(::-1,:) * 0.03937 ; convert to inches
    end if
    tvar = tvar - back6tvar
;
    t32 = grb_file->$T2M$(0,::-1,:) - 273.15
    t32 = t32 * 9/5 + 32 ; Convert to F
;
    mvar = grb_file->$MSLP$(::-1,:) / 100. ; convert from Pa to mb
    mint = 8
    mdens = 0.5
    mlinethick = 1.0
;
    h5 = grb_file->$GHISBL$(level500,::-1,:) / 10. ; use decameters
    h10 = grb_file->$GHISBL$(level1000,::-1,:) / 10. ; use decameters
    thick = h5 - h10
    thint = 6
    thdens = 0.5
    thlinethick = 1.0
  else
    lat = grb_file->$LAT$(:)
    if ( fctm .gt. 0 ) then
      if (isfilevar(grb_file,TPACC)) then
        zz = TPACC
      else
        zz = TPACC + fctm + "h"
      end if
      tvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
    else
      exit
    end if
    if (isfilevar(back6_grb_file,TPACC)) then
      zz = TPACC
    else
      zz = TPACC + back6fctm + "h"
    end if
    if (back6fctm .eq. 0) then
      back6tvar = tvar * 0
    else
      back6tvar = back6_grb_file->$zz$(:,:) * 0.03937 ; convert to inches
    end if
    tvar = tvar - back6tvar
;
    t32 = grb_file->$T2M$(:,:) - 273.15
    t32 = t32 * 9/5 + 32 ; Convert to F
;
    mvar = grb_file->$MSLP$(:,:) / 100. ; convert from Pa to mb
    mint = 8
    mdens = 0.5
    mlinethick = 1.0
;
    h5 = grb_file->$GHISBL$(level500,:,:) / 10. ; use decameters
    h10 = grb_file->$GHISBL$(level1000,:,:) / 10. ; use decameters
    thick = h5 - h10
    thint = 6
    thdens = 0.5
    thlinethick = 1.0
  end if
;
end if
;
load "$NCL_HOME/obj/get_date_str_FIM.ncl"
;
print(date_str)
print("6h totp")
print(min(tvar))
print(max(tvar))
;
xdim = nx - 1
ydim = ny - 1
rnx = 1.*xdim
rny = 1.*ydim
if (rny .ge. rnx) then
  vpheight = .88
  vpy = 1.-((1.-vpheight)/2.)
  vpwidth = (vpheight/rny)*rnx
  vpx = (1.-((vpheight/rny)*rnx))/2.
else
  vpwidth = .88
  vpx = (1.-vpwidth)/2.
  vpheight = (vpwidth/rnx)*rny
  vpy = 1.-((1.-((vpwidth/rnx)*rny))/2.)
end if
;
; Create an application object.
;
appid = create "mdss" appClass defaultapp
    "appUsrDir" : "./"
    "appDefaultParent" : True
end create
;
; Set only one of the following three params to 1, depending on the type
; of output desired (NCGM=metacode file, X11=screen, PS=PostScript file)
;
    NCGM=1
    X11=0
    PS=0
;
    if (NCGM .eq. 1) then
;
; Create an ncgmWorkstation object.
;
        wid = create "mdssWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./sfc_acp.ncgm"
        end create
    else
      if (X11 .eq. 1) then
;
; Create an XWorkstation object.
;
        wid = create "mdssWork" xWorkstationClass defaultapp
            "wkPause" : True
        end create
      else
        if (PS .eq. 1) then
;
; Create a PSWorkstation object.
;
          wid = create "mdssWork" psWorkstationClass defaultapp
           "wkPSFileName" : "./sfc_acp.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
;
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
tvarsave = tvar
;
if (domainname .eq. "fim") then
;
  load "$NCL_HOME/obj/4_tiles_loop.ncl"
;
  tvar = tvarsave
;
  if (max(tvar(lly:ury,llx:urx)) .le. 0) then
    tvar(lly,llx) = .11
  end if
;
  load "$NCL_HOME/obj/fim_maps_blk.ncl"
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
;
  t32field = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : t32
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : t32@_FillValue
  end create
;
  mfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : mvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : mvar@_FillValue
  end create
;
  zfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thick
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : thick@_FillValue
  end create
;
  load "$NCL_HOME/obj/precip_0-40_whtbkg.ncl"
;
  setvalues cnid
    "cnRasterModeOn" : False
  end setvalues
;
; 32F isotherm
;
  load "$NCL_HOME/obj/32F_isotherm.ncl"
;
  setvalues cnid5
      "cnLineColors" : (/24/)
  end setvalues
;
  if (iq .ne. 0) then
    mlinethick = 2.0
    thlinethick = 2.0
    setvalues cnid5
      "cnLineThicknessF" : 3.0
    end setvalues
  end if
;
  cnid4 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  mfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 900
      "cnMaxLevelValF" : 1100
      "cnLevelSpacingF" : mint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 23
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 23 ; "Background"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : mdens
      "cnLineThicknessF" : mlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  cnid6 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  zfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 402
      "cnMaxLevelValF" : 600
      "cnLevelSpacingF" : thint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 2
;      "cnLineDashPattern" : 5
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 2 ; "Foreground"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : thdens
      "cnLineThicknessF" : thlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  titlestring = interval + "h Precip (in), MSLP (mb), 1000-500 Thickness (dm)"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(cnid5)
  draw(cnid6)
  draw(cnid4)
  draw(mpid)
;
  gsres = True
  if (iq .eq. 0) then
;    do i = 0,dimsizes(airport_id)-1
;      gsres@gsMarkerIndex = 16
;      gsres@gsMarkerColor = 20
;      gsres@gsMarkerSizeF = 0.004
;      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;      gsres@gsMarkerIndex = 16
;      gsres@gsMarkerColor = 1
;      gsres@gsMarkerSizeF = 0.002
;      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;    end do
  else
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 20
      gsres@gsMarkerSizeF = 0.01
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 1
      gsres@gsMarkerSizeF = 0.005
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    end do
  end if
;
  frame(wid)
;
  end do  ; loop begins in 4_tiles_loop.ncl
;
end if  ; domainname .eq. "fim"
;
if (domainname .eq. "130") then
;
  load "$NCL_HOME/obj/ruc_tiles_loop.ncl"
;
  if (iq .eq. 0) then
    load "$NCL_HOME/obj/lambert_conformal_map_blk.ncl"
  else
    load "$NCL_HOME/obj/lc_map_counties.ncl"
    setvalues mpid
      "mpNationalLineColor" : "background"
      "mpCountyLineColor" : "background"
      "mpGridAndLimbOn" : False
    end setvalues
  end if
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
;
  t32field = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : t32
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : t32@_FillValue
  end create
;
  mfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : mvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : mvar@_FillValue
  end create
;
  zfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thick
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : thick@_FillValue
  end create
;
  load "$NCL_HOME/obj/precip_0-40_whtbkg.ncl"
;
  setvalues cnid
    "cnRasterModeOn" : False
  end setvalues
;
; 32F isotherm
;
  load "$NCL_HOME/obj/32F_isotherm.ncl"
;
  setvalues cnid5
      "cnLineColors" : (/24/)
  end setvalues
;
  if (iq .ne. 0) then
    mlinethick = 2.0
    thlinethick = 2.0
    setvalues cnid5
      "cnLineThicknessF" : 3.0
    end setvalues
  end if
;
  cnid4 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  mfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 900
      "cnMaxLevelValF" : 1100
      "cnLevelSpacingF" : mint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 23
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 23 ; "Background"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : mdens
      "cnLineThicknessF" : mlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  cnid6 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  zfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 402
      "cnMaxLevelValF" : 600
      "cnLevelSpacingF" : thint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 2
;      "cnLineDashPattern" : 5
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 2 ; "Foreground"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : thdens
      "cnLineThicknessF" : thlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  titlestring = interval + "h Precip (in), MSLP (mb), 1000-500 Thickness (dm)"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(cnid5)
  draw(cnid6)
  draw(cnid4)
  draw(mpid)
;
  gsres = True
  if (iq .eq. 0) then
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 20
      gsres@gsMarkerSizeF = 0.004
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 1
      gsres@gsMarkerSizeF = 0.002
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    end do
  else
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 20
      gsres@gsMarkerSizeF = 0.01
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 1
      gsres@gsMarkerSizeF = 0.005
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    end do
  end if
;
  frame(wid)
;
  end do  ; loop begins in ruc_tiles_loop.ncl
;
end if  ; domainname .eq. "130"
;
if (domainname .eq. "174") then
;
  load "$NCL_HOME/obj/fim_174subdomain_loop.ncl"
;
  if (idom .eq. 0 .or. idom .eq. 2) then
    load "$NCL_HOME/obj/fim_maps_cent0_blk.ncl"
  else
    load "$NCL_HOME/obj/fim_maps_cent180_blk.ncl"
  end if
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
;
  t32field = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : t32
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : t32@_FillValue
  end create
;
  mfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : mvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : mvar@_FillValue
  end create
;
  zfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thick
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : thick@_FillValue
  end create
;
  load "$NCL_HOME/obj/precip_0-40_whtbkg.ncl"
;
  load "$NCL_HOME/obj/32F_isotherm.ncl"
;
  setvalues cnid5
      "cnLineColors" : (/24/)
  end setvalues
;
  if (iq .ne. 0) then
    mlinethick = 2.0
    thlinethick = 2.0
    setvalues cnid5
      "cnLineThicknessF" : 3.0
    end setvalues
  end if
;
  cnid4 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  mfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 900
      "cnMaxLevelValF" : 1100
      "cnLevelSpacingF" : mint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 23
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 23 ; "Background"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : mdens
      "cnLineThicknessF" : mlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  cnid6 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  zfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 402
      "cnMaxLevelValF" : 600
      "cnLevelSpacingF" : thint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 2
;      "cnLineDashPattern" : 5
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 2 ; "Foreground"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : thdens
      "cnLineThicknessF" : thlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  titlestring = interval + "h Precip (in), MSLP (mb), 1000-500 Thickness (dm)"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(cnid5)
  draw(cnid6)
  draw(cnid4)
  draw(mpid)
;
  frame(wid)
;
  end do  ; loop begins in fim_174subdomain_loop.ncl
;
end if  ; domainname .eq. "174"
;
if (domainname .eq. "242") then
;
  load "$NCL_HOME/obj/242_tiles_loop.ncl"
;
  centerlat = 90
  centerlon = grb_file->$LON$@Lov
  load "$NCL_HOME/obj/stereographic_map_blk.ncl"
;
  setvalues mpid
    "mpUSStateLineThicknessF" : 2
    "mpGeophysicalLineThicknessF" : 2
    "mpNationalLineThicknessF" : 2
  end setvalues
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
;
  t32field = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : t32
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : t32@_FillValue
  end create
;
  mfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : mvar
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : mvar@_FillValue
  end create
;
  zfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thick
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : thick@_FillValue
  end create
;
  load "$NCL_HOME/obj/precip_0-40_whtbkg.ncl"
;
;  if (iq .ne. 0) then
    setvalues cnid
      "cnFillMode" : "AreaFill"
    end setvalues
;  else
;    setvalues cnid
;      "cnFillMode" : "RasterFill"
;    end setvalues
;  end if
;
  load "$NCL_HOME/obj/32F_isotherm.ncl"
;
  setvalues cnid5
      "cnLineColors" : (/24/)
  end setvalues
;
  if (iq .ne. 0) then
    mlinethick = 2.0
    thlinethick = 2.0
    setvalues cnid5
      "cnLineThicknessF" : 3.0
    end setvalues
  end if
;
  cnid4 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  mfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 900
      "cnMaxLevelValF" : 1100
      "cnLevelSpacingF" : mint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 23
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 23 ; "Background"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : mdens
      "cnLineThicknessF" : mlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  cnid6 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  zfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 402
      "cnMaxLevelValF" : 600
      "cnLevelSpacingF" : thint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 2
;      "cnLineDashPattern" : 5
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 2 ; "Foreground"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : thdens
      "cnLineThicknessF" : thlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  titlestring = interval + "h Precip (in), MSLP (mb), 1000-500 Thickness (dm)"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(cnid5)
  draw(cnid6)
  draw(cnid4)
  draw(mpid)
;
  frame(wid)
;
  end do  ; loop begins in 242_tiles_loop.ncl
;
end if  ; domainname .eq. "242"
;
if (domainname .ne. "fim" .and. domainname .ne. "130" .and. domainname .ne. "174" .and. domainname .ne. "242") then
;
  load "$NCL_HOME/obj/fim_maps_blk.ncl"
;
; Create ScalarField objects.
;
  if (domainname .eq. "244" .or. domainname .eq. "129") then
;
    tfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : tvar
        "sfXCStartV" : 0
        "sfYCStartV" : ydim
        "sfXCEndV" : xdim
        "sfYCEndV" : 0
        "sfMissingValueV" : tvar@_FillValue
    end create
;
    t32field = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : t32
        "sfXCStartV" : 0
        "sfYCStartV" : ydim
        "sfXCEndV" : xdim
        "sfYCEndV" : 0
        "sfMissingValueV" : t32@_FillValue
    end create
;
    mfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : mvar
        "sfXCStartV" : 0
        "sfYCStartV" : ydim
        "sfXCEndV" : xdim
        "sfYCEndV" : 0
        "sfMissingValueV" : mvar@_FillValue
    end create
;
    zfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : thick
        "sfXCStartV" : 0
        "sfYCStartV" : ydim
        "sfXCEndV" : xdim
        "sfYCEndV" : 0
        "sfMissingValueV" : thick@_FillValue
    end create
;
  end if
;
  if (domainname .eq. "236" .or. domainname .eq. "201" .or. domainname .eq. "224" .or. \
      domainname .eq. "83") then
;
    iq = 0
;
    tfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : tvar
        "sfXCStartV" : 0
        "sfYCStartV" : 0
        "sfXCEndV" : xdim
        "sfYCEndV" : ydim
        "sfMissingValueV" : tvar@_FillValue
    end create
;
    t32field = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : t32
        "sfXCStartV" : 0
        "sfYCStartV" : 0
        "sfXCEndV" : xdim
        "sfYCEndV" : ydim
        "sfMissingValueV" : t32@_FillValue
    end create
;
    mfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : mvar
        "sfXCStartV" : 0
        "sfYCStartV" : 0
        "sfXCEndV" : xdim
        "sfYCEndV" : ydim
        "sfMissingValueV" : mvar@_FillValue
    end create
;
    zfield = create "ScalarField" scalarFieldClass appid
        "sfDataArray" : thick
        "sfXCStartV" : 0
        "sfYCStartV" : 0
        "sfXCEndV" : xdim
        "sfYCEndV" : ydim
        "sfMissingValueV" : thick@_FillValue
    end create
;
  end if
;
  load "$NCL_HOME/obj/precip_0-40_whtbkg.ncl"
;
  if (domainname .eq. "236" .or. domainname .eq. "244" .or. domainname .eq. "83" .or. \
      domainname .eq. "201" .or. domainname .eq. "224") then
;
    iq = 0
;
    setvalues cnid
      "cnRasterModeOn" : False
    end setvalues
;
  end if
;
  load "$NCL_HOME/obj/32F_isotherm.ncl"
;
  setvalues cnid5
      "cnLineColors" : (/24/)
  end setvalues
;
  if (iq .ne. 0) then
    mlinethick = 2.0
    thlinethick = 2.0
    setvalues cnid5
      "cnLineThicknessF" : 3.0
    end setvalues
  end if
;
  cnid4 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  mfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 900
      "cnMaxLevelValF" : 1100
      "cnLevelSpacingF" : mint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 23
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 23 ; "Background"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : mdens
      "cnLineThicknessF" : mlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  cnid6 = create "contourplot" contourPlotClass wid
      "cnScalarFieldData":  zfield
      "cnFillOn" : False
      "cnLevelSelectionMode" : "ManualLevels"
      "cnMinLevelValF" : 402
      "cnMaxLevelValF" : 600
      "cnLevelSpacingF" : thint
      "cnLevelFlags" : (/"LineAndLabel"/)
      "cnInfoLabelOn" : False
      "cnLinesOn" : True
      "cnLineColor" : 2
;      "cnLineDashPattern" : 5
      "cnLineLabelsOn" : True
      "cnLineLabelInterval" : 1
      "cnLineLabelFont" : 21
      "cnLineLabelFontHeightF" : 0.01
      "cnLineLabelFontColor" : 2 ; "Foreground"
      "cnLineLabelBackgroundColor" : 1
      "cnLineLabelPlacementMode" : "Computed"
      "cnLineLabelDensityF" : thdens
      "cnLineThicknessF" : thlinethick
      "pmTickMarkDisplayMode" : "NoCreate"
      "vpXF"      : vpx        ; set viewport
      "vpYF"      : vpy
      "vpWidthF"  : vpwidth
      "vpHeightF" : vpheight
  end create
;
  titlestring = interval + "h Precip (in), MSLP (mb), 1000-500 Thickness (dm)"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(cnid5)
  draw(cnid6)
  draw(cnid4)
  draw(mpid)
;
  gsres = True
  if (domainname .eq. "236") then
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 20
      gsres@gsMarkerSizeF = 0.004
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 1
      gsres@gsMarkerSizeF = 0.002
      gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    end do
  end if
;
  frame(wid)
;
end if  ; domainname .ne. "fim" .and. domainname .ne. "130" .and. domainname .ne. "174" .and. domainname .ne. "242"
;
end
;
