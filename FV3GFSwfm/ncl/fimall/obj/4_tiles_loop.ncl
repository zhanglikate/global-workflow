; do loop to make subdomain tiles for domain 4 (global lat-lon 0.5 deg)
;
do iq = 0,1
;
if (iq .eq. 0) then ; full domain
  llx = 0
  lly = 0
  urx = nx - 1
  ury = ny - 1
  wstrid = 10
end if
;
if (iq .eq. 1) then ; Taiwan
  llx = 228
  lly = 214
  urx = 255
  ury = 241
  wstrid = 1
end if
;
tmpnx = urx - llx
tmpny = ury - lly
xdim = tmpnx
ydim = tmpny
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
LcLon = lon(llx)
LcLat = lat(lly)
RcLon = lon(urx)
RcLat = lat(ury)

