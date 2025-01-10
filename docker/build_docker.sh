#!/bin/bash
# Copyright (c) 2024 Boston Dynamics AI Institute LLC.  All rights reserved.

# Get github token
GITHUB_TOKEN=$(gh auth status -t 2>&1 | grep -oP 'Token:\s+\K[\w0-9_]+')
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "GitHub token could not be obtained. Starting container without GitHub token."
fi

docker build --progress=plain -t pytorch3d-wheel-arm64 -f docker/Dockerfile --build-arg GITHUB_TOKEN=$GITHUB_TOKEN .
