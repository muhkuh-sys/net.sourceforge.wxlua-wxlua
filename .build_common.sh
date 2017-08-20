# Do not call this script directly. It is included from the .build??_*.sh files.

echo "PRJ_DIR        = ${PRJ_DIR}"
echo "BUILD_DIR      = ${BUILD_DIR}"
echo "CMAKE_COMPILER = ${CMAKE_COMPILER}"
echo "JONCHKI        = ${JONCHKI}"
echo "JONCHKI_SYSTEM = ${JONCHKI_SYSTEM}"

# Create all folders.
#rm -rf ${BUILD_DIR}
rm -rf ${BUILD_DIR}/lua5.1/wxlua
rm -rf ${BUILD_DIR}/lua5.2/wxlua
rm -rf ${BUILD_DIR}/lua5.3/wxlua

mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/external
mkdir -p ${BUILD_DIR}/lua5.1/build_requirements
mkdir -p ${BUILD_DIR}/lua5.1/wxlua
mkdir -p ${BUILD_DIR}/lua5.2/build_requirements
mkdir -p ${BUILD_DIR}/lua5.2/wxlua
mkdir -p ${BUILD_DIR}/lua5.3/build_requirements
mkdir -p ${BUILD_DIR}/lua5.3/wxlua


# Build the wxWidgets library.
pushd ${BUILD_DIR}/external
cmake ${CMAKE_COMPILER} ${PRJ_DIR}/external
make
popd
WXCONFIG=${BUILD_DIR}/external/wxwidgets/install/bin/wx-config

# Get the build requirements for the LUA5.1 version.
pushd ${BUILD_DIR}/lua5.1/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.1" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
lua5.1 ${JONCHKI} --verbose info --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies wxlua/lua5.1-wxlua-*.xml
popd

# Build wxLua for LUA5.1 .
pushd ${BUILD_DIR}/lua5.1/wxlua
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="OFF" -DBUILDCFG_LUA_VERSION="5.1" -DCMAKE_INSTALL_PREFIX="" -DWXCONFIG=${WXCONFIG} ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.1/install

# Get the build requirements for the LUA5.2 version.
pushd ${BUILD_DIR}/lua5.2/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.2" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
lua5.1 ${JONCHKI} --verbose info --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies wxlua/lua5.2-wxlua-*.xml
popd

# Build wxLua for LUA5.2 .
pushd ${BUILD_DIR}/lua5.2/wxlua
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="OFF" -DBUILDCFG_LUA_VERSION="5.2" -DCMAKE_INSTALL_PREFIX="" -DWXCONFIG=${WXCONFIG} ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.2/install

# Get the build requirements for the LUA5.3 version.
pushd ${BUILD_DIR}/lua5.3/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DBUILDCFG_LUA_VERSION="5.3" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
lua5.1 ${JONCHKI} --verbose info --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies wxlua/lua5.3-wxlua-*.xml
popd

# Build wxLua for LUA5.3 .
pushd ${BUILD_DIR}/lua5.3/wxlua
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="OFF" -DBUILDCFG_LUA_VERSION="5.3" -DCMAKE_INSTALL_PREFIX="" -DWXCONFIG=${WXCONFIG} ${CMAKE_COMPILER} ${PRJ_DIR}
make
make install DESTDIR=${BUILD_DIR}/lua5.3/install
