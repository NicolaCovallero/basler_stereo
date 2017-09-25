#edit the following line to add the libraries' header files
FIND_PATH(stereovision_INCLUDE_DIR ../include/stereovision.h)

FIND_LIBRARY(stereovision_LIBRARY
    NAMES stereovision
    PATHS C:/Users/Utente/Documents/Visual Studio 2015/Projects/StereoVision) 

IF (stereovision_INCLUDE_DIR AND stereovision_LIBRARY)
   SET(stereovision_FOUND TRUE)
ENDIF (stereovision_INCLUDE_DIR AND stereovision_LIBRARY)

IF (stereovision_FOUND)
   IF (NOT stereovision_FIND_QUIETLY)
      MESSAGE(STATUS "Found stereovision: ${stereovision_LIBRARY}")
   ENDIF (NOT stereovision_FIND_QUIETLY)
ELSE (stereovision_FOUND)
   IF (stereovision_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find stereovision")
   ENDIF (stereovision_FIND_REQUIRED)
ENDIF (stereovision_FOUND)