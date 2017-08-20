cmake_minimum_required(VERSION 3.2.3)

PROJECT("org.wxwidgets.wxwidgets")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "3.1.1")


IF(${CMAKE_CROSSCOMPILING})
	IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		# Get the prefix of the compiler.
		GET_FILENAME_COMPONENT(GCC_BASENAME ${CMAKE_C_COMPILER} NAME)
		IF(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			SET(CONFIGURE_HOST "--host=${CMAKE_MATCH_1}")
		ELSE(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			MESSAGE(FATAL_ERROR "Failed to extract the compiler prefix from the C compiler ${CMAKE_C_COMPILER}")
		ENDIF(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
	ELSE("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		MESSAGE(FATAL_ERROR "Cross compiling detected, but not using GCC. This is currently not supported.")
	ENDIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
ELSE(${CMAKE_CROSSCOMPILING})
	SET(CONFIGURE_HOST "")
ENDIF(${CMAKE_CROSSCOMPILING})

# Select the native toolkit.
IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	SET(NATIVE_TOOLKIT "--with-msw")
ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	SET(NATIVE_TOOLKIT "--with-gtk=3")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

SET(EXT_CFLAGS "")
SET(EXT_CXXFLAGS "")
SET(EXT_LDFLAGS "")

# Use static versions of libgcc and libstdc++ on windows.
IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	LIST(APPEND EXT_LDFLAGS  "-static-libgcc -static-libstdc++")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

# The static libraries will be linked to a shared object later. This needs "-fPIC" on linux.
IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"  AND  "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
	LIST(APPEND EXT_CFLAGS "-fPIC")
	LIST(APPEND EXT_CXXFLAGS "-fPIC")
ENDIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"  AND  "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")

STRING(REPLACE ";" " " P_CFLAGS "${EXT_CFLAGS}")
STRING(REPLACE ";" " " P_CXXFLAGS "${EXT_CXXFLAGS}")
STRING(REPLACE ";" " " P_LDFLAGS "${EXT_LDFLAGS}")

ExternalProject_Add(TARGET_wxwidgets
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/wxwidgets
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets-gitc93b88a.tar.xz
                    URL_HASH SHA1=d9f82eccd61661f04dac167408cf0073ab2b7818
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CFLAGS=${P_CFLAGS}" "CXXFLAGS=${P_CXXFLAGS}" "LDFLAGS=${P_LDFLAGS}" ${CMAKE_CURRENT_BINARY_DIR}/wxwidgets/src/TARGET_wxwidgets/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --disable-shared --disable-precomp-headers ${NATIVE_TOOLKIT} ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)
