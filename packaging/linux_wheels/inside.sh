#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

set -ex

source ~/miniconda3/bin/activate
conda init bash
# shellcheck source=/dev/null
source ~/.bashrc

cd /inside
VERSION=$(python -c "exec(open('pytorch3d/__init__.py').read()); print(__version__)")
ARCH="amd64"

export BUILD_VERSION=$VERSION
export FORCE_CUDA=1
export MAX_JOBS=8
export CONDA_PKGS_DIRS=/conda_cache

# As a rule, we want to build for any combination of dependencies which is supported by
# PyTorch3D and not older than the current Google Colab set up.

PYTHON_VERSIONS="3.10"
# the keys are pytorch versions
declare -A CONDA_CUDA_VERSIONS=(
    ["2.6.0"]="cu124"
)

for python_version in $PYTHON_VERSIONS
do
    for pytorch_version in "${!CONDA_CUDA_VERSIONS[@]}"
    do

        extra_channel="-c nvidia"
        cudatools="pytorch-cuda"

        for cu_version in ${CONDA_CUDA_VERSIONS[$pytorch_version]}
        do
            if [[ $SELECTED_CUDA != "$cu_version" ]]
            then
                continue
            fi
            case "$cu_version" in
                "cu124")
                    export CUDA_HOME=/usr/local/cuda-12.4/
                    export CUDA_TAG=12.4
                    export NVCC_FLAGS="-gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_70,code=sm_70 -gencode=arch=compute_75,code=sm_75 -gencode=arch=compute_50,code=compute_50"
                ;;
                *)
                    echo "Unrecognized cu_version=$cu_version"
                    exit 1
                ;;
            esac
            tag=py"${python_version//./}"_"${cu_version}"_pyt"${pytorch_version//./}"_"${ARCH}"

            outdir="/inside/packaging/linux_wheels/output/$tag"
            if [[ -d "$outdir" ]]
            then
                continue
            fi

            conda create -y -n "$tag" "python=$python_version"
            conda activate "$tag"
            # shellcheck disable=SC2086

            pip install iopath
            #conda install -y -c pytorch $extra_channel "pytorch=$pytorch_version" "$cudatools=$CUDA_TAG"
            #echo "python version" "$python_version" "pytorch version" "$pytorch_version" "cuda version" "$cu_version" "tag" "$tag"
            pip3 install torch==2.6 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

            rm -rf dist

            # Required to compile with CUDA
            # conda install -c bottler nvidiacub
            conda install -c conda-forge ninja

            python -c 'import torch; print("compiled or not?", torch.cuda._is_compiled())'
            python -c 'import torch; from torch.utils.cpp_extension import CUDA_HOME; print(torch.cuda.is_available(), CUDA_HOME)'
            python setup.py clean
            python setup.py bdist_wheel

            rm -rf "$outdir"
            mkdir -p "$outdir"
            cp dist/*whl "$outdir"

            conda deactivate
        done
    done
done
echo "DONE"
