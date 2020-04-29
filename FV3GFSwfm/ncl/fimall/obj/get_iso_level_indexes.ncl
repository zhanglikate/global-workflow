; Get isobaric levels for u and v, height, temp
;
load "$NCL_HOME/obj/fim_grib_names.ncl"
;
if (isfilevar(grb_file,UISBL)) then
;
  utst = grb_file->$UISBL$(:,:,:)
  udims = dimsizes(utst)
  do ll = 0,15
    lnam = "lv_ISBL"+ll
    if (isfilevar(grb_file,lnam)) then
      ltst = grb_file->$lnam$
      ldim = dimsizes(ltst)
      if (udims(0) .eq. ldim) then
        break
      end if
      delete(lnam)
      delete(ltst)
      delete(ldim)
    end if
  end do
;
  levnam = grb_file->$lnam$
  levunits = grb_file->$lnam$@units
  if (levunits .eq. "Pa") then
    levnam = levnam / 100
  end if
  do ii = 0, dimsizes(levnam)-1
    if (levnam(ii) .eq. isolev) then
      level = ii
    end if
  end do
;
  delete(utst)
  delete(udims)
  delete(lnam)
  delete(ltst)
  delete(ldim)
  delete(levnam)
  delete(levunits)
;
  print(isolev+"mb, wind level index = "+level)
;
end if
;
if (isfilevar(grb_file,GHISBL)) then
;
  htst = grb_file->$GHISBL$(:,:,:)
  hdims = dimsizes(htst)
  do ll = 0,15
    lnam = "lv_ISBL"+ll
    if (isfilevar(grb_file,lnam)) then
      ltst = grb_file->$lnam$
      ldim = dimsizes(ltst)
      if (hdims(0) .eq. ldim) then
        break
      end if
      delete(lnam)
      delete(ltst)
      delete(ldim)
    end if
  end do
;
  levnam = grb_file->$lnam$
  levunits = grb_file->$lnam$@units
  if (levunits .eq. "Pa") then
    levnam = levnam / 100
  end if
  do ii = 0, dimsizes(levnam)-1
    if (levnam(ii) .eq. isolev) then
      levelh = ii
    end if
    if (levnam(ii) .eq. 500) then
      level500 = ii
    end if
    if (levnam(ii) .eq. 1000) then
      level1000 = ii
    end if
  end do
;
  delete(htst)
  delete(hdims)
  delete(lnam)
  delete(ltst)
  delete(ldim)
  delete(levnam)
  delete(levunits)
;
  print(isolev+"mb, hgt level index = "+levelh)
  print("500mb, hgt level index = "+level500)
  print("1000mb, hgt level index = "+level1000)
;
end if
;
if (isfilevar(grb_file,TISBL)) then
;
  ttst = grb_file->$TISBL$(:,:,:)
  tdims = dimsizes(ttst)
  do ll = 0,15
    lnam = "lv_ISBL"+ll
    if (isfilevar(grb_file,lnam)) then
      ltst = grb_file->$lnam$
      ldim = dimsizes(ltst)
      if (tdims(0) .eq. ldim) then
        break
      end if
      delete(lnam)
      delete(ltst)
      delete(ldim)
    end if
  end do
;
  levnam = grb_file->$lnam$
  levunits = grb_file->$lnam$@units
  if (levunits .eq. "Pa") then
    levnam = levnam / 100
  end if
  do ii = 0, dimsizes(levnam)-1
    if (levnam(ii) .eq. isolev) then
      levelt = ii
    end if
  end do
;
  delete(ttst)
  delete(tdims)
  delete(lnam)
  delete(ltst)
  delete(ldim)
  delete(levnam)
  delete(levunits)
;
  print(isolev+"mb, temp level index = "+levelt)
;
end if
;
if (isolev .ge. 100) then
;
  if (isfilevar(grb_file,VVEL)) then
;
    vvtst = grb_file->$VVEL$(:,:,:)
    vvdims = dimsizes(vvtst)
    do ll = 0,15
      lnam = "lv_ISBL"+ll
      if (isfilevar(grb_file,lnam)) then
        ltst = grb_file->$lnam$
        ldim = dimsizes(ltst)
        if (vvdims(0) .eq. ldim) then
          break
        end if
        delete(lnam)
        delete(ltst)
        delete(ldim)
      end if
    end do
;
    levnam = grb_file->$lnam$
    levunits = grb_file->$lnam$@units
    if (levunits .eq. "Pa") then
      levnam = levnam / 100
    end if
    do ii = 0, dimsizes(levnam)-1
      if (levnam(ii) .eq. isolev) then
        levelvv = ii
      end if
    end do
;
    delete(vvtst)
    delete(vvdims)
    delete(lnam)
    delete(ltst)
    delete(ldim)
    delete(levnam)
    delete(levunits)
;
    print(isolev+"mb, vvel level index = "+levelvv)
;
  end if
;
end if
;
if (isfilevar(grb_file,RHISBL)) then
;
  rhtst = grb_file->$RHISBL$(:,:,:)
  rhdims = dimsizes(rhtst)
  do ll = 0,15
    lnam = "lv_ISBL"+ll
    if (isfilevar(grb_file,lnam)) then
      ltst = grb_file->$lnam$
      ldim = dimsizes(ltst)
      if (rhdims(0) .eq. ldim) then
        break
      end if
      delete(lnam)
      delete(ltst)
      delete(ldim)
    end if
  end do
;
  levnam = grb_file->$lnam$
  levunits = grb_file->$lnam$@units
  if (levunits .eq. "Pa") then
    levnam = levnam / 100
  end if
  rhlevnam = levnam
  do ii = 0, dimsizes(levnam)-1
    if (levnam(ii) .eq. isolev) then
      levelrh = ii
    end if
  end do
;
  delete(rhtst)
  delete(rhdims)
  delete(lnam)
  delete(ltst)
  delete(ldim)
  delete(levnam)
  delete(levunits)
;
  print(isolev+"mb, rh level index = "+levelrh)
;
end if
; 

