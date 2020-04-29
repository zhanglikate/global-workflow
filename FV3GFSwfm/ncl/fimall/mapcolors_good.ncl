  wid = create "mdssWork" windowWorkstationClass defaultapp
    "wkFormat"   : "x11"
    "wkPause" : True
  end create

  mpid = create "mapplot" mapPlotClass wid
    "mpProjection" : "CylindricalEquidistant"
    "mpLimitMode" : "LatLon"
    "mpMinLonF" : -130
    "mpMinLatF" : 20
    "mpMaxLonF" : -60
    "mpMaxLatF" : 60
    "mpOutlineOn" : True
    "mpFillOn" : False
  end create

  setvalues mpid
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpUSStateLineColor" : "purple"
    "mpUSStateLineThicknessF" : 2.0
  end setvalues

  draw(mpid)
  frame(wid)

  getvalues mpid
    "mpUSStateLineColor" : color
  end getvalues
  print("mpid color = " + color)
