cmake_minimum_required(VERSION 3.2.3)

PROJECT("org.wxwidgets.wxwidgets")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "3.1.0")


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


SET(LIBLIST "")
SET(INCLIST "")
SET(LDLIST "")

# Use static versions of libgcc and libstdc++ on windows.
IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	LIST(APPEND LDLIST  "-static-libgcc -static-libstdc++")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

STRING(REPLACE ";" " " P_LINK_LIBRARIES "${LIBLIST}")
STRING(REPLACE ";" " " P_INCLIST "${INCLIST}")
STRING(REPLACE ";" " " P_LDLIST "${LDLIST}")

ExternalProject_Add(TARGET_wxwidgets
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/wxwidgets
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets-${VERSION_EXTERNAL}.tar.bz2
                    URL_HASH SHA1=2170839cfa9d9322e8ee8368b21a15a2497b4f11
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CPPFLAGS=${P_INCLIST}" "LDFLAGS=${P_LDLIST}" "LIBS=${P_LINK_LIBRARIES}" ${CMAKE_CURRENT_BINARY_DIR}/wxwidgets/src/TARGET_wxwidgets/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --disable-shared --disable-precomp-headers --with-gtk=3 --enable-compat28 ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
                    USES_TERMINAL_CONFIGURE 1
                    USES_TERMINAL_BUILD 1
)
