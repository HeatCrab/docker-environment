#!/bin/bash

help() {
    cat <<EOF
Usage:
    eman help                       : Show this help
    eman check-verilator            : Print the version of the first found Verilator (if there are multiple version of Verilator installed)
    eman verilator-example <PATH>   : Compile and run the Verilator example(s) with example path
    eman c-compiler-version         : Print the version of default C compiler and the version of GNU Make
    eman c-compiler-example <PATH>  : Compile and run the C/C++ example(s) with example path
EOF
}

case "$1" in
    help|--help|-h) 
        help;;
    check-verilator)
        verilator --version;;
    verilator-example)
        shift
        cd "$1" && make clean all;;
    c-compiler-version)
        gcc --version; make --version;;
    c-compiler-example)
        shift
        cd "$1" && make clean all;;
    *)
        echo "Unknown command: $1"; help;;
esac