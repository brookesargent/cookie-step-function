#!/usr/bin/env bash

export GOARCH=amd64
export GOOS=linux
export GO111MODULE=on

get_build_programs()
{
    program_dir=${1}
    program_paths=$(find ${program_dir} -type f -name main.go -exec dirname '{}' \;)
    for path in ${program_paths} ; do
        basename ${path}
    done
}

if [ -d build ]; then 
    rm -rf build
fi

mkdir -p build/bin

functions=( $(get_build_programs functions) )
for function in ${functions[@]}; do
    go build -o build/bin/${function} functions/${function}/main.go
    zip -jq build/${function}.zip build/bin/${function}
done
