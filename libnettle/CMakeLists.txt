cmake_minimum_required(VERSION 3.7)

PROJECT("libnettle")

INCLUDE(ExternalProject)
SET(VERSION_EXTERNAL "3.9")
SET(VERSION_PACKAGE  "1")
SET(PROJECT_VERSION  "${VERSION_EXTERNAL}.${VERSION_PACKAGE}")
SET(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
SET(LIBGMP_INCLUDE_DIR "${CMAKE_BINARY_DIR}/build_requirements/jonchki/install/dev/include")
SET(LIBGMP_LIB_DIR "${CMAKE_BINARY_DIR}/build_requirements/jonchki/install/dev/lib")
message("******${LIBGMP_INCLUDE_DIR}")
message("******${LIBGMP_LIB_DIR}")
# Get the VCS version for the jonchki configuration.
INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/version.cmake)

# Filter the jonchki configuration.
CONFIGURE_FILE(installer/libnettle.xml
               ${CMAKE_BINARY_DIR}/libnettle-${PROJECT_VERSION}.xml
               @ONLY)

#----------------------------------------------------------------------------
#
# Build the project.
#
IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
ExternalProject_Add(TARGET_libnettle
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libnettle
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nettle-3.9.tar.gz
                    URL_HASH SHA1=308c81e94e2ba333fc39ea4141760a8f0cd19c37
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "LIBS=-lgmp" ${CMAKE_CURRENT_BINARY_DIR}/libnettle/src/TARGET_libnettle/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-pic --with-include-path=${LIBGMP_INCLUDE_DIR} --with-lib-path=${LIBGMP_LIB_DIR} --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

# libnettle depends on libGMP.
#ADD_DEPENDENCIES(TARGET_libnettle TARGET_libgmp)

SET(LIBNETTLE_PREFIX       ${CMAKE_BINARY_DIR}/install            CACHE INTERNAL "The complete path to the libnettle installation.")
SET(LIBNETTLE_LIBRARY      nettle                                 CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBHOGWEED_LIBRARY     hogweed                                CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBNETTLE_INCLUDE_DIR  ${LIBNETTLE_PREFIX}/include            CACHE INTERNAL "The include folder for the libnettle library.")

# Use the lib64 folder only on "ubuntu 20.04 x86_64" and "ubuntu 22.04 x86_64".
IF(JONCHKI_PLATFORM_CPU_ARCH STREQUAL "x86_64")
        SET(LIB_FOLDER "lib64")
ELSE(JONCHKI_PLATFORM_CPU_ARCH STREQUAL "x86_64")
        SET(LIB_FOLDER "lib")
ENDIF(JONCHKI_PLATFORM_CPU_ARCH STREQUAL "x86_64")



SET(LIBNETTLE_LIB_DIR      ${LIBNETTLE_PREFIX}/${LIB_FOLDER}   CACHE INTERNAL "The complete path to the libnettle library.")



# Create a package.
SET(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_BINARY_DIR}/../repository/org/libnettle/${VERSION_EXTERNAL})
SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
SET(CPACK_GENERATOR "TXZ")

INSTALL(FILES ${CMAKE_BINARY_DIR}/install/${LIB_FOLDER}/libnettle.a ${CMAKE_BINARY_DIR}/install/${LIB_FOLDER}/libhogweed.a
		TYPE LIB)
INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/install/include/
		DESTINATION include)

CONFIGURE_FILE(installer/install.lua 
				${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
				@ONLY)

INSTALL (FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		DESTINATION .)

CONFIGURE_FILE(installer/libnettle.xml
				${CPACK_OUTPUT_FILE_PREFIX}/libnettle-${VERSION_EXTERNAL}-${JONCHKI_PLATFORM}.xml
				@ONLY)

SET(CPACK_PACKAGE_FILE_NAME "libnettle-${VERSION_EXTERNAL}-${JONCHKI_PLATFORM}")

INCLUDE(CPack)

ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))