set(NEMS2NC_SRC nems2nc.cc nems2nc.h)
add_library(nems2nc ${NEMS2NC_SRC})
set(GFSNC_SRC gfsnc.cc gfsnc.h nems2ncvars.h nems2nc.h)
add_library(gfsnc ${GFSNC_SRC})
set(NEMSIOC_SRC nemsio.cc nemsio.h)
add_library(nemsioc ${NEMSIOC_SRC})
set(NEMSIO_INT nemsio_interface.h nemsio_interface.f90)
add_library(nemsio_int ${NEMSIO_INT})

set(MAIN_SRC nemsio2nc.cc)

add_executable(nemsioatm2nc ${MAIN_SRC})
target_link_libraries(nemsioatm2nc nems2nc gfsnc nemsioc nemsio_int ${NETCDF_LIBRARIES_C} ${NEMSIO_LIBRARY} ${BACIO_LIBRARY} ${W3NCO_4_LIBRARY})

