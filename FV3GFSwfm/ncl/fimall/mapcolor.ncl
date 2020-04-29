load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("x11","map")

  mpres               = True

  mpres@gsnMaximize         = True

  mpres@mpOutlineOn         = True
  mpres@mpFillOn            = False  

;---Zoom in on area of interest
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLonF             = -130 
  mpres@mpMaxLonF             =  -60
  mpres@mpMinLatF             =  20
  mpres@mpMaxLatF             =  60
  mpres@mpCenterLonF          = -95

  mpres@mpOutlineBoundarySets   = "AllBoundaries"
  mpres@mpUSStateLineColor      = "purple"
  mpres@mpUSStateLineThicknessF = 5.0


  map = gsn_csm_map(wks,mpres)
end
