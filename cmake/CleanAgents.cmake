######################################################################
## CleanAgents.cmake
## Helper script to clean manifest files from build directory
## Removes *_manifest.txt files while preserving other build artifacts
######################################################################

# Find and remove all manifest files in the build directory
file(GLOB _manifest_files "${CMAKE_BINARY_DIR}/*_manifest.txt")
foreach(_file ${_manifest_files})
    file(REMOVE "${_file}")
endforeach()

if(_manifest_files)
    message(STATUS "Removed manifest files: ${_manifest_files}")
endif()
