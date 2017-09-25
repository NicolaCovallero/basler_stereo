# - Try to find Pylon
# Once done this will define
#  PYLON_FOUND - System has Pylon
#  PYLON_INCLUDE_DIRS - The Pylon include directories
#  PYLON_LIBRARIES - The libraries needed to use Pylon

IF(WIN32)
  message("Windows OS detected")
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 ) # determines the size of a void pointer in the machine, in particular this if checks if the pointer's length is equal to 64 bits = 8 bytes
    set( PYLON_LIBRARY "$ENV{PYLON_DEV_DIR}/lib/x64" )
  else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( PYLON_LIBRARY "$ENV{PYLON_DEV_DIR}/lib/Win32" )
  endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  FIND_PATH(  PYLON_INCLUDE_DIR pylon/PylonBase.h
      PATHS
      "$ENV{PYLON_DEV_DIR}/include"
	)
ELSE(WIN32)
  IF(UNIX)
	message("UNIX OS detected")
    if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
      set( PYLON_LIBRARY "/opt/pylon5/lib64" )
    else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
      set( PYLON_LIBRARY "/opt/pylon5/lib32" )
    endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	FIND_PATH(  PYLON_INCLUDE_DIR pylon/PylonBase.h
      PATHS
      /opt/pylon5/include
      "$ENV{PYLON_ROOT}/include"
	)
  ENDIF(UNIX)
ENDIF(WIN32)



FIND_LIBRARY( PYLONBASE_LIBRARY 
        NAMES 
        pylonbase #PylonBase_MD_VC120_v5_0 
				PylonBase_MD_VC100
        PATHS
        ${PYLON_LIBRARY}
)

FIND_LIBRARY( PYLON_UTILITY_LIBRARY 
        NAMES 
        pylonutility #PylonUtility_MD_VC120_v5_0 
				PylonUtility_MD_VC100
        PATHS
        ${PYLON_LIBRARY}
)

FIND_LIBRARY( PYLON_BOOTSTRAPPER_LIBRARY 
        NAMES 
        pylonbootstrapper  PylonBootstrapper
        PATHS
        ${PYLON_LIBRARY}
)

set( XERCES-C_LIBRARY "" )
FIND_LIBRARY( XERCES-C_LIBRARY 
        NAMES 
        Xerces-C_gcc40_v2_7 Xerces-C_MD_VC100_v2_7_1
        PATHS
        ${PYLON_LIBRARY}
)

if( NOT XERCES-C_LIBRARY)
    set(XERCES-C_LIBRARY "")
endif(NOT XERCES-C_LIBRARY)

if( NOT PYLON_BOOTSTRAPPER_LIBRARY)
    set(PYLON_BOOTSTRAPPER_LIBRARY "")
endif(NOT PYLON_BOOTSTRAPPER_LIBRARY)

set(PYLON_LIBRARIES  ${PYLONBASE_LIBRARY} ${XERCES-C_LIBRARY} ${PYLON_UTILITY_LIBRARY} ${PYLON_BOOTSTRAPPER_LIBRARY})
set(PYLON_INCLUDE_DIRS ${PYLON_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(PYLON DEFAULT_MSG
  PYLON_INCLUDE_DIR
  PYLON_LIBRARY)

mark_as_advanced(PYLON_INCLUDE_DIR PYLON_LIBRARIES)
 
