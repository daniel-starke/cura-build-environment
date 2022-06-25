# Copyright (c) 2022 Ultimaker B.V.
# cura-build-environment is released under the terms of the AGPLv3 or higher.

if(WIN32)
    set(ext .pyd)
    set(env_path_sep ":")
    set(exe_ext ".exe")
    set(exe_path "bin")
    set(lib_path "lib")
else()
    set(ext .so)
    set(env_path_sep ":")
    set(exe_ext "")
    set(exe_path "bin")
    set(lib_path "lib")
endif()

if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()