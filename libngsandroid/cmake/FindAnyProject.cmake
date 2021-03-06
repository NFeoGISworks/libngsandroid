################################################################################
# Project:  external projects
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015-2017, NextGIS <info@nextgis.com>
# Copyright (C) 2015 Dmitry Baryshnikov
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

set(TARGET_LINK_LIB) # ${TARGET_LINK_LIB} ""
set(DEPENDENCY_LIB) # ${DEPENDENCY_LIB} ""
set(WITHOPT ${WITHOPT} "")
set(EXPORTS_PATHS)
set(LINK_SEARCH_PATHS)

include (CMakeParseArguments)

function(find_anyproject name)

    string(TOUPPER ${name} UPPER_NAME)
    set(IS_FOUND ${UPPER_NAME}_FOUND)
    set(VERSION_STRING ${UPPER_NAME}_VERSION_STRING)
    if(NOT DEFINED ${IS_FOUND}) #if the package was found anywhere
        set(${IS_FOUND} FALSE)
    endif()

    set(options OPTIONAL REQUIRED QUIET EXACT MODULE)
    set(oneValueArgs DEFAULT VERSION SHARED)
    set(multiValueArgs CMAKE_ARGS COMPONENTS)
    cmake_parse_arguments(find_anyproject "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if (find_anyproject_REQUIRED OR find_anyproject_DEFAULT)
        set(_WITH_OPTION_ON TRUE)
    else()
        set(_WITH_OPTION_ON FALSE)
    endif()

    if(NOT DEFINED find_anyproject_SHARED)
        set(find_anyproject_SHARED ${BUILD_SHARED_LIBS})
    endif()

    if(DEFINED WITH_${name})
        set(WITHOPT "${WITHOPT}option(WITH_${name} \"Set ON to use ${name}\" ${WITH_${name}})\n")
        if(DEFINED WITH_${name}_EXTERNAL)
            set(WITHOPT "${WITHOPT}option(WITH_${name}_EXTERNAL \"Set ON to use external ${name}\" ${WITH_${name}_EXTERNAL})\n")
        else()
            set(WITHOPT "${WITHOPT}option(WITH_${name}_EXTERNAL \"Set ON to use external ${name}\" OFF)\n")
        endif()
    else()
        set(WITHOPT "${WITHOPT}option(WITH_${name} \"Set ON to use ${name}\" ${_WITH_OPTION_ON})\n")
        set(WITHOPT "${WITHOPT}option(WITH_${name}_EXTERNAL \"Set ON to use external ${name}\" OFF)\n")
        option(WITH_${name} "Set ON to use ${name}" ${_WITH_OPTION_ON})
    endif()

    write_ext_options(find_anyproject_SHARED)

    if(WITH_${name})
        option(WITH_${name}_EXTERNAL "Set ON to use external ${name}" OFF)
        if(WITH_${name}_EXTERNAL)
            include(FindExtProject)
            find_extproject(${name} ${ARGN})
        else()
            # transfer some input options to find_package arguments
            if(find_anyproject_VERSION)
                set(FIND_PROJECT_ARG ${find_anyproject_VERSION})
            endif()
            if(find_anyproject_EXACT)
                set(FIND_PROJECT_ARG ${FIND_PROJECT_ARG} EXACT)
            endif()
            if(find_anyproject_QUIET)
                set(FIND_PROJECT_ARG ${FIND_PROJECT_ARG} QUIET)
            endif()
            if(find_anyproject_MODULE)
                set(FIND_PROJECT_ARG ${FIND_PROJECT_ARG} MODULE)
            endif()
            #if(find_anyproject_REQUIRED)
            #    set(FIND_PROJECT_ARG ${FIND_PROJECT_ARG} REQUIRED)
            #endif()
            if(find_anyproject_COMPONENTS)
                set(FIND_PROJECT_ARG ${FIND_PROJECT_ARG} COMPONENTS ${find_anyproject_COMPONENTS})
            endif()

            find_package(${name} ${FIND_PROJECT_ARG} CONFIG QUIET)
            if(${name}_FOUND AND (${name}_RUN_IN_MODULE_MODE OR ${UPPER_NAME}_RUN_IN_MODULE_MODE))
                find_package(${name} ${FIND_PROJECT_ARG} MODULE QUIET)
            endif()
            if(${name}_FOUND OR ${UPPER_NAME}_FOUND)
                set(FOUND_WITH_CONFIG_MODE TRUE)
            else()
                message(STATUS "Not found ${name} in packages. Try look in system.")
                find_package(${name} ${FIND_PROJECT_ARG})
            endif()

            if(${name}_FOUND)
                set(${UPPER_NAME}_FOUND ${${name}_FOUND})
            endif()
            if(${UPPER_NAME}_FOUND)
                set(${name}_FOUND ${${UPPER_NAME}_FOUND})
            endif()

            if(${name}_VERSION_STRING)
                set(${UPPER_NAME}_VERSION_STRING ${${name}_VERSION_STRING})
            endif()
            if(${UPPER_NAME}_VERSION_STRING)
                set(${name}_VERSION_STRING ${${UPPER_NAME}_VERSION_STRING})
            endif()

            if(${name}_INCLUDE_DIRS)
                set(${UPPER_NAME}_INCLUDE_DIRS ${${name}_INCLUDE_DIRS})
            endif()
            if(${UPPER_NAME}_INCLUDE_DIRS)
                set(${name}_INCLUDE_DIRS ${${UPPER_NAME}_INCLUDE_DIRS})
            endif()

            if(${name}_INCLUDE_DIR)
                set(${UPPER_NAME}_INCLUDE_DIR ${${name}_INCLUDE_DIR})
            endif()
            if(${UPPER_NAME}_INCLUDE_DIR)
                set(${name}_INCLUDE_DIR ${${UPPER_NAME}_INCLUDE_DIR})
            endif()

            if(${name}_LIBRARIES)
                set(${UPPER_NAME}_LIBRARIES ${${name}_LIBRARIES})
            endif()
            if(${UPPER_NAME}_LIBRARIES)
                set(${name}_LIBRARIES ${${UPPER_NAME}_LIBRARIES})
            endif()

            if(${name}_LIBRARY)
                set(${UPPER_NAME}_LIBRARY ${${name}_LIBRARY})
            endif()
            if(${UPPER_NAME}_LIBRARY)
                set(${name}_LIBRARY ${${UPPER_NAME}_LIBRARY})
            endif()

            if(FOUND_WITH_CONFIG_MODE)
                message(STATUS "Found ${name} in package repository: ${${UPPER_NAME}_LIBRARY} (found version \"${${UPPER_NAME}_VERSION}\")")
            endif()
        endif()

        #message(STATUS "VERSION_STRING ${VERSION_STRING} ${${VERSION_STRING}}")
        if(${IS_FOUND})
            set(${IS_FOUND} TRUE CACHE INTERNAL "use ${name}")
            set(${VERSION_STRING} ${${VERSION_STRING}} CACHE INTERNAL "version ${name}")
            if(${UPPER_NAME}_INCLUDE_DIRS)
                set(${UPPER_NAME}_INCLUDE_DIRS ${${UPPER_NAME}_INCLUDE_DIRS} CACHE INTERNAL "include directories ${name}")
            endif()
            if(${UPPER_NAME}_INCLUDE_DIR)
                set(${UPPER_NAME}_INCLUDE_DIR ${${UPPER_NAME}_INCLUDE_DIR} CACHE INTERNAL "include directories ${name}")
            endif()
            if(${UPPER_NAME}_LIBRARIES)
                set(${UPPER_NAME}_LIBRARIES ${${UPPER_NAME}_LIBRARIES} CACHE INTERNAL "library ${name}")
            endif()
            if(${UPPER_NAME}_LIBRARY)
                set(${UPPER_NAME}_LIBRARY ${${UPPER_NAME}_LIBRARY} CACHE INTERNAL "library ${name}")
            endif()
            if(${UPPER_NAME}_VERSION)
                set(${UPPER_NAME}_VERSION ${${UPPER_NAME}_VERSION} CACHE INTERNAL "library ${name} version")
                set(${UPPER_NAME}_VERSION_STR ${${UPPER_NAME}_VERSION} CACHE INTERNAL "library ${name} version")
            endif()

            mark_as_advanced(${IS_FOUND}
                ${UPPER_NAME}_INCLUDE_DIR
                ${UPPER_NAME}_INCLUDE_DIRS
                ${UPPER_NAME}_LIBRARY
                ${UPPER_NAME}_LIBRARIES
                ${UPPER_NAME}_VERSION
                ${UPPER_NAME}_VERSION_STR
            )
        elseif(find_anyproject_REQUIRED)
            message(FATAL_ERROR "${name} is required in ${PROJECT_NAME}!")
        else()
            message(WARNING "${name} not found and will be disabled in ${PROJECT_NAME}!")
        endif()
    endif()

    if(NOT WITH_${name}_EXTERNAL AND ${IS_FOUND})
        if(${UPPER_NAME}_INCLUDE_DIRS)
            include_directories(${${UPPER_NAME}_INCLUDE_DIRS})
        elseif(${UPPER_NAME}_INCLUDE_DIR)
            include_directories(${${UPPER_NAME}_INCLUDE_DIR})
        elseif(${name}_INCLUDE_DIRS)
            include_directories(${${name}_INCLUDE_DIRS})
        elseif(${name}_INCLUDE_DIR)
            include_directories(${${name}_INCLUDE_DIR})
        endif()

        # Special case for Qt4
        if(QT4_FOUND)
            if (NOT TARGET Qt4::qmake)
                add_executable(Qt4::qmake IMPORTED)
                set_property(TARGET Qt4::qmake PROPERTY IMPORTED_LOCATION ${QT_QMAKE_EXECUTABLE})
            endif()
            if (NOT TARGET Qt4::moc)
                add_executable(Qt4::moc IMPORTED)
                set_property(TARGET Qt4::moc PROPERTY IMPORTED_LOCATION ${QT_MOC_EXECUTABLE})
            endif()
            if (NOT TARGET Qt4::rcc)
                add_executable(Qt4::rcc IMPORTED)
                set_property(TARGET Qt4::rcc PROPERTY IMPORTED_LOCATION ${QT_RCC_EXECUTABLE})
            endif()
            if (NOT TARGET Qt4::uic)
                add_executable(Qt4::uic IMPORTED)
                set_property(TARGET Qt4::uic PROPERTY IMPORTED_LOCATION ${QT_UIC_EXECUTABLE})
            endif()
            if (NOT TARGET Qt4::lrelease)
                add_executable(Qt4::lrelease IMPORTED)
                set_property(TARGET Qt4::lrelease PROPERTY IMPORTED_LOCATION ${QT_LRELEASE_EXECUTABLE})
            endif()

            mark_as_advanced(Qt4::qmake Qt4::moc Qt4::rcc Qt4::uic Qt4::lrelease)

            foreach(QT4_NEED_COMPONENT ${find_anyproject_COMPONENTS})
                string(TOUPPER ${QT4_NEED_COMPONENT} QT4_NEED_COMPONENT)
                if(QT_${QT4_NEED_COMPONENT}_LIBRARY)
                    set(${UPPER_NAME}_LIBRARIES ${${UPPER_NAME}_LIBRARIES} ${QT_${QT4_NEED_COMPONENT}_LIBRARY})
                elseif(QT_${QT4_NEED_COMPONENT}_LIBRARY_RELEASE)
                    set(${UPPER_NAME}_LIBRARIES ${${UPPER_NAME}_LIBRARIES} ${QT_${QT4_NEED_COMPONENT}_LIBRARY_RELEASE})
                elseif(QT_${QT4_NEED_COMPONENT}_LIBRARY_DEBUG)
                    set(${UPPER_NAME}_LIBRARIES ${${UPPER_NAME}_LIBRARIES} ${QT_${QT4_NEED_COMPONENT}_LIBRARY_DEBUG})
                endif()
                include_directories(${QT_${QT4_NEED_COMPONENT}_INCLUDE_DIR})
                get_filename_component(PARENT_DIR ${QT_${QT4_NEED_COMPONENT}_INCLUDE_DIR} DIRECTORY)
                include_directories(${PARENT_DIR})
            endforeach()

            include(Qt4Macros)
        endif()

        if(${UPPER_NAME}_LIBRARIES)
            set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${${UPPER_NAME}_LIBRARIES} PARENT_SCOPE)
        elseif(${UPPER_NAME}_LIBRARY)
            set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${${UPPER_NAME}_LIBRARY} PARENT_SCOPE)
        elseif(${name}_LIBRARIES)
            set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${${name}_LIBRARIES} PARENT_SCOPE)
        elseif(${name}_LIBRARY)
            set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${${name}_LIBRARY} PARENT_SCOPE)
        endif()
    else()
        set(TARGET_LINK_LIB ${TARGET_LINK_LIB} PARENT_SCOPE)
        set(DEPENDENCY_LIB ${DEPENDENCY_LIB} PARENT_SCOPE)
    endif()
    set(WITHOPT ${WITHOPT} PARENT_SCOPE)
    set(EXPORTS_PATHS ${EXPORTS_PATHS} PARENT_SCOPE)
    set(LINK_SEARCH_PATHS ${LINK_SEARCH_PATHS} PARENT_SCOPE)

    write_ext_options(find_anyproject_SHARED)
endfunction()

function(target_link_extlibraries name)
    if(DEPENDENCY_LIB)
        add_dependencies(${name} ${DEPENDENCY_LIB})
    endif()
    if(LINK_SEARCH_PATHS)
        link_directories(${LINK_SEARCH_PATHS})
    endif()
    if(TARGET_LINK_LIB)
        #list(REMOVE_DUPLICATES TARGET_LINK_LIB) debug;...;optimised;... etc. if filter out
        target_link_libraries(${name} ${TARGET_LINK_LIB})
    endif()

endfunction()

macro(any_project_var_to_parent_scope)
    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} PARENT_SCOPE)
    set(DEPENDENCY_LIB ${DEPENDENCY_LIB} PARENT_SCOPE)
    set(EXPORTS_PATHS ${EXPORTS_PATHS} PARENT_SCOPE)
    set(LINK_SEARCH_PATHS ${LINK_SEARCH_PATHS} PARENT_SCOPE)
endmacro()

macro(write_ext_options IS_SHARED)
    set(OUTPUT_STR ${WITHOPT})
    if(NOT ${IS_SHARED})
        if(EXPORTS_PATHS)
            foreach(EXPORT_PATH ${EXPORTS_PATHS})
                string(CONCAT EXPORTS_PATHS_STR ${EXPORTS_PATHS_STR} " \"${EXPORT_PATH}\"")
            endforeach()
            set(OUTPUT_STR "${OUTPUT_STR}set(INCLUDE_EXPORTS_PATHS \${INCLUDE_EXPORTS_PATHS} ${EXPORTS_PATHS_STR})\n")
        endif()
    endif()
    if(LINK_SEARCH_PATHS)
        foreach(LINK_SEARCH_PATH ${LINK_SEARCH_PATHS})
            string(CONCAT LINK_SEARCH_PATHS_STR ${LINK_SEARCH_PATHS_STR} " \"${LINK_SEARCH_PATH}\"")
        endforeach()
        set(OUTPUT_STR "${OUTPUT_STR}set(INCLUDE_LINK_SEARCH_PATHS \${INCLUDE_LINK_SEARCH_PATHS} ${LINK_SEARCH_PATHS_STR})\n")
    endif()
    file(WRITE ${CMAKE_BINARY_DIR}/ext_options.cmake ${OUTPUT_STR})
endmacro()
