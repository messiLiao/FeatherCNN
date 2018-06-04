# **********************************************************
# Copyright (c) 2014-2017 Google, Inc.    All rights reserved.
# **********************************************************

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of Google, Inc. nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL GOOGLE, INC. OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.

# For cross-compiling on arm64 Linux using gcc-aarch64-linux-gnu package:
# - install AArch64 tool chain:
#   $ sudo apt-get install g++-aarch64-linux-gnu
# - cross-compiling config
#   $ cmake -DCMAKE_TOOLCHAIN_FILE=../dynamorio/make/toolchain-arm64.cmake ../dynamorio
# You may have to set CMAKE_FIND_ROOT_PATH to point to the target enviroment, e.g.
# by passing -DCMAKE_FIND_ROOT_PATH=/usr/aarch64-linux-gnu on Debian-like systems.

set(CMAKE_SYSTEM_NAME RTEMS)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(TARGET_ABI "linux-gnu")

# toolchain setup for rtems
set(ARCH arm )
set(BSP beagleboneblack )
set(RTEMS_VERSION 5)
set(RTEMS_TOOLS             "$ENV{HOME}/opt/rtems/${RTEMS_VERSION}/${ARCH}-rtems${RTEMS_VERSION}")

## bsp path
set(BSP_DIR                 "$ENV{HOME}/opt/rtems/${RTEMS_VERSION}")

set(RTEMS_TOOLS_INCLUDE     "${RTEMS_TOOLS}/include")
set(RTEMS_TOOLS_LIB         "${RTEMS_TOOLS}/lib")
set(RTEMS_BSP_INCLUDE       "${BSP_DIR}/${ARCH}-rtems${RTEMS_VERSION}/${BSP}/lib/include")
set(RTEMS_BSP_LIB           "${BSP_DIR}/${ARCH}-rtems${RTEMS_VERSION}/${BSP}/lib")

## specify the cross compiler
find_program(C_COMPILER ${ARCH}-rtems${RTEMS_VERSION}-gcc)
if(NOT C_COMPILER)
    message(FATAL_ERROR "could not find ${ARCH}-rtems${RTEMS_VERSION}-gcc compiler")
endif()
set(CMAKE_C_COMPILER ${C_COMPILER} )

find_program(CXX_COMPILER ${ARCH}-rtems${RTEMS_VERSION}-g++)
if(NOT CXX_COMPILER)
    message(FATAL_ERROR "could not find ${ARCH}-rtems${RTEMS_VERSION}-g++ compiler")
endif()
set(CMAKE_CXX_COMPILER ${C_COMPILER} )

# To build the tests, we need to set where the target environment containing
# the required library is. On Debian-like systems, this is
# /usr/aarch64-linux-gnu.
set(CMAKE_FIND_ROOT_PATH  get_file_component(${C_COMPILER} PATH))
# search for programs in the build host directories
# SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
# SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set additional variables.
# If we don't set some of these, CMake will end up using the host version.
# We want the full path, however, so we can pass EXISTS and other checks in
# the our CMake code.
# compiler tools
foreach(tool objcopy nm ld as strip cpp)
    string(TOUPPER ${tool} TOOL)
    find_program(${TOOL} arm-rtems4.12-${tool})
    if(NOT ${TOOL})
        message(FATAL_ERROR "could not find ${tool}")
    endif()
endforeach()


# for linker flags
set(RTEMS_LINKER_FLAGS "-B${RTEMS_BSP_LIB} -specs bsp_specs -qrtems -g -O2")
set(LINKER_FLAGS "-Wl,-gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS} ${RTEMS_LINKER_FLAGS}")

# for compiler flags
set(BSP_CFLAGS "-mcpu=cortex-a8 -mtune=cortex-a8 -march=armv7-a -mfloat-abi=softfp  -mfpu=neon -D__RTEMS__" )
set(RTEMS_C_FLAGS "${BSP_CFLAGS} -O2 -g -qrtems -B${RTEMS_BSP_LIB}" )
set(RTEMS_CXX_FLAGS "${BSP_CFLAGS} -O2 -g -qrtems -B${RTEMS_BSP_LIB}" )

set(CMAKE_C_FLAGS ${RTEMS_C_FLAGS})
set(CMAKE_CXX_FLAGS ${RTEMS_CXX_FLAGS})
set(CMAKE_CXX_LINKER_FLAGS ${RTEMS_CXX_FLAGS})

INCLUDE_DIRECTORIES(${RTEMS_TOOLS_INCLUDE} ${RTEMS_BSP_INCLUDE})
LINK_DIRECTORIES(${RTEMS_TOOLS_LIB} ${RTEMS_BSP_LIB})