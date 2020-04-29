load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
;
function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/1.000,1.000,1.000/), \   ; 0 (background)
                (/.000,.000,.000/), \   ; 1 (foreground)
                (/.000,.184,1.000/), \     ; 2
                (/.082,.506,1.000/), \     ; 3
                (/.141,.675,.925/), \      ; 4
                (/.000,.890,.902/), \      ; 5
                (/.392,.392,.392/), \      ; 20
                (/.500,.500,.500/) /) )    ; 21
end
;
begin
;
;  ny = 65
;  nx = 65
;  ny = 129
;  nx = 129
  ny = 259
  nx = 259
;
xdim = nx - 1
ydim = ny - 1
rnx = 1.*xdim
rny = 1.*ydim
if (rny .ge. rnx) then
  vpheight = 1.
  vpy = 1.-((1.-vpheight)/2.)
  vpwidth = (vpheight/rny)*rnx
  vpx = (1.-((vpheight/rny)*rnx))/2.
else
  vpwidth = 1.
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
    NCGM=0
    X11=0
    PS=1
;
    if (NCGM .eq. 1) then
;
; Create an ncgmWorkstation object.
;
        wid = create "mdssWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./201test.ncgm"
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
;          wid = create "mdssWork" psWorkstationClass defaultapp
            wid = gsn_open_wks("png","./201test.png")
;           "wkPSFileName" : "./201test.ps"
;          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
;
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;gsn_draw_colormap(wid)
;frame(wid)
;exit
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "Stereographic"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpCenterLatF" : 90
    "mpCenterLonF" : 255
    "mpLeftCornerLonF" : 210
    "mpLeftCornerLatF" : -20.826
    "mpRightCornerLonF" : 30
    "mpRightCornerLatF" : -20.826
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States"/)
    "mpUSStateLineColor" : "foreground"
    "mpUSStateLineThicknessF" : 1
    "mpGridAndLimbOn" : True
    "mpGridLatSpacingF" : 10
    "mpGridLonSpacingF" : 10
    "mpGeophysicalLineColor" : "foreground"
    "mpGeophysicalLineThicknessF" : 1
    "mpNationalLineColor" : "foreground"
    "mpNationalLineThicknessF" : 1
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
draw(mpid)
;
gsres = True
do i = 0,nx-1
  ri = i/(nx-1.0)
  do j = 0,ny-1
    rj = j/(ny-1.0)
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 2
    gsres@gsMarkerSizeF = 0.001
    gsn_polymarker_ndc(wid,ri,rj,gsres)
  end do
end do
;
frame(wid)
end
;

