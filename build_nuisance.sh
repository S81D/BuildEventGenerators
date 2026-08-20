#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"

# Same reasoning as build_neut.sh: don't source global_vars.sh/setup_generators.sh
# here. That pulls in UPS cmake/root (SL7-era, needs libssl.so.10) which this
# container doesn't have -- "cmake: error while loading shared libraries:
# libssl.so.10". Build against the container's own native cmake/gcc/ROOT instead.
if [[ -z "${SINGULARITY_CONTAINER}${APPTAINER_CONTAINER}" ]]; then
  echo "error: not running inside the genie3 singularity container. Enter it first:" >&2
  echo "  singularity shell -B/pnfs:/pnfs,/cvmfs:/cvmfs,/exp/annie/data:/exp/annie/data,/exp/annie/app:/exp/annie/app /cvmfs/singularity.opensciencegrid.org/anniesoft/genie3:latest/" >&2
  exit 1
fi

# NUISANCE needs to find our already-built NEUT (NEUT_ROOT) and ROOT's libs
# on LD_LIBRARY_PATH -- same activation step needed to run neutroot2 directly.
source "${BASE_DIR}/activate_neut.sh"

cd "${BASE_DIR}" || exit 1

if [ ! -d nuisance ]; then
  git clone https://github.com/NUISANCEMC/nuisance.git
fi
cd nuisance || exit 1
#git checkout v2r8

mkdir -p build
cd build || exit 1

# Only NEUT is actually built right now -- GENIE/NuWro/GiBUU/nusystematics
# are left OFF since enabling them without a build would just fail to find
# them. Flip these back to ON once/if those pieces get built.
cmake .. \
  -DGENIE_ENABLED=OFF \
  -DNuWro_ENABLED=OFF \
  -DNEUT_ENABLED=ON \
  -DGiBUU_ENABLED=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DProb3plusplus_ENABLED=ON \
  -Dnusystematics_ENABLED=OFF \
  -DNuHepMC_ENABLED=OFF

make -j 4
make install
