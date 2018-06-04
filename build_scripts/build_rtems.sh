#!/bin/bash

mkdir -p build-rtems-arm
pushd build-rtems-arm
cmake -DCMAKE_TOOLCHAIN_FILE=../build_scripts/rtems-arm.toolchain.cmake .. -DFEATHER_ARM=1
make -j4
make install
popd
