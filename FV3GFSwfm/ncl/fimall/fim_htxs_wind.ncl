;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "WRFUserARW.ncl"
modl = getenv("MODL")
;
;load "$NCL_HOME/obj/cmap1.ncl"
load "$NCL_HOME/obj/cmap3_cmap1_dbl2_merged.ncl"
;
begin
;
fname = asciiread("arw_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
domainname = asciiread("domain.txt",-1,"string")
;
parms = asciiread("parms_file.txt",-1,"float")  ; read lat,lon of x-section end points
start_lat = parms(0)
start_lon = parms(1)
end_lat = parms(2)
end_lon = parms(3)
htfrac = parms(4)
;
if (domainname .eq. "fim") then
;
  planny = filevardimsizes(grb_file,"lat_4")
  plannx = filevardimsizes(grb_file,"lon_4")
;
  intm = grb_file->T_4_SFC@initial_time
  fctm = grb_file->T_4_SFC@forecast_time
  lat = grb_file->lat_4(:)
  lon = grb_file->lon_4(:)
  if (start_lon .lt. 0.) then
    start_lon = start_lon + 360.
  end if
  if (end_lon .lt. 0.) then
    end_lon = end_lon + 360.
  end if
;
end if
;
if (domainname .eq. "236") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_236")
  planny = fimsizes(0)
  plannx = fimsizes(1)
;
  intm = grb_file->T_236_SFC@initial_time
  fctm = grb_file->T_236_SFC@forecast_time
  lat = grb_file->gridlat_236(:,:)
  lon = grb_file->gridlon_236(:,:)
  latin1 = grb_file->gridlon_236@Latin1
  latin2 = grb_file->gridlon_236@Latin2
  lov = grb_file->gridlon_236@Lov
;
end if
;
if (domainname .eq. "africa" .or. domainname .eq. "europe") then
;
  planny = filevardimsizes(grb_file,"g0_lat_1")
  plannx = filevardimsizes(grb_file,"g0_lon_2")
;
  intm = grb_file->T_GDS0_SFC@initial_time
  fctm = grb_file->T_GDS0_SFC@forecast_time
  lat = grb_file->g0_lat_1(:)
  lon = grb_file->g0_lon_2(:)
;
end if
;
if (domainname .eq. "219") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_219")
  planny = fimsizes(0)
  plannx = fimsizes(1)
;
  intm = grb_file->T_219_SFC@initial_time
  fctm = grb_file->T_219_SFC@forecast_time
  lat = grb_file->gridlat_219(:,:)
  lon = grb_file->gridlon_219(:,:)
;
end if
;
if (domainname .eq. "28") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_28")
  planny = fimsizes(0)
  plannx = fimsizes(1)
;
  intm = grb_file->T_28_SFC@initial_time
  fctm = grb_file->T_28_SFC@forecast_time
  lat = grb_file->gridlat_28(:,:)
  lon = grb_file->gridlon_28(:,:)
;
end if

if (domainname .eq. "244") then
;
  planny = filevardimsizes(grb_file,"lat_244")
  plannx = filevardimsizes(grb_file,"lon_244")
;
  intm = grb_file->T_244_SFC@initial_time
  fctm = grb_file->T_244_SFC@forecast_time
  lat = grb_file->lat_244(:)
  lon = grb_file->lon_244(:)
;
end if
;
if (domainname .eq. "w_pacific") then
;
  planny = filevardimsizes(grb_file,"g0_lat_1")
  plannx = filevardimsizes(grb_file,"g0_lon_2")
;
  intm = grb_file->T_GDS0_SFC@initial_time
  fctm = grb_file->T_GDS0_SFC@forecast_time
  lat = grb_file->g0_lat_1(:)
  lon = grb_file->g0_lon_2(:)
;
end if
;
year = stringtointeger(getSubString(intm,6,9))
mon  = stringtointeger(getSubString(intm,0,1))
day  = stringtointeger(getSubString(intm,3,4))
hour = stringtointeger(getSubString(intm,12,13))
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(year,mon,day,hour,0,0,time@units, 0)
fcst = (/date + stringtointeger(fctm)*3600/)
fcst@units = "seconds since 1970-01-01 00:00:0.0"
utc_date = ut_calendar(fcst, 0)
year   = floattointeger(utc_date(:,0))    ; Convert to integer for
month  = floattointeger(utc_date(:,1))    ; use in the sprinti function.
day    = floattointeger(utc_date(:,2))
hour   = floattointeger(utc_date(:,3))
minute = floattointeger(utc_date(:,4))
second = utc_date(:,5)
date_str = "Valid " + sprinti("%0.2i/", month) + sprinti("%0.2i/",day) + \
           sprinti("%0.4i", year) + " " + sprinti("%0.2i:00 ", hour)  + \
           "UTC"
;
print(date_str)
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
           "wkMetaName" : "./htxs_wind.ncgm"
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
           "wkPSFileName" : "./htxs_wind.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;
; Increase workspace memory
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
if (domainname .eq. "fim") then
;
  uvar = grb_file->UW_4_HYBL(:,:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_4_HYBL(:,:,:) * 1.9429 ; convert to knots
  windsfc = grb_file->T_4_SFC(:,:) * 0. ; new ground level wind (set to 0.)
  tvar = grb_file->T_4_HYBL(:,:,:) - 273.15
  tvarsfc = grb_file->T_4_SFC(:,:) - 273.15
  hvar = grb_file->GH_4_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_4_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "236") then
;
  uvar = grb_file->UW_236_HYBL(:,:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_236_HYBL(:,:,:) * 1.9429 ; convert to knots
  windsfc = grb_file->T_236_SFC(:,:) * 0. ; new ground level wind (set to 0.)
  tvar = grb_file->T_236_HYBL(:,:,:) - 273.15
  tvarsfc = grb_file->T_236_SFC(:,:) - 273.15
  hvar = grb_file->GH_236_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_236_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "africa" .or. domainname .eq. "europe") then
;
  tvar = grb_file->T_GDS0_HYBL(:,:,:) - 273.15
  hvar = grb_file->GH_GDS0_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_GDS0_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "219") then
;
  tvar = grb_file->T_219_HYBL(:,:,:) - 273.15
  hvar = grb_file->GH_219_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_219_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "28") then
;
  tvar = grb_file->T_28_HYBL(:,:,:) - 273.15
  hvar = grb_file->GH_28_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_28_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "244") then
;
  tvar = grb_file->T_244_HYBL(:,:,:) - 273.15
  hvar = grb_file->GH_244_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_244_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
if (domainname .eq. "w_pacific") then
;
  tvar = grb_file->T_GDS0_HYBL(:,:,:) - 273.15
  hvar = grb_file->GH_GDS0_HYBL(:,:,:) / 1000. ; convert to km
  pvar = grb_file->P_GDS0_HYBL(:,:,:) / 100. ; convert to mb
;
end if
;
uv2 = uvar * uvar
vv2 = vvar * vvar
wind = sqrt(uv2 + vv2)
templevs = grb_file->lv_HYBL4
maxlev = dimsizes(templevs)
windwithsfc = pvar
windwithsfc(1:maxlev,:,:) = wind
windwithsfc(0,:,:) = windsfc
print("Wind Spd")
print(min(windwithsfc))
print(max(windwithsfc))
;
; Compute potential temperature
;
tvarwithsfc = pvar
templevs = grb_file->lv_HYBL4
maxlev = dimsizes(templevs)
tvarwithsfc(1:maxlev,:,:) = tvar
tvarwithsfc(0,:,:) = tvarsfc
thetavar = (tvarwithsfc + 273.15) * (1000./pvar)^.285714
print("theta")
print("min = "+min(thetavar))
print("max = "+max(thetavar))
;
print("domain " + domainname)
print("temp")
print(min(tvarwithsfc))
print(max(tvarwithsfc))
print("gh")
print(min(hvar))
print(max(hvar))
;
s1d = grb_file->lv_HYBL0(:) * 1.0
hgt = conform(tvarwithsfc, s1d, 0)
;
print("start_lat = "+start_lat)
print("start_lon = "+start_lon)
print("end_lat = "+end_lat)
print("end_lon = "+end_lon)
if (domainname .eq. "fim") then
  startpts = new(2,integer)
  endpts = new(2,integer)
  do j = 0,dimsizes(lat)-2
    print("j = "+j+"  lat(j) = "+lat(j)+"  lat(j+1) = "+lat(j+1))
    if (start_lat.le.lat(j) .and. start_lat.gt.lat(j+1)) then
      print("got start lat at "+j)
      startpts(0) = j
    end if
    if (end_lat.le.lat(j) .and. end_lat.gt.lat(j+1)) then
      print("got end lat at "+j)
      endpts(0) = j
    end if
  end do
  do i = 0,dimsizes(lon)-2
    print("i = "+i+"  lon(i) = "+lon(i)+"  lon(i+1) = "+lon(i+1))
    if (start_lon.ge.lon(i) .and. start_lon.lt.lon(i+1)) then
      print("got start lon at "+i)
      startpts(1) = i
    end if
    if (end_lon.ge.lon(i) .and. end_lon.lt.lon(i+1)) then
      print("got end lon at "+i)
      endpts(1) = i
    end if
  end do
  print(startpts)
  print(endpts)
end if
;
if (domainname .eq. "236") then
  startpts = wrf_latlon_to_ij(lat, lon, start_lat, start_lon)
  endpts = wrf_latlon_to_ij(lat, lon, end_lat, end_lon)
end if
print(startpts)
print(endpts)
planepts = (/ startpts(1), startpts(0), endpts(1), endpts(0) /) * 1.0
;
plane = wrf_user_intrp3d(windwithsfc, hvar, "v", planepts, 0.0, True)
if (max(plane) .eq. min(plane)) then
  plane(0,0) = 0.2
end if
thetaplane = wrf_user_intrp3d(thetavar, hvar, "v", planepts, 0.0, True)
planehts = wrf_user_intrp3d(hvar, hvar, "v", planepts, 0.0, True)
planepres = wrf_user_intrp3d(pvar, hvar, "v", planepts, 0.0, True)
dims = dimsizes(plane)
if (domainname .eq. "fim") then
  distance = gc_latlon(lat(startpts(0)), lon(startpts(1)), \
                       lat(endpts(0)), lon(endpts(1)), 0, 4)
end if 
if (domainname .eq. "236") then
  distance = gc_latlon(lat(startpts(0), startpts(1)), lon(startpts(0),startpts(1)), \
                       lat(endpts(0), endpts(1)), lon(endpts(0), endpts(1)), 0, 4)
end if
;
if ( distance/10 .gt. 10 ) then
  numlabels = 11
  distlabels = fspan(0, distance, numlabels)
  distlabels = round(distlabels,3)
  if (distlabels(10) .gt. distance) then
    distlabels(10) = distlabels(10) - 1
  end if
else
  numlabels = 2
  distlabels = fspan(0, distance, numlabels)
  distlabels = (/ 0,distance /)
end if
;
nx = dims(1)
ny = dims(0)
nx2 = nx
ny2 = ny
do ii = 1,20
  if (nx2 .gt. ny2) then
    ny2 = ny2 + ny
  end if
  if (ny2 .gt. nx2) then
    nx2 = nx2 + nx
  end if
  aspect = (ny2 * 1.0)/(nx2 * 1.0)
  diffaspect = abs(1.0 - aspect)
  if (ii .eq. 1) then
    prevdiffaspect = diffaspect
    holdnx2 = nx2
    holdny2 = ny2
  else
    if (diffaspect .lt. prevdiffaspect) then
      prevdiffaspect = diffaspect
      holdnx2 = nx2
      holdny2 = ny2
    end if
  end if
end do
nx2 = holdnx2
ny2 = holdny2
;
xdim = nx2 - 1
ydim = ny2 - 1
rnx = 1.*xdim
rny = 1.*ydim
if (rny .ge. rnx) then
  vpheight = .8
  vpy = 1.-((1.-vpheight)/2.)
  vpwidth = (vpheight/rny)*rnx
  vpx = (1.-((vpheight/rny)*rnx))/2.
else
  vpwidth = .8
  vpx = (1.-vpwidth)/2.
  vpheight = (vpwidth/rnx)*rny
  vpy = 1.-((1.-((vpwidth/rnx)*rny))/2.)
end if
;
midpt = (ny - 1) * htfrac
;
; Create ScalarField objects.
;
if (domainname .eq. "fim" .or. domainname .eq. "244") then
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : plane
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : plane@_FillValue
  end create
  thetafield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thetaplane
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : thetaplane@_FillValue
  end create
  hfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : planehts
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : planehts@_FillValue
  end create
;
end if
;
if (domainname .eq. "236" .or. domainname .eq. "africa" .or. \
    domainname .eq. "w_pacific" .or. domainname .eq. "europe") then
;
; Temperature
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : plane
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : plane@_FillValue
  end create
  thetafield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : thetaplane
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : thetaplane@_FillValue
  end create
  hfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : planehts
      "sfYCStartSubsetV" : 0
      "sfYCEndSubsetV" : midpt
      "sfMissingValueV" : planehts@_FillValue
  end create
;
end if
;
if (domainname .eq. "219") then
;
; Temperature
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartV" : 0
      "sfYCStartV" : 0
      "sfXCEndV" : xdim
      "sfYCEndV" : ydim
      "sfMissingValueV" : -999.0
  end create
;
; Geopotential Height
;
  hfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : hvar
      "sfXCStartV" : 0
      "sfYCStartV" : 0
      "sfXCEndV" : xdim
      "sfYCEndV" : ydim
      "sfMissingValueV" : -999.0
  end create
;
end if
;
if (domainname .eq. "28") then
;
  tfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvar
      "sfXCStartV" : xdim
      "sfYCStartV" : ydim
      "sfXCEndV" : 0
      "sfYCEndV" : 0
      "sfMissingValueV" : -999.0
  end create
;
; Geopotential Height
;
  hfield = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : hvar
      "sfXCStartV" : xdim
      "sfYCStartV" : ydim
      "sfXCEndV" : 0
      "sfYCEndV" : 0
      "sfMissingValueV" : -999.0
  end create
;
end if
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/wind_20-180by20.ncl"
;
setvalues cnid
  "cnRasterModeOn" : False
  "cnFillColors" : (/ 52,54,56,58,60,62,64,66,68,70,72,74,88 /)
;  "cnExplicitLabelBarLabelsOn" : True
;  "lbLabelStrings" : (/ "-80","","","","-70","","","","-60","","","","-50","","","","-40", \
;                        "","","","-30","","-25","","-20","","-15","","-10","","-5","", \
;                        "0","","5","","10","","15","","20","","25","","30","", \
;                        "35","","40" /)
  "lbTopMarginF" : 0.35
  "lbAutoManage" : False
  "lbLabelFont" : 21
  "lbLabelFontHeightF" : 0.015
  "tiYAxisString" : "Height (km)"
  "tiYAxisFont" : 21
  "tiYAxisFontHeightF" : 0.012
  "tiYAxisOffsetXF" : -0.022
  "tiXAxisString" : "Distance (km)"
  "tiXAxisFont" : 21
  "tiXAxisFontHeightF" : 0.012
  "tiXAxisOffsetYF" : -0.01
end setvalues
;
if (domainname .eq. "236" .or. domainname .eq. "africa" .or. \
    domainname .eq. "244" .or. domainname .eq. "w_pacific" .or. \
    domainname .eq. "europe" .or. domainname .eq. "28") then
;
  setvalues cnid
    "cnRasterModeOn" : False
  end setvalues
;
end if
;
; Theta
;
cnid2 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  thetafield
;    "cnScalarFieldData":  hfield
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 260
    "cnMaxLevelValF" : 900
    "cnLevelSpacingF" : 4
;    "cnMinLevelValF" : 0
;    "cnMaxLevelValF" : 50
;    "cnLevelSpacingF" : 1
    "cnLinesOn" : True
    "cnMonoLineColor" : True
    "cnLineColor" : 0
    "cnLineThicknessF" : 1.25
    "cnLineLabelsOn" : True
    "cnLineLabelFontHeightF" : 0.0125
    "cnLineLabelFontThicknessF" : 2.0
    "cnLineLabelPlacementMode" : "Computed"
    "cnLineLabelDensityF" : 0.1
    "cnInfoLabelOn" : False
    "cnLineLabelInterval" : 1
    "cnLineLabelFont" : 21
    "cnLineLabelFontColor" : "Background"
    "cnLineLabelBackgroundColor" : -1
    "pmTickMarkDisplayMode" : "NoCreate"
    "cnFillOn" : False
    "cnGridBoundPerimOn" : False
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
mxplnht = max(planehts) * htfrac
mxplnhtm = mxplnht * 1000.
;
; Read in the stdatm.txt file to get relevant pressure to mxplnht
;
toppres = "" 
if (mxplnhtm.lt.40000.) then
  stdatmvars = asciiread("stdatm.txt",(/40001,6/),"float")
  do findpres = 0,39999
    if (mxplnhtm.ge.stdatmvars(findpres,0) .and. mxplnhtm.lt.stdatmvars(findpres+1,0)) then
      mnplnpres = stdatmvars(findpres,2)
      toppres = sprintf("%0.2f",mnplnpres)
    end if
  end do
else
  if (htfrac .eq. 1.0) then
    toppres = sprintf("%0.2f",min(planepres))
  end if
end if

prlevs = (/ 0.11, 1.457, 3.013, 5.579, 7.193, 9.177, \
            10.379, 11.806, 13.637, 16.221, 20.643, mxplnht /)
prlevslabs = (/ "1000","850","700","500","400", \
                "300","250","200","150","100","50",toppres /)
;
tmid = create "TickMarks" tickMarkClass wid
  "tmBorderLineColor" : 1
  "tmXBDataLeftF" : 0
  "tmXBDataRightF" : distance
  "tmXBMode" : "Explicit"
  "tmXBValues" : distlabels
  "tmXBLabels" : distlabels
  "tmXBLabelFont" : 21
  "tmXBLabelFontHeightF" : 0.012
  "tmXBLabelDeltaF" : -0.5
  "tmXBMinorLengthF" : 0.01
  "tmXBMinorLineColor" : 1
  "tmXBMajorLengthF" : 0.01
  "tmXBMajorLineColor" : 1
  "tmYLDataBottomF" : 0
  "tmYLDataTopF" : mxplnht
  "tmYLMode" : "Manual"
  "tmYLTickSpacingF" : 5
  "tmYLLabelFont" : 21
  "tmYLLabelFontHeightF" : 0.012
  "tmYLLabelDeltaF" : -0.5
  "tmYLMinorLengthF" : 0.01
  "tmYLMinorLineColor" : 1
  "tmYLMinorPerMajor" : 4
  "tmYLMajorLengthF" : 0.01
  "tmYLMajorLineColor" : 1
  "tmYUseLeft" : False
  "tmYROn" : True
  "tmYRLabelsOn" : True
  "tmYRDataBottomF" : 0
  "tmYRDataTopF" : mxplnht
  "tmYRMode" : "Explicit"
  "tmYRValues" : prlevs
  "tmYRLabels" : prlevslabs
  "tmYRLabelFont" : 21
  "tmYRLabelFontHeightF" : 0.012
  "tmYRLabelDeltaF" : 0.5
  "tmYRMajorLengthF" : 0.01
  "tmYRMajorLineColor" : 1
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
end create
;
titleid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : "Wind Speed (kt) X-sect from "+start_lat+","+start_lon+ \
               " to "+end_lat+","+end_lon
  "txFont" : 22
  "txFontHeightF" : 0.02
  "txFontColor" : 1
end create
;
txid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : modl+" "+intm+" "+fctm+" hr fcst"
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid2 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : date_str
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid3 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txAngleF" : 270.0
  "txString" : "Pressure (mb, from Std. Atm.)"
  "txFont" : 21
  "txFontHeightF" : 0.0125
  "txFontColor" : 1
end create
;
txid4 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : start_lat+","+start_lon
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid5 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : end_lat+","+end_lon
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
iannotitle = NhlAddAnnotation(cnid,titleid)
setvalues iannotitle
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  0.0
end setvalues
;
if (vpheight .ge. vpwidth) then
  opos = 0.032
else
  opos = 0.1 - ((vpheight/vpwidth)*0.07)
end if
;
ianno = NhlAddAnnotation(cnid,txid)
setvalues ianno
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  opos
end setvalues
;
ianno2 = NhlAddAnnotation(cnid,txid2)
setvalues ianno2
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  opos + .005
end setvalues
;
ianno3 = NhlAddAnnotation(cnid,txid3)
setvalues ianno3
  "amZone":           10
  "amSide":           "right"
  "amJust":           "centerleft"
  "amParallelPosF":    0.5
;  "amOrthogonalPosF":  opos + 0.005
end setvalues
;
ianno4 = NhlAddAnnotation(cnid,txid4)
setvalues ianno4
  "amZone":           10
  "amSide":           "bottom"
  "amJust":           "topleft"
  "amParallelPosF":    0.0 - (opos * 2)
  "amOrthogonalPosF":  -(opos * 2.5)
end setvalues
;
ianno5 = NhlAddAnnotation(cnid,txid5)
setvalues ianno5
  "amZone":           10
  "amSide":           "bottom"
  "amJust":           "topright"
  "amParallelPosF":    1.0 + (opos * 2)
  "amOrthogonalPosF":  -(opos * 2.5)
end setvalues
;
; Draw Temp cross section
;
draw(cnid)
draw(cnid2)  ; theta lines don't look right, some closed contours
draw(tmid)
;
; Plot the transect line in plan view (picture-in-picture)
;
newvpx = vpx + (vpwidth - (vpwidth * .2))
newvpy = vpy
newvpwidth = vpwidth * .2
newvpheight = vpheight * .2
;
;temp500 = grb_file->T_236_ISBL(19,:,:) - 273.15
;
xdim = plannx - 1
ydim = planny - 1
;
; find the approximate center point of the cross section
;
if (domainname .eq. "fim") then
  midlat = (lat(startpts(0)) + lat(endpts(0))) / 2.
  midlon = (lon(startpts(1)) + lon(endpts(1))) / 2.
end if
if (domainname .eq. "236") then
  midlat = (lat(startpts(0),startpts(1)) + lat(endpts(0),endpts(1))) / 2.
  midlon = (lon(startpts(0),startpts(1)) + lon(endpts(0),endpts(1))) / 2.
end if
;
if (domainname .eq. "fim") then
  res = True
  res@MAP_PROJ  = 6
  res@STAND_LON = 0.0
  res@POLE_LAT = 90.0
  res@POLE_LON =  0.0
  res@LATINC = 0.5
  res@LONINC = 0.5
  res@REF_LON = lon(0)
  res@REF_LAT = lat(0)
  res@KNOWNI = 0
  res@KNOWNJ = 0
end if
if (domainname .eq. "236") then
  res = True
  res@MAP_PROJ  = 1
  res@TRUELAT1  = grb_file->gridlon_236@Latin1
  res@TRUELAT2  = grb_file->gridlon_236@Latin2
  res@STAND_LON = grb_file->gridlon_236@Lov
  res@DX        = grb_file->gridlon_236@Dx
  res@DY        = grb_file->gridlon_236@Dy
  res@POLE_LAT = 90.0
  res@POLE_LON =  0.0
  res@LATINC = 0.0
  res@LONINC = 0.0
  res@REF_LON = lon(0,0)
  res@REF_LAT = lat(0,0)
  res@KNOWNI = 0
  res@KNOWNJ = 0
end if
;
; Use the grid spacing to determine how many pts in x and y
; (subtracting 10 provides a little margin so that the line
; endpoints can be seen)
;
if (domainname .eq. "fim") then
  gdist = distance / 111 
  gdist = gdist + 120   ; add a little distance so we can see endpoints
;
  centerpt = new(2,integer)
  centerpt(0) = startpts(0) + (abs(startpts(0) - endpts(0)) / 2)
  centerpt(1) = startpts(1) + (abs(startpts(1) - endpts(1)) / 2)
  llx = floattointeger(centerpt(1) - (gdist/2))
  lly = floattointeger(centerpt(0) - (gdist/2))
  urx = floattointeger(centerpt(1) + (gdist/2))
  ury = floattointeger(centerpt(0) + (gdist/2))
  LcLon = lon(llx)
  LcLat = lat(lly)
  RcLon = lon(urx)
  RcLat = lat(ury)
end if

if (domainname .eq. "236") then
  gdist = distance / (floattointeger(res@DX / 1000.) - 10)
;
  centerpt = wrf_latlon_to_ij(lat, lon, midlat, midlon)
  llx = floattointeger(centerpt(1) - (gdist/2))
  lly = floattointeger(centerpt(0) - (gdist/2))
  urx = floattointeger(centerpt(1) + (gdist/2))
  ury = floattointeger(centerpt(0) + (gdist/2))
  Lc = wrf_ij_to_ll(llx, lly, res)
  Rc = wrf_ij_to_ll(urx, ury, res)
  LcLon = Lc(0)
  LcLat = Lc(1)
  RcLon = Rc(0)
  RcLat = Rc(1)
end if

;  plansub = temp500(lly:ury,llx:urx)
;  if (max(plansub) .eq. min(plansub)) then
;    temp500(lly,llx) = 0.  ; set the corner pt to avoid constant field plot
;  end if
;
;planfield = create "ScalarField" scalarFieldClass appid
;    "sfDataArray" : temp500
;    "sfXCStartSubsetV" : llx
;    "sfYCStartSubsetV" : lly
;    "sfXCEndSubsetV" : urx
;    "sfYCEndSubsetV" : ury
;    "sfMissingValueV" : temp500@_FillValue
;end create
;
;cnid3 = create "contourplot" contourPlotClass wid
;    "cnScalarFieldData":  planfield
;;    "cnRasterModeOn":  True
;    "cnLevelSelectionMode" : "ExplicitLevels"
;    "cnFillColors" : (/ 42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60, \
;                        61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76 /)
;    "cnLevels" : (/ -70,-67.5,-65,-62.5,-60,-57.5,-55,-52.5,-50,-47.5,-45,-42.5, \
;                    -40,-37.5,-35,-32.5,-30,-27.5,-25,-22.5,-20,-17.5,-15,-12.5, \
;                    -10,-7.5,-5,-2.5,0,2.5,5,7.5,10 /)
;    "cnFillOn" : True
;    "cnLinesOn" : False
;    "cnLineLabelsOn" : False
;    "cnInfoLabelOn" : False
;    "pmTickMarkDisplayMode" : "NoCreate"
;    "pmLabelBarDisplayMode" : "NEVER"
;    "pmLabelBarHeightF" : .05
;    "pmLabelBarWidthF" : 0.9
;    "pmLabelBarSide" : "bottom"
;    "pmLabelBarOrthogonalPosF" : 0.0
;    "lbOrientation" : "horizontal"
;    "lbTitleFont" : 22
;    "lbPerimOn" : False
;    "lbBoxLinesOn" : True
;    "vpXF"      : newvpx        ; set viewport
;    "vpYF"      : newvpy
;    "vpWidthF"  : newvpwidth
;    "vpHeightF" : newvpheight
;end create
;draw(cnid3)
;
if (domainname .eq. "fim") then
  mpid2 = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpCenterLonF" : midlon
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
    "mpOutlineSpecifiers" : (/"Canada : Provinces"/)
    "mpNationalLineColor" : 28
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : 28
    "mpUSStateLineThicknessF" : 1.25
    "mpGridAndLimbOn" : False
    "mpGeophysicalLineColor" : 28
    "mpPerimOn" : True
    "mpPerimLineColor" : 28
    "vpXF"      : newvpx        ; set viewport
    "vpYF"      : newvpy
    "vpWidthF"  : newvpwidth
    "vpHeightF" : newvpheight
;
  end create
end if
;
if (domainname .eq. "236") then
  mpid2 = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "LambertConformal"
    "mpLambertParallel1F" : latin1
    "mpLambertParallel2F" : latin2
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLambertMeridianF" : lov
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
;    "mpDataSetName" : "Earth..4"
    "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
    "mpOutlineSpecifiers" : (/"Canada : Provinces"/)
    "mpNationalLineColor" : 28
    "mpUSStateLineColor" : 28
    "mpUSStateLineThicknessF" : 1.25
    "mpGridAndLimbOn" : False
    "mpGeophysicalLineColor" : 28
    "mpPerimOn" : True
    "mpPerimLineColor" : 28
    "vpXF"      : newvpx        ; set viewport
    "vpYF"      : newvpy
    "vpWidthF"  : newvpwidth
    "vpHeightF" : newvpheight
;
  end create
end if
;
if (domainname .eq. "236") then
  if (distance .lt. 500.) then
    setvalues mpid2
      "mpOutlineBoundarySets" : "AllBoundaries"
      "mpUSStateLineThicknessF" : 2
    end setvalues
  end if
end if
;
draw(mpid2)
gsres = True
gsres@gsLineColor = 31
gsres@gsLineThicknessF = 2
lons = new(2,float)
lats = new(2,float)
if (domainname .eq. "fim") then
  lons(0) = lon(startpts(1))
  lons(1) = lon(endpts(1))
  lats(0) = lat(startpts(0))
  lats(1) = lat(endpts(0))
end if
if (domainname .eq. "236") then
  lons(0) = lon(startpts(0),startpts(1))
  lons(1) = lon(endpts(0),endpts(1))
  lats(0) = lat(startpts(0),startpts(1))
  lats(1) = lat(endpts(0),endpts(1))
end if
gsn_polyline(wid,mpid2,lons,lats,gsres)
;
frame(wid)
;
end
;
