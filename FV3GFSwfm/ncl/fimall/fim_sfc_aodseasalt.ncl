;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
modl = getenv("MODL")
;
load "$NCL_HOME/obj/cmap_aod.ncl"
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
intm = grb_file->$TISBL$@initial_time
fctm = grb_file->$TISBL$@forecast_time
fctmunits = grb_file->$TISBL$@forecast_time_units
if (fctmunits .ne. "hours") then
  fctm = fctm * tointeger(fctmunits)
end if
;
if (domainname .eq. "fim") then
;
  ny = filevardimsizes(grb_file,LAT)
  nx = filevardimsizes(grb_file,LON)
;
  lon = grb_file->$LON$(:)
  if (fv3) then
    lat = grb_file->$LAT$(::-1)
    tvar = grb_file->$AODSEASALTSFC$(::-1,:) ; AOD sea salt
  else
    lat = grb_file->$LAT$(:)
    tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
  end if
;
end if
;
if (domainname .eq. "129") then
;
  ny = filevardimsizes(grb_file,LAT)
  nx = filevardimsizes(grb_file,LON)
;
  lat = grb_file->$LAT$(:)
  lon = grb_file->$LON$(:)
  tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;  hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
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
  tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;  hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
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
  tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;  hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
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
  tvar = grb_file->$AODSEASALTSFC$(::-1,:) ; AOD sea salt
  tvarorig = tvar
  fliptvar = lonFlip(tvar)
;  hvar = grb_file->$GHISBL$(level,::-1,:) / 10. ; convert to decameters
;  hvarorig = hvar
;  fliphvar = lonFlip(hvar)
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
  tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;  hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
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
  tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;  hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
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
    tvar = grb_file->$AODSEASALTSFC$(::-1,:) ; AOD sea salt
;    hvar = grb_file->$GHISBL$(level,::-1,:) / 10. ; use decameters
  else
    lat = grb_file->$LAT$(:)
    tvar = grb_file->$AODSEASALTSFC$(:,:) ; AOD sea salt
;    hvar = grb_file->$GHISBL$(level,:,:) / 10. ; use decameters
  end if
;
end if
;
tvarsave = tvar
;tvar = tvar * 10.
;do ii = 0,nx-1
;  do jj = 0,ny-1
;    if (tvar(jj,ii) .lt. 2.) then
;      tvar(jj,ii) = 1.
;    end if
;  end do
;end do
;tvar = log10(tvar)
;
load "$NCL_HOME/obj/get_date_str_FIM.ncl"
;
print(date_str) 
print("AOD Sea Salt")
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
           "wkMetaName" : "./sfc_aodseasalt.ncgm"
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
           "wkPSFileName" : "./sfc_aodseasalt.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;setvalues wid
;   "wkColorMap" : "WhiteBlueGreenYellowRed"
;   "wkBackgroundColor" : "black"
;   "wkForegroundColor" : "white"
;end setvalues
;NhlSetColor(wid,255,0.55,0.14,0.80)
;NhlSetColor(wid,254,0.5,0.5,0.5)
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
; Create a ScalarField object.
;
tvarsave = tvar
;
if (domainname .eq. "fim") then
;
  load "$NCL_HOME/obj/4_tiles_loop.ncl"
;
  tvar = tvarsave
  if (min(tvar(lly:ury,llx:urx)) .lt. 0.1 .and. max(tvar(lly:ury,llx:urx)) .lt. 0.1) then
    tvar(lly,llx) = .12
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
;  hfield = create "ScalarField" scalarFieldClass appid
;      "sfDataArray" : hvar
;      "sfXCStartSubsetV" : llx
;      "sfYCStartSubsetV" : lly
;      "sfXCEndSubsetV" : urx
;      "sfYCEndSubsetV" : ury
;      "sfMissingValueV" : hvar@_FillValue
;  end create
;
;  load "$NCL_HOME/obj/intfd.ncl"
  load "$NCL_HOME/obj/pwtr.ncl"
;
  setvalues cnid
    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16 /)
    "cnLevels" : (/ .1,.16,.23,.29,.36,.42,.49,.55,.61,.68,.74,.81,.87,1 /)
  end setvalues
;
  if (iq .ne. 0) then
    setvalues cnid
      "cnFillMode" : "AreaFill"
    end setvalues
  end if
;
;  load "$NCL_HOME/obj/height_60m.ncl"
;
  titlestring = "Sea Salt Aerosol Optical Depth"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
  draw(cnid)
  draw(mpid)
;  draw(cnid4)
;
  gsres = True
  if (iq .eq. 0) then
;    do i = 0,dimsizes(airport_id)-1
;      gsres@gsMarkerIndex = 16
;      gsres@gsMarkerColor = 17
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
      gsres@gsMarkerColor = 17
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
  tvar = tvarsave
  if (min(tvar(lly:ury,llx:urx)) .lt. 0.1 .and. max(tvar(lly:ury,llx:urx)) .lt. 0.1) then
    tvar(lly,llx) = .12
  end if
;
  if (iq .eq. 0) then
    load "$NCL_HOME/obj/lambert_conformal_map_blk.ncl"
  else
    load "$NCL_HOME/obj/lc_map_counties.ncl"
    setvalues mpid
      "mpNationalLineColor" : "background"
      "mpCountyLineColor" : "background"
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
;  hfield = create "ScalarField" scalarFieldClass appid
;      "sfDataArray" : hvar
;      "sfXCStartSubsetV" : llx
;      "sfYCStartSubsetV" : lly
;      "sfXCEndSubsetV" : urx
;      "sfYCEndSubsetV" : ury
;      "sfMissingValueV" : hvar@_FillValue
;  end create
;
;  load "$NCL_HOME/obj/intfd.ncl"
  load "$NCL_HOME/obj/pwtr.ncl"
;
  setvalues cnid
    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16 /)
    "cnLevels" : (/ .1,.16,.23,.29,.36,.42,.49,.55,.61,.68,.74,.81,.87,1 /)
    "cnRasterModeOn" : False
  end setvalues
;
;  load "$NCL_HOME/obj/height_60m.ncl"
;
  titlestring = "Sea Salt Aerosol Optical Depth"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(mpid)
;  draw(cnid4)
;
  gsres = True
  if (iq .eq. 0) then
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 17
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
      gsres@gsMarkerColor = 17
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
  tvar = tvarsave
  if (min(tvar(lly:ury,llx:urx)) .lt. 0.1 .and. max(tvar(lly:ury,llx:urx)) .lt. 0.1) then
    tvar(lly,llx) = .12
  end if
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
;  hfield = create "ScalarField" scalarFieldClass appid
;      "sfDataArray" : hvar
;      "sfXCStartSubsetV" : llx
;      "sfYCStartSubsetV" : lly
;      "sfXCEndSubsetV" : urx
;      "sfYCEndSubsetV" : ury
;      "sfMissingValueV" : hvar@_FillValue
;  end create
;
  load "$NCL_HOME/obj/intfd.ncl"
;
;  load "$NCL_HOME/obj/height_60m.ncl"
;
  titlestring = "Sea Salt Aerosol Optical Depth"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(mpid)
;  draw(cnid4)
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
  tvar = tvarsave
  if (min(tvar(lly:ury,llx:urx)) .lt. 0.1 .and. max(tvar(lly:ury,llx:urx)) .lt. 0.1) then
    tvar(lly,llx) = .12
  end if
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
;  hfield = create "ScalarField" scalarFieldClass appid
;      "sfDataArray" : hvar
;      "sfXCStartSubsetV" : llx
;      "sfYCStartSubsetV" : lly
;      "sfXCEndSubsetV" : urx
;      "sfYCEndSubsetV" : ury
;      "sfMissingValueV" : hvar@_FillValue
;  end create
;
;  load "$NCL_HOME/obj/intfd.ncl"
  load "$NCL_HOME/obj/pwtr.ncl"
;
  setvalues cnid
    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16 /)
    "cnLevels" : (/ .1,.16,.23,.29,.36,.42,.49,.55,.61,.68,.74,.81,.87,1 /)
    "cnFillMode" : "AreaFill"
  end setvalues
;
;  load "$NCL_HOME/obj/height_60m.ncl"
;
  titlestring = "Sea Salt Aerosol Optical Depth"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(mpid)
;  draw(cnid4)
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
; Create a ScalarField object.
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
;    hfield = create "ScalarField" scalarFieldClass appid
;        "sfDataArray" : hvar
;        "sfXCStartV" : 0
;        "sfYCStartV" : ydim
;        "sfXCEndV" : xdim
;        "sfYCEndV" : 0
;        "sfMissingValueV" : hvar@_FillValue
;    end create
;
  end if
;
  if (domainname .eq. "236" .or. domainname .eq. "201" .or. domainname .eq. "224" .or. \
      domainname .eq. "83") then
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
;    hfield = create "ScalarField" scalarFieldClass appid
;        "sfDataArray" : hvar
;        "sfXCStartV" : 0
;        "sfYCStartV" : 0
;        "sfXCEndV" : xdim
;        "sfYCEndV" : ydim
;        "sfMissingValueV" : hvar@_FillValue
;    end create
;
  end if
;
;  load "$NCL_HOME/obj/intfd.ncl"
  load "$NCL_HOME/obj/pwtr.ncl"
;
  setvalues cnid
    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16 /)
    "cnLevels" : (/ .1,.16,.23,.29,.36,.42,.49,.55,.61,.68,.74,.81,.87,1 /)
  end setvalues
;
  if (domainname .eq. "236" .or. domainname .eq. "244" .or. domainname .eq. "83" .or. \
      domainname .eq. "201" .or. domainname .eq. "224") then
;
    setvalues cnid
      "cnRasterModeOn" : False
    end setvalues
;
  end if
;
;  load "$NCL_HOME/obj/height_60m.ncl"
;
;  if (domainname .eq. "fim" .or. domainname .eq. "129") then
;    setvalues cnid4
;      "cnLineThicknessF" : 1
;      "cnLineLabelDensityF" : 0.001
;    end setvalues
;  end if
;;
;  if (domainname .eq. "201") then
;    setvalues cnid4
;      "cnLineLabelDensityF" : 0.001
;    end setvalues
;  end if
;
  titlestring = "Sea Salt Aerosol Optical Depth"
  load "$NCL_HOME/obj/add_titles.ncl"
  load "$NCL_HOME/obj/add_explabel.ncl"
;
; Draw map
;
  draw(cnid)
  draw(mpid)
;  draw(cnid4)
;
  gsres = True
  if (domainname .eq. "236") then
    do i = 0,dimsizes(airport_id)-1
      gsres@gsMarkerIndex = 16
      gsres@gsMarkerColor = 17
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

