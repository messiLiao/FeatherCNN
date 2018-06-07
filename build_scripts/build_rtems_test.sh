#!/bin/bash

arm-rtems5-g++ -mcpu=cortex-a8 -mtune=cortex-a8 -march=armv7-a -mfloat-abi=softfp  -mfpu=neon -O2 -g -qrtems -B/home/messi/opt/rtems/5/arm-rtems5/beagleboneblack/lib -D__RTEMS__ -specs bsp_specs -qrtems -g -O2 ./test/test.cpp -I./build-rtems-arm/install/feather/include/ -L ./build-rtems-arm/install/feather/lib/ -lfeather -fopenmp -O3 -o feather_benchmark
