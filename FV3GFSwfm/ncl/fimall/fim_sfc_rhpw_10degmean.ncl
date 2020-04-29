;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
theos = systemfunc("uname")
modl = getenv("MODL")
;
load "$NCL_HOME/obj/cmap1b.ncl"
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
if (domainname .eq. "fim") then
;
  ny = filevardimsizes(grb_file,"lat_4")
  nx = filevardimsizes(grb_file,"lon_4")
;
  intm = grb_file->T_4_SFC@initial_time
  fctm = grb_file->T_4_SFC@forecast_time
  lat = grb_file->lat_4(:)
  lon = grb_file->lon_4(:)
  tvar = grb_file->CNWAT_4_EATM(:,:) * 100
;  tvar = grb_file->PW_4_SFC(:,:)
;
end if
;
if (domainname .eq. "236") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_236")
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  intm = grb_file->T_236_SFC@initial_time
  fctm = grb_file->T_236_SFC@forecast_time
  lat = grb_file->gridlat_236(:,:)
  lon = grb_file->gridlon_236(:,:)
  latin1 = grb_file->gridlon_236@Latin1
  latin2 = grb_file->gridlon_236@Latin2
  lov = grb_file->gridlon_236@Lov
  tvar = grb_file->CNWAT_236_EATM(:,:) * 100
;
end if
;
if (domainname .eq. "africa" .or. domainname .eq. "europe" .or. \
    domainname .eq. "w_pacific" .or. domainname .eq. "floating" .or. \
    domainname .eq. "e_pacific") then
;
  nx = filevardimsizes(grb_file,"g0_lon_2")
  ny = filevardimsizes(grb_file,"g0_lat_1")
;
  intm = grb_file->T_GDS0_SFC@initial_time
  fctm = grb_file->T_GDS0_SFC@forecast_time
  lat = grb_file->g0_lat_1(:)
  lon = grb_file->g0_lon_2(:)
  tvar = grb_file->CNWAT_GDS0_EATM(:,:) * 100
;
end if
;
if (domainname .eq. "219") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_219")
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  intm = grb_file->T_219_SFC@initial_time
  fctm = grb_file->T_219_SFC@forecast_time
  lat = grb_file->gridlat_219(:,:)
  lon = grb_file->gridlon_219(:,:)
  tvar = grb_file->CNWAT_219_EATM(:,:) * 100
;
end if
;
if (domainname .eq. "28") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_28")
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  intm = grb_file->T_28_SFC@initial_time
  fctm = grb_file->T_28_SFC@forecast_time
  lat = grb_file->gridlat_28(:,:)
  lon = grb_file->gridlon_28(:,:)
  tvar = grb_file->CNWAT_28_EATM(:,:) * 100
;
end if
;
if (domainname .eq. "244") then
;
  ny = filevardimsizes(grb_file,"lat_244")
  nx = filevardimsizes(grb_file,"lon_244")
;
  intm = grb_file->T_244_SFC@initial_time
  fctm = grb_file->T_244_SFC@forecast_time
  lat = grb_file->lat_244(:)
  lon = grb_file->lon_244(:)
  tvar = grb_file->CNWAT_244_EATM(:,:) * 100
;
end if
;
load "$NCL_HOME/obj/get_date_str_FIM.ncl"
;
print(date_str)
print("RH wrt PW")
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
lat7565N = 0.
lat6555N = 0.
lat5545N = 0.
lat4535N = 0.
lat3525N = 0.
lat2515N = 0.
lat1505N = 0.
lat0505N = 0.
lat0515S = 0.
lat1525S = 0.
lat2535S = 0.
lat3545S = 0.
lat4555S = 0.
lat5565S = 0.
lat6575S = 0.
;
lat7565Ntally = 0.
lat6555Ntally = 0.
lat5545Ntally = 0.
lat4535Ntally = 0.
lat3525Ntally = 0.
lat2515Ntally = 0.
lat1505Ntally = 0.
lat0505Ntally = 0.
lat0515Stally = 0.
lat1525Stally = 0.
lat2535Stally = 0.
lat3545Stally = 0.
lat4555Stally = 0.
lat5565Stally = 0.
lat6575Stally = 0.
;
lat7565Navg = 0.
lat6555Navg = 0.
lat5545Navg = 0.
lat4535Navg = 0.
lat3525Navg = 0.
lat2515Navg = 0.
lat1505Navg = 0.
lat0505Navg = 0.
lat0515Savg = 0.
lat1525Savg = 0.
lat2535Savg = 0.
lat3545Savg = 0.
lat4555Savg = 0.
lat5565Savg = 0.
lat6575Savg = 0.
;
do ilon = 0,xdim
do jlat = 0,ydim
  if (lat(jlat) .le. 75 .and. lat(jlat) .gt. 65) then
    lat7565N = lat7565N + tvar(jlat,ilon)
    lat7565Ntally = lat7565Ntally + 1.
  end if
  if (lat(jlat) .le. 65 .and. lat(jlat) .gt. 55) then
    lat6555N = lat6555N + tvar(jlat,ilon)
    lat6555Ntally = lat6555Ntally + 1.
  end if
  if (lat(jlat) .le. 55 .and. lat(jlat) .gt. 45) then
    lat5545N = lat5545N + tvar(jlat,ilon)
    lat5545Ntally = lat5545Ntally + 1.
  end if
  if (lat(jlat) .le. 45 .and. lat(jlat) .gt. 35) then
    lat4535N = lat4535N + tvar(jlat,ilon)
    lat4535Ntally = lat4535Ntally + 1.
  end if
  if (lat(jlat) .le. 35 .and. lat(jlat) .gt. 25) then
    lat3525N = lat3525N + tvar(jlat,ilon)
    lat3525Ntally = lat3525Ntally + 1.
  end if
  if (lat(jlat) .le. 25 .and. lat(jlat) .gt. 15) then
    lat2515N = lat2515N + tvar(jlat,ilon)
    lat2515Ntally = lat2515Ntally + 1.
  end if
  if (lat(jlat) .le. 15 .and. lat(jlat) .gt. 5) then
    lat1505N = lat1505N + tvar(jlat,ilon)
    lat1505Ntally = lat1505Ntally + 1.
  end if
  if (lat(jlat) .le. 5 .and. lat(jlat) .gt. -5) then
    lat0505N = lat0505N + tvar(jlat,ilon)
    lat0505Ntally = lat0505Ntally + 1.
  end if
  if (lat(jlat) .le. -5 .and. lat(jlat) .gt. -15) then
    lat0515S = lat0515S + tvar(jlat,ilon)
    lat0515Stally = lat0515Stally + 1.
  end if
  if (lat(jlat) .le. -15 .and. lat(jlat) .gt. -25) then
    lat1525S = lat1525S + tvar(jlat,ilon)
    lat1525Stally = lat1525Stally + 1.
  end if
  if (lat(jlat) .le. -25 .and. lat(jlat) .gt. -35) then
    lat2535S = lat2535S + tvar(jlat,ilon)
    lat2535Stally = lat2535Stally + 1.
  end if
  if (lat(jlat) .le. -35 .and. lat(jlat) .gt. -45) then
    lat3545S = lat3545S + tvar(jlat,ilon)
    lat3545Stally = lat3545Stally + 1.
  end if
  if (lat(jlat) .le. -45 .and. lat(jlat) .gt. -55) then
    lat4555S = lat4555S + tvar(jlat,ilon)
    lat4555Stally = lat4555Stally + 1.
  end if
  if (lat(jlat) .le. -55 .and. lat(jlat) .gt. -65) then
    lat5565S = lat5565S + tvar(jlat,ilon)
    lat5565Stally = lat5565Stally + 1.
  end if
  if (lat(jlat) .le. -65 .and. lat(jlat) .gt. -75) then
    lat6575S = lat6575S + tvar(jlat,ilon)
    lat6575Stally = lat6575Stally + 1.
  end if
end do
end do
;
print("7565 = "+lat7565Ntally)
print("6555 = "+lat6555Ntally)
print("5545 = "+lat5545Ntally)
print("4535 = "+lat4535Ntally)
print("3525 = "+lat3525Ntally)
print("2515 = "+lat2515Ntally)
print("1505 = "+lat1505Ntally)
print("0505 = "+lat0505Ntally)
print("0515 = "+lat0515Stally)
print("1525 = "+lat1525Stally)
print("2535 = "+lat2535Stally)
print("3545 = "+lat3545Stally)
print("4555 = "+lat4555Stally)
print("5565 = "+lat5565Stally)
print("6575 = "+lat6575Stally)
;
lat7565Navg = lat7565N / lat7565Ntally
lat6555Navg = lat6555N / lat6555Ntally
lat5545Navg = lat5545N / lat5545Ntally
lat4535Navg = lat4535N / lat4535Ntally
lat3525Navg = lat3525N / lat3525Ntally
lat2515Navg = lat2515N / lat2515Ntally
lat1505Navg = lat1505N / lat1505Ntally
lat0505Navg = lat0505N / lat0505Ntally
lat0515Savg = lat0515S / lat0515Stally
lat1525Savg = lat1525S / lat1525Stally
lat2535Savg = lat2535S / lat2535Stally
lat3545Savg = lat3545S / lat3545Stally
lat4555Savg = lat4555S / lat4555Stally
lat5565Savg = lat5565S / lat5565Stally
lat6575Savg = lat6575S / lat6575Stally
;
print("lat7565Navg = "+lat7565Navg)
print("lat6555Navg = "+lat6555Navg)
print("lat5545Navg = "+lat5545Navg)
print("lat4535Navg = "+lat4535Navg)
print("lat3525Navg = "+lat3525Navg)
print("lat2515Navg = "+lat2515Navg)
print("lat1505Navg = "+lat1505Navg)
print("lat0505Navg = "+lat0505Navg)
print("lat0515Savg = "+lat0515Savg)
print("lat1525Savg = "+lat1525Savg)
print("lat2535Savg = "+lat2535Savg)
print("lat3545Savg = "+lat3545Savg)
print("lat4555Savg = "+lat4555Savg)
print("lat5565Savg = "+lat5565Savg)
print("lat6575Savg = "+lat6575Savg)
;
xvals = (/ -70.0, -60.0, -50.0, -40.0, -30.0, -20.0, -10.0, 0.0, \
            10.0,  20.0,  30.0,  40.0,  50.0,  60.0,  70,0 /)
rhpwyvals = (/ lat6575Savg, lat5565Savg, lat4555Savg, lat3545Savg, \
               lat2535Savg, lat1525Savg, lat0515Savg, lat0505Navg, \
               lat1505Navg, lat2515Navg, lat3525Navg, lat4535Navg, \
               lat5545Navg, lat6555Navg, lat7565Navg /)
;
; now get the PW and make a new yvals array
;
delete(tvar)
tvar = grb_file->PW_4_SFC(:,:)
;
lat7565N = 0.
lat6555N = 0.
lat5545N = 0.
lat4535N = 0.
lat3525N = 0.
lat2515N = 0.
lat1505N = 0.
lat0505N = 0.
lat0515S = 0.
lat1525S = 0.
lat2535S = 0.
lat3545S = 0.
lat4555S = 0.
lat5565S = 0.
lat6575S = 0.
;
lat7565Ntally = 0.
lat6555Ntally = 0.
lat5545Ntally = 0.
lat4535Ntally = 0.
lat3525Ntally = 0.
lat2515Ntally = 0.
lat1505Ntally = 0.
lat0505Ntally = 0.
lat0515Stally = 0.
lat1525Stally = 0.
lat2535Stally = 0.
lat3545Stally = 0.
lat4555Stally = 0.
lat5565Stally = 0.
lat6575Stally = 0.
;
lat7565Navg = 0.
lat6555Navg = 0.
lat5545Navg = 0.
lat4535Navg = 0.
lat3525Navg = 0.
lat2515Navg = 0.
lat1505Navg = 0.
lat0505Navg = 0.
lat0515Savg = 0.
lat1525Savg = 0.
lat2535Savg = 0.
lat3545Savg = 0.
lat4555Savg = 0.
lat5565Savg = 0.
lat6575Savg = 0.
;
do ilon = 0,xdim
do jlat = 0,ydim
  if (lat(jlat) .le. 75 .and. lat(jlat) .gt. 65) then
    lat7565N = lat7565N + tvar(jlat,ilon)
    lat7565Ntally = lat7565Ntally + 1.
  end if
  if (lat(jlat) .le. 65 .and. lat(jlat) .gt. 55) then
    lat6555N = lat6555N + tvar(jlat,ilon)
    lat6555Ntally = lat6555Ntally + 1.
  end if
  if (lat(jlat) .le. 55 .and. lat(jlat) .gt. 45) then
    lat5545N = lat5545N + tvar(jlat,ilon)
    lat5545Ntally = lat5545Ntally + 1.
  end if
  if (lat(jlat) .le. 45 .and. lat(jlat) .gt. 35) then
    lat4535N = lat4535N + tvar(jlat,ilon)
    lat4535Ntally = lat4535Ntally + 1.
  end if
  if (lat(jlat) .le. 35 .and. lat(jlat) .gt. 25) then
    lat3525N = lat3525N + tvar(jlat,ilon)
    lat3525Ntally = lat3525Ntally + 1.
  end if
  if (lat(jlat) .le. 25 .and. lat(jlat) .gt. 15) then
    lat2515N = lat2515N + tvar(jlat,ilon)
    lat2515Ntally = lat2515Ntally + 1.
  end if
  if (lat(jlat) .le. 15 .and. lat(jlat) .gt. 5) then
    lat1505N = lat1505N + tvar(jlat,ilon)
    lat1505Ntally = lat1505Ntally + 1.
  end if
  if (lat(jlat) .le. 5 .and. lat(jlat) .gt. -5) then
    lat0505N = lat0505N + tvar(jlat,ilon)
    lat0505Ntally = lat0505Ntally + 1.
  end if
  if (lat(jlat) .le. -5 .and. lat(jlat) .gt. -15) then
    lat0515S = lat0515S + tvar(jlat,ilon)
    lat0515Stally = lat0515Stally + 1.
  end if
  if (lat(jlat) .le. -15 .and. lat(jlat) .gt. -25) then
    lat1525S = lat1525S + tvar(jlat,ilon)
    lat1525Stally = lat1525Stally + 1.
  end if
  if (lat(jlat) .le. -25 .and. lat(jlat) .gt. -35) then
    lat2535S = lat2535S + tvar(jlat,ilon)
    lat2535Stally = lat2535Stally + 1.
  end if
  if (lat(jlat) .le. -35 .and. lat(jlat) .gt. -45) then
    lat3545S = lat3545S + tvar(jlat,ilon)
    lat3545Stally = lat3545Stally + 1.
  end if
  if (lat(jlat) .le. -45 .and. lat(jlat) .gt. -55) then
    lat4555S = lat4555S + tvar(jlat,ilon)
    lat4555Stally = lat4555Stally + 1.
  end if
  if (lat(jlat) .le. -55 .and. lat(jlat) .gt. -65) then
    lat5565S = lat5565S + tvar(jlat,ilon)
    lat5565Stally = lat5565Stally + 1.
  end if
  if (lat(jlat) .le. -65 .and. lat(jlat) .gt. -75) then
    lat6575S = lat6575S + tvar(jlat,ilon)
    lat6575Stally = lat6575Stally + 1.
  end if
end do
end do
;
print("7565 = "+lat7565Ntally)
print("6555 = "+lat6555Ntally)
print("5545 = "+lat5545Ntally)
print("4535 = "+lat4535Ntally)
print("3525 = "+lat3525Ntally)
print("2515 = "+lat2515Ntally)
print("1505 = "+lat1505Ntally)
print("0505 = "+lat0505Ntally)
print("0515 = "+lat0515Stally)
print("1525 = "+lat1525Stally)
print("2535 = "+lat2535Stally)
print("3545 = "+lat3545Stally)
print("4555 = "+lat4555Stally)
print("5565 = "+lat5565Stally)
print("6575 = "+lat6575Stally)
;
lat7565Navg = lat7565N / lat7565Ntally
lat6555Navg = lat6555N / lat6555Ntally
lat5545Navg = lat5545N / lat5545Ntally
lat4535Navg = lat4535N / lat4535Ntally
lat3525Navg = lat3525N / lat3525Ntally
lat2515Navg = lat2515N / lat2515Ntally
lat1505Navg = lat1505N / lat1505Ntally
lat0505Navg = lat0505N / lat0505Ntally
lat0515Savg = lat0515S / lat0515Stally
lat1525Savg = lat1525S / lat1525Stally
lat2535Savg = lat2535S / lat2535Stally
lat3545Savg = lat3545S / lat3545Stally
lat4555Savg = lat4555S / lat4555Stally
lat5565Savg = lat5565S / lat5565Stally
lat6575Savg = lat6575S / lat6575Stally
;
print("lat7565Navg = "+lat7565Navg)
print("lat6555Navg = "+lat6555Navg)
print("lat5545Navg = "+lat5545Navg)
print("lat4535Navg = "+lat4535Navg)
print("lat3525Navg = "+lat3525Navg)
print("lat2515Navg = "+lat2515Navg)
print("lat1505Navg = "+lat1505Navg)
print("lat0505Navg = "+lat0505Navg)
print("lat0515Savg = "+lat0515Savg)
print("lat1525Savg = "+lat1525Savg)
print("lat2535Savg = "+lat2535Savg)
print("lat3545Savg = "+lat3545Savg)
print("lat4555Savg = "+lat4555Savg)
print("lat5565Savg = "+lat5565Savg)
print("lat6575Savg = "+lat6575Savg)
;
pwyvals = (/ lat6575Savg, lat5565Savg, lat4555Savg, lat3545Savg, \
             lat2535Savg, lat1525Savg, lat0515Savg, lat0505Navg, \
             lat1505Navg, lat2515Navg, lat3525Navg, lat4535Navg, \
             lat5545Navg, lat6555Navg, lat7565Navg /)
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
           "wkMetaName" : "./sfc_rhpw.ncgm"
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
           "wkPSFileName" : "./sfc_rhpw.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
   "wkColorMap" : gen_colormap()
   "wkBackgroundColor" : "white"
   "wkForegroundColor" : "black"
end setvalues
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
field1 = create "field1" coordArraysClass defaultapp
    "caYArray": rhpwyvals
    "caXArray": xvals
end create
;
field2 = create "field2" coordArraysClass defaultapp
    "caYArray": pwyvals
    "caXArray": xvals
end create
;
xy1 = create "xy1" xyPlotClass wid
    "xyCoordData": field1
    "trYMaxF" :  100.
    "trYMinF" :  0.
    "trXMaxF" :   90.
    "trXMinF" :  -90.
    "tmYROn"    : False
    "tmYUseLeft" : False
    "tmYLLabelsOn"    : True
    "tmYLMode"  : "Explicit"
    "tmYLValues"  : (/0.,10.,20.,30.,40.,50.,60.,70.,80.,90.,100./)
    "tmYLLabels"  : (/"0","10","20","30","40","50","60","70","80","90","100"/)
    "tmYLLabelFont" : 22
    "tmYLLabelFontThicknessF" : 2.0
    "tmYLLabelFontColor" : "red"
    "tmYRMinorOn" : False
    "tmXBLabelFont" : 22
    "tmXBLabelFontThicknessF" : 2.0
    "tiMainFont": 26
    "tiMainFontHeightF": .03
    "tiMainString": "Mean RHPW and PW"
    "tiXAxisFont": 22
    "tiXAxisFontThicknessF": 2.0
    "tiXAxisString": "Latitude"
    "tiYAxisFont": 22
    "tiYAxisFontColor" : "red"
    "tiYAxisFontThicknessF": 2.0
    "tiYAxisString": "RHPW (%)"
end create
;
xy2 = create "xy2" xyPlotClass wid
    "xyCoordData": field2
    "trYMaxF" :  100.
    "trYMinF" :  0.
    "trXMaxF" :   90.
    "trXMinF" :  -90.
    "tmYROn" : True
    "tmYLOn" : False
    "tmXBOn" : False
    "tmYUseLeft" : False
    "tmYRLabelsOn" : True
    "tmYRMode"  : "Explicit"
    "tmYRValues"  : (/0.,10.,20.,30.,40.,50.,60.,70.,80.,90.,100./)
    "tmYRLabels"  : (/"0","10","20","30","40","50","60","70","80","90","100"/)
    "tmYRLabelFont" : 22
    "tmYRLabelFontThicknessF" : 2.0
    "tmYRLabelFontColor" : "blue"
    "tiYAxisSide": "Right"
    "tiYAxisFont": 22
    "tiYAxisFontColor" : "blue"
    "tiYAxisFontThicknessF": 2.0
    "tiYAxisString": "PW (mm)"
end create
;
getvalues xy1
    "xyCoordDataSpec" : spec1
end getvalues
;
setvalues spec1
   "xyMonoLineColor" : "true"
   "xyLineColor" : "red"
   "xyLineThicknessF" : 2.0
end setvalues
;
getvalues xy2
    "xyCoordDataSpec" : spec2
end getvalues
;
setvalues spec2
   "xyMonoLineColor" : "true"
   "xyLineColor" : "blue"
   "xyLineThicknessF" : 2.0
end setvalues
;
draw(xy1)
draw(xy2)
frame(wid)
;
end
;
