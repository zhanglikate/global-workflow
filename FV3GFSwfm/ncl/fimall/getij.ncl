;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
begin
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
  wstrid = 10
;
  uvar = grb_file->UW_4_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_4_HTGL(:,:) * 1.9429 ; convert to knots
;
end if
;
if (domainname .eq. "83") then
;
  ny = filevardimsizes(grb_file,"lat_83")
  nx = filevardimsizes(grb_file,"lon_83")
;
  intm = grb_file->T_83_SFC@initial_time
  fctm = grb_file->T_83_SFC@forecast_time
  lat = grb_file->lat_83(:)
  lon = grb_file->lon_83(:)
  wstrid = 10
;
  uvar = grb_file->UW_83_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_83_HTGL(:,:) * 1.9429 ; convert to knots
;
end if
;
if (domainname .eq. "130") then
;
  fimsizes = filevardimsizes(grb_file,"gridlat_130")
  ny = fimsizes(0)
  nx = fimsizes(1)
;
  intm = grb_file->T_130_SFC@initial_time
  fctm = grb_file->T_130_SFC@forecast_time
  lat = grb_file->gridlat_130(:,:)
  lon = grb_file->gridlon_130(:,:)
  latin1 = grb_file->gridlon_130@Latin1
  latin2 = grb_file->gridlon_130@Latin2
  lov = grb_file->gridlon_130@Lov
  wstrid = 7
;
  uvar = grb_file->UW_130_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_130_HTGL(:,:) * 1.9429 ; convert to knots
;
end if
;
if (domainname .eq. "174") then
;
  ny = filevardimsizes(grb_file,"lat_174")
  nx = filevardimsizes(grb_file,"lon_174")
;
  intm = grb_file->T_174_SFC@initial_time
  fctm = grb_file->T_174_SFC@forecast_time
  lat = grb_file->lat_174(:)
  lon = grb_file->lon_174(:)
  lonorig = lon
  fliplon = lonFlip(lon)
;  splitpt = toint(nx / 2)
;  firsthalflon = lon(:splitpt)
;  secndhalflon = lon(splitpt+1:)
;  shiftlon = 
;  print(firsthalflon)
;  print(secndhalflon)
;
; use this to get i,j from lat,lon
;  lon = fliplon  ; only use for africa and europe (or any domain that crosses 0 lon)
  lat2d = new((/ny,nx/),float)
  lon2d = new((/ny,nx/),float)
  do iny = 0,ny-1
    do inx = 0,nx-1
      lat2d(iny,inx) = lat(iny)
      lon2d(iny,inx) = lon(inx)
    end do
  end do
;
  RAOBLAT = 50.0
  RAOBLON = 130.0
  gridpts1 = wrf_latlon_to_ij(lat2d, lon2d, RAOBLAT, RAOBLON)
  print(gridpts1)
  wstrid = 50
;
  uvarorig = grb_file->UW_174_HTGL(::-1,:) * 1.9429 ; convert to knots
  uvar = uvarorig
  flipuvar = lonFlip(uvar)
  vvarorig = grb_file->VW_174_HTGL(::-1,:) * 1.9429 ; convert to knots
  vvar = vvarorig
  flipvvar = lonFlip(vvar)
;
end if
;
exit
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
  wstrid = 3
;
  uvar = grb_file->UW_236_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_236_HTGL(:,:) * 1.9429 ; convert to knots
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
  wstrid = 5
  if (domainname .eq. "floating") then
    wstrid = 2
  end if
  if (domainname .eq. "w_pacific" .or. domainname .eq. "e_pacific") then
    wstrid = 7
  end if
;
  uvar = grb_file->UW_GDS0_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_GDS0_HTGL(:,:) * 1.9429 ; convert to knots
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
  wstrid = 10
;
  uvar = grb_file->UW_219_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_219_HTGL(:,:) * 1.9429 ; convert to knots
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
  wstrid = 2
;
  uvar = grb_file->UW_28_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_28_HTGL(:,:) * 1.9429 ; convert to knots
  uvar = -uvar
  vvar = -vvar
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
  wstrid = 7
;
  uvar = grb_file->UW_244_HTGL(:,:) * 1.9429 ; convert to knots
  vvar = grb_file->VW_244_HTGL(:,:) * 1.9429 ; convert to knots
;
end if
;
end
