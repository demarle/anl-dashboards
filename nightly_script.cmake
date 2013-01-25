# Client maintainer: dave.demarle@kitware.com
cmake_minimum_required ( VERSION 2.8 )

message("DIRNAME is ${dirname}")

set (CTEST_SITE "eureka.anl")
set (CTEST_BUILD_NAME "Eureka-${dirname}")

set (CTEST_BUILD_CONFIGURATION "Nightly")
set (CTEST_CMAKE_GENERATOR "Unix Makefiles")
set (CTEST_UPDATE_COMMAND "git")
set (CTEST_BUILD_FLAGS "-j 2")

set (CTEST_NOTES_FILES "${CTEST_SCRIPT_DIRECTORY}/nightly_script.sh")
list (APPEND CTEST_NOTES_FILES 
     "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
     "${CTEST_SCRIPT_DIRECTORY}/qsub_tests.sh"
     "${CTEST_SCRIPT_DIRECTORY}/compute_node_tests.sh"
     )
set (CTEST_SOURCE_DIRECTORY "/intrepid-fs0/projects/pvdev/common/pv-source/${dirname}")
set (CTEST_BINARY_DIRECTORY "/intrepid-fs0/projects/pvdev/eureka/pv-build/${dirname}")
set (VTK_DATA_ROOT "/intrepid-fs0/projects/pvdev/common/pv-source/VTKData")
set (PARAVIEW_DATA_ROOT "/intrepid-fs0/projects/pvdev/common/pv-source/ParaViewData")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt"
"
//Path to a program
CMAKE_MAKE_PROGRAM:FILEPATH=/usr/bin/make
//Name of generator.
CMAKE_GENERATOR:INTERNAL=${CTEST_CMAKE_GENERATOR}
//Build type
CMAKE_BUILD_TYPE:STRING=Release

//Path to VTK regression test data
VTK_DATA_ROOT=${VTK_DATA_ROOT}
//Path to ParaView regression test data
PARAVIEW_DATA_ROOT=${PARAVIEW_DATA_ROOT}

//Build leak checking support into VTK.
VTK_DEBUG_LEAKS:BOOL=ON

//Build with shared libraries python
BUILD_SHARED_LIBS:BOOL=ON

//Enable Python scripting
PARAVIEW_ENABLE_PYTHON:BOOL=ON

//Enable MPI
PARAVIEW_USE_MPI:BOOL=ON

//Enable VisItBridge
PARAVIEW_USE_VISITBRIDGE:BOOL=ON

//Not interested in client, only on server side
PARAVIEW_BUILD_QT_GUI:BOOL=OFF

//Where make install will put it, should be /soft/somewhere when ready 
CMAKE_INSTALL_PREFIX:PATH=/intrepid-fs0/projects/pvdev/eureka/pv-install/${dirname}
"
)

ctest_start (${CTEST_BUILD_CONFIGURATION})
ctest_update (SOURCE "${VTK_DATA_ROOT}")
ctest_update (SOURCE "${PARAVIEW_DATA_ROOT}")
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files ("${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#don't ctest_test, instead run a script to qsub something that will on backend 
execute_process (
  COMMAND 
  qsub_tests.sh ${CTEST_SCRIPT_DIRECTORY} ${CTEST_BINARY_DIRECTORY} 
		${CTEST_BUILD_NAME} ${CTEST_SITE}
  WORKING_DIRECTORY ${CTEST_SCRIPT_DIRECTORY}
)
ctest_submit ()
