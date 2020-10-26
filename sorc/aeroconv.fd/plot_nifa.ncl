;---------------------------------------------------------------
;  NCL User Guide Example: NUG_triangular_grid_ICON.ncl
;
;  Grid type:         ICON - Unstructured grid
;
;  Settings:          sub-region,
;                     manual-levels,
;                     draw colored triangles with outlines,
;                     don't draw missing values
;  KMF 31.10.14
;---------------------------------------------------------------

;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

CASE="C768"
NX=768
NY=768

begin
  start_code_time = get_cpu_time()

  diri = "./INPUT/"
  fi = "grid_spec.tile1.nc"

  if (.not. fileexists(diri+fi)) then
     print(diri+fi)
     print("You don't have the necessary data for this script. Bad luck for you!")
     print("")
     exit
  end if

  ff = addfile(diri+fi, "r")
  x=ff->grid_lont
  imax=NX*NY*6
  var=new((/imax/),typeof(x))
  var1=new((/imax/),typeof(x))
  lonn=new((/imax/),typeof(x))
  latn=new((/imax/),typeof(x))
;  ll=62
;  it=0
  in=0

  do iy=1,6
    dir = "./INPUT/"
    fv3 = "grid_spec.tile"+iy+".nc"
    f = addfile(dir+fv3, "r")
    dir3 = "./OUTPUT/"
    f3 = "gfs_data.tile"+iy+".nc"
    fc = addfile(dir3+f3,"r")
    sandall1 = fc->ice_aero
    ;sandall = dim_sum_n(sandall1,0)
    sandall = sandall1(64,:,:)

    lon=f->grid_lont
    lat=f->grid_latt
    lonc=f->grid_lon
    latc=f->grid_lat

    ;print (lon(:,0))
    ;print (lat(:,0))
    ;print (latc(:,0))
    ;print (sandcv(:,:))

    do ii=0,NX-1
    do jj=0,NY-1
     var(in)=sandall(ii,jj)
     lonn(in)=lon(ii,jj)
     latn(in)=lat(ii,jj)
     in=in+1
    end do
    end do

  end do

  wks = gsn_open_wks("png", "nifa.png")   ;-- open a workstation
;  wks = gsn_open_wks("X11", "Sand")   ;-- open a workstation
plot=new(2,graphic)
;-- set resources
   res                       =  True
   res@gsnMaximize           =  True
 ;  res@gsnAddCyclic          =  True

   res@cnFillOn              =  True            ;-- turn on contour fill
   res@cnFillPalette         = "ncl_default"    ;-- Choose color map
   res@cnFillMode            = "areaFill"
   ;res@cnFillMode            = "RasterFill"
   res@cnLinesOn             =  False           ;-- Turn lines off
   res@cnLineLabelsOn        =  False           ;-- Turn labels off
  ; res@trGridType            ="TriangularMesh"
  ; res@mpProjection         = "Orthographic"
  ; res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ; res@cnLevels         = (/0.5, 1, 2 , 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 35, 40, 45, 50 /)
  ; res@cnCellFillEdgeColor   = 1
;   res@cnCellFillMissingValEdgeColor = "black"
;   res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
;   res@cnMinLevelValF        =  0.0001            ;-- minimum contour level
;   res@cnMaxLevelValF        =  0.0002            ;-- maximum contour level
    ;res@cnLevelSpacingF       =  1e-3
                                                ;-- title string
   res@tiMainFontHeightF     =  0.02

   res@sfXArray              =  lonn
   res@sfYArray              =  latn
;-- draw the contour map
   res@tiMainString          = "nifa at lowest (closest to surface) GFS level [kg-1]"
   plot(0) = gsn_csm_contour_map(wks,var,res)
   gsn_panel(wks,plot,(/1,1/),False)
   end
