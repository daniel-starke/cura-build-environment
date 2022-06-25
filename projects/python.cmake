# Copyright (c) 2022 Ultimaker B.V.
# cura-build-environment is released under the terms of the AGPLv3 or higher.
#
# Sets up a virtual environment using the Python interpreter

if(NOT DEFINED Python_VERSION)
    set(Python_VERSION
            3.10
            CACHE STRING "Python Version" FORCE)
    message(STATUS "Setting Python version to ${Python_VERSION}. Set Python_VERSION if you want to compile against an other version.")
endif()
if(APPLE)
    set(Python_FIND_FRAMEWORK NEVER)
endif()
find_package(cpython ${Python_VERSION} QUIET COMPONENTS Interpreter)
if(NOT TARGET cpython::python)
    find_package(Python ${Python_VERSION} EXACT REQUIRED COMPONENTS Interpreter)
	set(python_lib_path "${lib_path}/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}")
	set(PYTHONPATH ${CMAKE_INSTALL_PREFIX}/${python_lib_path}/site-packages)
	set(Python_VENV_EXECUTABLE ${CMAKE_INSTALL_PREFIX}/${exe_path}/python${exe_ext})
	set(Python_SITELIB_LOCAL ${CMAKE_INSTALL_PREFIX}/${python_lib_path}/site-packages/)
else()
    add_library(Python::Python ALIAS cpython::python)
    set(Python_SITEARCH "${CMAKE_INSTALL_PREFIX}/lib/python3.10/site-packages")
    set(Python_EXECUTABLE ${cpython_PACKAGE_FOLDER_RELEASE}/bin/python${exe_ext})
    set(ENV{PYTHONPATH} ${Python_SITEARCH})
endif()
message(STATUS "Using Python ${Python_VERSION}")

add_custom_target(create-virtual-env ALL COMMENT "Create Virtual Environment")
add_custom_command(
        TARGET create-virtual-env
        COMMAND ${Python_EXECUTABLE} -m venv ${CMAKE_INSTALL_PREFIX})

add_custom_target(install-base-python-requirements ALL COMMENT "Install base python requirements in virtual environment")
add_custom_command(
        TARGET install-base-python-requirements
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${PYTHONPATH}" ${Python_VENV_EXECUTABLE} -m pip install --require-hashes -r  ${CMAKE_SOURCE_DIR}/projects/base_requirements.txt
		COMMAND rm -f ${PYTHONPATH}/setuptools/*.exe
		COMMAND cp /mingw64/${python_lib_path}/site-packages/setuptools/*.exe ${PYTHONPATH}/setuptools/)
add_dependencies(install-base-python-requirements create-virtual-env)

# we depend on a patched setuptools package and thus cannot use an isolated build environment
add_custom_target(install-python-requirements ALL COMMENT "Install python requirements in virtual environment")
add_custom_command(
        TARGET install-python-requirements
        COMMAND sed -i "s/('nt', 'msvc')/('nt', 'mingw32')/g" "${PYTHONPATH}/setuptools/_distutils/ccompiler.py"
        COMMAND sed -i "s/self.dll_libraries = get_msvcr()/self.dll_libraries = get_msvcr() or []/g" "${PYTHONPATH}/setuptools/_distutils/cygwinccompiler.py"
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${PYTHONPATH}" ${Python_VENV_EXECUTABLE} -m pip install --no-build-isolation --require-hashes -r  ${CMAKE_SOURCE_DIR}/projects/requirements0.txt
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${PYTHONPATH}" ${Python_VENV_EXECUTABLE} -m pip install --no-build-isolation --require-hashes -r  ${CMAKE_SOURCE_DIR}/projects/requirements.txt
		COMMAND tar -C ${CMAKE_INSTALL_PREFIX} -xzf ${CMAKE_SOURCE_DIR}/pyqt5-5.12.2-mingw64.tgz)
add_dependencies(install-python-requirements install-base-python-requirements)
