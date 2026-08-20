#!/bin/bash
# Source this (do not execute) after entering the genie3 container:
#   source activate_neut.sh
# Sets up NEUT's own env vars, plus ROOT's lib dir on LD_LIBRARY_PATH --
# NEUT binaries (e.g. neutroot2) aren't built with an rpath to ROOT, unlike
# the container's own `root` binary, so this has to be done by hand every
# session or they fail with "libRint.so: cannot open shared object file".

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"

source "${BASE_DIR}/neut/build/Linux/bin/setup.NEUT.sh"
export LD_LIBRARY_PATH="$(root-config --libdir):${LD_LIBRARY_PATH}"
