cmake_minimum_required(VERSION 3.2.3)

PROJECT("net.sourceforge.wxlua")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "2.8.12.3")
SET(VERSION_PACKAGE  "1")
SET(PROJECT_VERSION  "${VERSION_EXTERNAL}.${VERSION_PACKAGE}")

# Get the VCS version for the jonchki configuration.
INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/version.cmake)

# Filter the jonchki configuration.
CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/wxlua.xml
               ${CMAKE_CURRENT_BINARY_DIR}/lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}.xml
               @ONLY)

#SET(SRCPKG_PATH ${CMAKE_CURRENT_SOURCE_DIR}/wxlua-git69fd84d1978b.tar.xz)
#SET(SRCPKG_HASH 804d8ff26de9b50418ce9e69f2f0f2f3a77aa95e)
SET(SRCPKG_PATH ${CMAKE_CURRENT_SOURCE_DIR}/wxlua-laptabrok-56a33ba93728.tar.xz)
SET(SRCPKG_HASH d75d38800b79dbf72f97ccb60a7708878a80bde4)


#----------------------------------------------------------------------------
#
# Build the project.
#
IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
	# Select the LUA version.
	INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/muhkuh_lua.cmake)

	# wxLua only knows LUA5.1 and LUA5.2 . LUA5.3 can be used as LUA5.2 .
	IF(${BUILDCFG_LUA_VERSION} STREQUAL "5.1")
		SET(wxLua_LUA_LIBRARY_VERSION "5.1")
	ELSEIF(${BUILDCFG_LUA_VERSION} STREQUAL "5.2")
		SET(wxLua_LUA_LIBRARY_VERSION "5.2")
	ELSEIF(${BUILDCFG_LUA_VERSION} STREQUAL "5.3")
		# Disguise LUA5.3 as LUA5.2 .
		SET(wxLua_LUA_LIBRARY_VERSION "5.2")
	ELSE(${BUILDCFG_LUA_VERSION} STREQUAL "5.1")
		MESSAGE(FATAL_ERROR "Invalid LUA version selected: ${BUILDCFG_LUA_VERSION}")
	ENDIF(${BUILDCFG_LUA_VERSION} STREQUAL "5.1")

	SET(PRJ_CMAKE_ARGS "")

	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_BUILD_TYPE=Release")
	LIST(APPEND PRJ_CMAKE_ARGS "-DBUILD_SHARED_LIBS=FALSE")
	LIST(APPEND PRJ_CMAKE_ARGS "-DwxWidgets_CONFIG_EXECUTABLE=${WXCONFIG}")
	LIST(APPEND PRJ_CMAKE_ARGS "-DwxLua_LUA_LIBRARY_USE_BUILTIN=FALSE")
	LIST(APPEND PRJ_CMAKE_ARGS "-DwxLua_LUA_LIBRARY_VERSION=${wxLua_LUA_LIBRARY_VERSION}")
	LIST(APPEND PRJ_CMAKE_ARGS "-DwxLua_LUA_INCLUDE_DIR=${LUA_INCLUDE_DIR}")
	LIST(APPEND PRJ_CMAKE_ARGS "-DwxLua_LUA_LIBRARY=${LUA_LIBRARIES}")

	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}")
	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_RC_COMPILER=${CMAKE_RC_COMPILER}")
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=''")

	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_C_FLAGS_RELEASE=-s")
	LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_CXX_FLAGS_RELEASE=-s")

	ExternalProject_Add(TARGET_wxlua
	                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/wxlua
	                    URL ${SRCPKG_PATH}
	                    URL_HASH SHA1=${SRCPKG_HASH}
	                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/wxlua/src/TARGET_wxlua --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
	                    CMAKE_ARGS ${PRJ_CMAKE_ARGS}
	                    SOURCE_SUBDIR wxLua
	                    INSTALL_COMMAND make install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/install
	)

	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/bin/libwx.dll
		        DESTINATION ${INSTALL_DIR_LUA_MODULES}
		        RENAME wx.dll)
	ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libwx.so
		        DESTINATION ${INSTALL_DIR_LUA_MODULES}
		        RENAME wx.so)
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")


	#----------------------------------------------------------------------------
	#
	# Build a package for the selected platform.
	#

	SET(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/targets/jonchki/repository/net/sourceforge/wxlua/wxlua/${PROJECT_VERSION})
	SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
	SET(CPACK_PACKAGE_FILE_NAME "lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}-${JONCHKI_PLATFORM}")

	SET(CPACK_GENERATOR "TXZ")
	INCLUDE(CPack)

	IF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
		# Package a windows build.

		# NOTE: Do not install the library again, there is an "INSTALL" already.

		CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/install_windows.lua
		               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		               @ONLY)

		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		        DESTINATION .)
	ELSE(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
		# Package a linux build.

		# NOTE: Do not install the library again, there is an "INSTALL" already.

		CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/install_linux.lua
		               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		               @ONLY)

		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		        DESTINATION .)
	ENDIF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")

	CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/wxlua.xml
	               ${CPACK_OUTPUT_FILE_PREFIX}/lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
	               @ONLY)


	#-----------------------------------------------------------------------------
	#
	# Create a custom target named "pack".
	# It builds the package and creates the hashes.
	#
	ADD_CUSTOM_TARGET(pack
	                  COMMAND ${CMAKE_MAKE_PROGRAM}
	                  COMMAND ${CMAKE_MAKE_PROGRAM} package
	                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
	                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.tar.xz
	                  COMMENT "Pack the artifact and generate the hashes...")


	#-----------------------------------------------------------------------------
	#
	# Filter the pom.xml file.
	#
	SET(POM_ARTIFACT_ID  "wxlua")
	SET(POM_GROUP_ID     "net.sourceforge.wxlua")
	SET(POM_VERSION      "${PROJECT_VERSION}")
	SET(POM_PACKAGING    "tar.xz")
	CONFIGURE_FILE(installer/lua${BUILDCFG_LUA_VERSION}/pom.xml
	               ${CPACK_OUTPUT_FILE_PREFIX}/lua${BUILDCFG_LUA_VERSION}-wxlua-${PROJECT_VERSION}.pom
	               @ONLY)
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
