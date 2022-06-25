#!/bin/sh

cd $(dirname $0)

export INSTALL_DIR=/I/tmp/CuraInstallation
export CC=gcc
export CXX=g++

rm -rf build >/dev/null
rm -rf "${INSTALL_DIR}" >/dev/null
mkdir build
cd build

pacman -Syu --noconfirm
pacman -S --noconfirm git mingw-w64-x86_64-python mingw-w64-x86_64-python-pip mingw-w64-x86_64-python-packaging mingw-w64-x86_64-sip mingw-w64-x86_64-pyqt-builder mingw-w64-x86_64-qt5 mingw-w64-x86_64-qt5-tools mingw-w64-x86_64-python-pyqt5 mingw-w64-x86_64-pkgconf mingw-w64-x86_64-make mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja mingw-w64-x86_64-gcc mingw-w64-x86_64-nsis || exit 1
pip install conan setuptools wheel
cat <<"_PROFILE" >"${USERPROFILE}/.conan/profiles/default"
[settings]
os=Windows
os_build=Windows
arch=x86_64
arch_build=x86_64
compiler=gcc
compiler.version=12
compiler.libcxx=libstdc++11
build_type=Release
[options]
[build_requires]
[env]
_PROFILE
# some python packages try to link to the python library without dots in its version number part
for f in ${MSYSTEM_PREFIX}/lib/libpython*.dll.a; do
	[ "${f}" = "${MSYSTEM_PREFIX}/lib/libpython*.dll.a" ] && exit 1
	[ -f "${f//3./3}" ] || ln -s "${f}" "${f//3./3}" || exit 1
done
ln -s "${MSYSTEM_PREFIX}/bin/mingw32-make.exe" "${MSYSTEM_PREFIX}/bin/make.exe"

export CONAN_CMAKE_GENERATOR=Ninja
export CONAN_USER_HOME_SHORT=None
cmake -G "Ninja" "-DCMAKE_PREFIX_PATH=${INSTALL_DIR}" "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}" -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CONFIGURATION_TYPES=Release -DCMAKE_BUILD_TYPE=Release .. || exit 1
cmake --build . || exit 1
