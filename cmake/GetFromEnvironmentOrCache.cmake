# Copyright 2022 Ultimaker

macro(GetFromEnvironmentOrCache)
    set(options BOOL FILEPATH PATH STRING INTERNAL REQUIRED)
    set(oneValueArgs NAME DEFAULT DESCRIPTION)
    set(multiValueArgs )
    cmake_parse_arguments(VAR "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT VAR_NAME)
        message(FATAL_ERROR "NAME is a required keyword")
    endif()

    if(NOT ${VAR_NAME})
        if(VAR_BOOL)
            set(VAR_CACHE BOOL)
        elseif(VAR_FILEPATH)
            set(VAR_CACHE FILEPATH)
        elseif(VAR_PATH)
            set(VAR_CACHE PATH)
        elseif(VAR_STRING)
            set(VAR_CACHE STRING)
        elseif(VAR_INTERNAL)
            set(VAR_CACHE INTERNAL)
        else()
            set(VAR_CACHE STRING)
        endif()

        if(DEFINED ENV{${VAR_NAME})
            set(VAR_VALUE $ENV{${VAR_NAME}})
            message(STATUS "Using value of environment variable for ${VAR_NAME}: ${VAR_VALUE}")
        elseif(DEFINED VAR_DEFAULT)
            set(VAR_VALUE ${VAR_DEFAULT})
            message(STATUS "Using default value for ${VAR_NAME}: ${VAR_VALUE}")
        elseif(VAR_REQUIRED)
            message(SEND_ERROR "${VAR_NAME} is a required variable, either provide a commandline arg, environment variable or default value")
        else()
            set(VAR_VALUE )
            message(STATUS "Using empty default value for ${VAR_NAME}")
        endif()

        if(NOT DEFINED VAR_DESCRIPTION)
            set(VAR_DESCRIPTION "")
        endif()

        set(${VAR_NAME}
                "${VAR_VALUE}"
                CACHE
                ${VAR_CACHE}
                ${VAR_DESCRIPTION}
                FORCE)
    else()
        message(STATUS "Using CMake provided variable ${VAR_NAME}: ${${VAR_NAME}}")
    endif()
endmacro()