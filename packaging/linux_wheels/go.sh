#!/usr/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Some directory to persist downloaded conda packages
conda_cache=/raid/$USER/building_conda_cache

mkdir -p "$conda_cache"

sudo docker run --rm -v "$conda_cache:/conda_cache" -v "$PWD/../../:/inside" -e SELECTED_CUDA=cu124 pytorch3d-wheel-arm64:latest bash /inside/packaging/linux_wheels/inside.sh
