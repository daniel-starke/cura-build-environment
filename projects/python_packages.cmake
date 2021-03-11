add_custom_target(NumpyScipyShapely ALL DEPENDS Python)

# Numpy, Scipy, Shapely
if(NOT BUILD_OS_WINDOWS)
    # On Mac, building with gfortran can be a problem. If we install scipy via pip, it will compile Fortran code
    # using gfortran by default, but if we install it manually, it will use f2py from numpy to convert Fortran
    # code to Python code and then compile, which solves this problem.
    # So, for non-Windows builds, we install scipy manually.

    # Numpy
    # Numpy version is limited by a bug in cx_Freeze to version 1.18.2: https://github.com/marcelotduarte/cx_Freeze/issues/653
    # More modern versions don't get packaged correctly. Newer versions of cx_Freeze than 6.5.2 might fix this problem (it is apparently fixed on the Main branch at the moment).
    add_custom_target(Numpy ALL
        COMMAND ${Python3_EXECUTABLE} -m pip install numpy==1.18.2
        DEPENDS Python
    )

    set(scipy_build_command ${Python3_EXECUTABLE} setup.py build)
    set(scipy_install_command ${Python3_EXECUTABLE} setup.py install)
    if(BUILD_OS_OSX)
        set(scipy_build_command env LDFLAGS="-undefined dynamic_lookup" ${scipy_build_command})
        set(scipy_install_command env LDFLAGS="-undefined dynamic_lookup" ${scipy_install_command})
    endif()

    # Scipy
    ExternalProject_Add(Scipy
        GIT_REPOSITORY https://github.com/scipy/scipy.git
        GIT_TAG v1.6.1
        GIT_SHALLOW TRUE
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${scipy_build_command}
        INSTALL_COMMAND ${scipy_install_command}
        BUILD_IN_SOURCE 1
        DEPENDS Numpy
    )

    # Shapely
    add_custom_target(Shapely ALL
        COMMAND ${Python3_EXECUTABLE} -m pip install "shapely[vectorized]==1.7.1"
        DEPENDS Scipy
    )

    add_dependencies(NumpyScipyShapely Scipy)
else()
    ### MASSSIVE HACK TIME!!!!
    # It is currently effectively impossible to build SciPy on Windows without a proprietary compiler (ifort).
    # This means we need to use a pre-compiled binary version of Scipy. Since the only version of SciPy for
    # Windows available depends on numpy with MKL, we also need the binary package for that.
    if(BUILD_OS_WIN32)
        add_custom_command(TARGET NumpyScipyShapely PRE_BUILD
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/numpy-1.18.2+mkl-cp38-cp38-win32.whl
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/scipy-1.6.1-cp38-cp38-win32.whl
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/Shapely-1.7.1-cp38-cp38-win32.whl
            COMMENT "Install Numpy, Scipy, and Shapely"
        )
    else()
        add_custom_command(TARGET NumpyScipyShapely PRE_BUILD
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/numpy-1.18.2+mkl-cp38-cp38-win_amd64.whl
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/scipy-1.6.1-cp38-cp38-win_amd64.whl
            COMMAND ${Python3_EXECUTABLE} -m pip install https://download.lfd.uci.edu/pythonlibs/w4tscw6k/Shapely-1.7.1-cp38-cp38-win_amd64.whl
            COMMENT "Install Numpy, Scipy, and Shapely"
        )
    endif()
endif()

# Other Python Packages
add_custom_target(PythonPackages ALL
    COMMAND ${Python3_EXECUTABLE} -m pip install appdirs==1.4.3
    COMMAND ${Python3_EXECUTABLE} -m pip install certifi==2019.11.28
    COMMAND ${Python3_EXECUTABLE} -m pip install cffi==1.14.1
    COMMAND ${Python3_EXECUTABLE} -m pip install chardet==3.0.4
    COMMAND ${Python3_EXECUTABLE} -m pip install cryptography==3.4.6
    COMMAND ${Python3_EXECUTABLE} -m pip install decorator==4.4.0
    COMMAND ${Python3_EXECUTABLE} -m pip install idna==2.8
    COMMAND ${Python3_EXECUTABLE} -m pip install importlib-metadata==3.7.2  # Dependency of cx_Freeze
    COMMAND ${Python3_EXECUTABLE} -m pip install netifaces==0.10.9
    COMMAND ${Python3_EXECUTABLE} -m pip install networkx==2.3
    COMMAND ${Python3_EXECUTABLE} -m pip install numpy-stl==2.10.1
    COMMAND ${Python3_EXECUTABLE} -m pip install packaging==18.0
    COMMAND ${Python3_EXECUTABLE} -m pip install pycollada==0.6
    COMMAND ${Python3_EXECUTABLE} -m pip install pycparser==2.19
    COMMAND ${Python3_EXECUTABLE} -m pip install pyparsing==2.4.2
    COMMAND ${Python3_EXECUTABLE} -m pip install PyQt5-sip==12.8.1
    COMMAND ${Python3_EXECUTABLE} -m pip install pyserial==3.4
    COMMAND ${Python3_EXECUTABLE} -m pip install python-dateutil==2.8.0
    COMMAND ${Python3_EXECUTABLE} -m pip install python-utils==2.3.0
    COMMAND ${Python3_EXECUTABLE} -m pip install requests==2.22.0
    COMMAND ${Python3_EXECUTABLE} -m pip install sentry-sdk==0.13.5
    COMMAND ${Python3_EXECUTABLE} -m pip install six==1.12.0
    # https://github.com/mikedh/trimesh/issues/575 since 3.2.34
    COMMAND ${Python3_EXECUTABLE} -m pip install trimesh==3.2.33
    # For testing HTTP requests
    COMMAND ${Python3_EXECUTABLE} -m pip install twisted==21.2.0
    COMMAND ${Python3_EXECUTABLE} -m pip install urllib3==1.25.6
    COMMAND ${Python3_EXECUTABLE} -m pip install PyYAML==5.1.2
    COMMAND ${Python3_EXECUTABLE} -m pip install zeroconf==0.24.1
    COMMENT "Install Python packages"
    DEPENDS NumpyScipyShapely
)

# OS-specific Packages
if(BUILD_OS_WINDOWS)
    add_custom_command(TARGET PythonPackages POST_BUILD
        COMMAND ${Python3_EXECUTABLE} -m pip install comtypes==1.1.7
        COMMENT "Install comtypes"
    )
endif()
