#!/usr/bin/env bash

SCRIPTS_DIR=$(dirname "$0")
CMAKE_DIR="${SCRIPTS_DIR}/../cmake"
BUILD_OUTPUT_DIR="${SCRIPTS_DIR}/../cmake-build"

mkdir -p ${BUILD_OUTPUT_DIR}
pushd ${BUILD_OUTPUT_DIR}
cmake ${CMAKE_DIR}

if [[ ! ${jobs+1} ]]; then
    if command -v nproc &>/dev/null; then # For linux
        jobs=$(nproc)
    elif command -v sysctl &>/dev/null; then # For macOS
        jobs=$(sysctl -n hw.logicalcpu)
    else
        jobs=4
    fi
fi

make -j ${jobs} protoc
make -j ${jobs} install/local
popd
