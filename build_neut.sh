#!/bin/bash                                                                                                                                                                                              

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"
NEUT_DIR="${BASE_DIR}/neut"

if [[ -z "${SINGULARITY_CONTAINER}${APPTAINER_CONTAINER}" ]]; then
  echo "error: not running inside the genie3 singularity container. Enter it first:" >&2
  echo "  singularity shell -B/pnfs:/pnfs,/cvmfs:/cvmfs,/exp/annie/data:/exp/annie/data,/exp/annie/app:/exp/annie/app /cvmfs/singularity.opensciencegrid.org/anniesoft/genie3:latest/" >&2
  exit 1
fi

cd "${NEUT_DIR}" || exit 1

# Not checking out a tagged release here -- building whatever is currently
# checked out in neut/.
# git fetch --tags
# git checkout tags/6.1.4

mkdir -p build
cd build || exit 1

cmake .. \
  -DNEUT_DOWNLOAD_DATA=OFF \
  -DNEUT_WERROR_ENABLED=OFF

make -j 4
make install

# Once installed, source the generated setup script to get NEUT's env vars
# (NEUTROOT, PATH, LD_LIBRARY_PATH) into your shell:
#   source ${NEUT_DIR}/build/Linux/bin/setup.NEUT.sh
