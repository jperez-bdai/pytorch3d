#!/bin/bash
# Copyright (c) 2024 Boston Dynamics AI Institute LLC.  All rights reserved.

whoiam=$(whoami)
export DOCKER_USER="${whoiam}"
docker_uid=$(id -u)
export DOCKER_UID="${docker_uid}"

# Support X11 forwarding.
XAUTH=/home/$DOCKER_USER/.Xauthority
echo "Preparing Xauthority data..."
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi
echo Xauth: $XAUTH

# Initialize Git variables
git_user_email=$(git config user.email)
export GIT_USER_EMAIL="${git_user_email}"
git_user_name=$(git config user.name)
export GIT_USER_NAME="${git_user_name}"

# Start docker
docker run -it --rm\
            --user root:root\
            --env DOCKER_USER=$DOCKER_USER\
            --env DOCKER_UID=$DOCKER_UID\
            --env "GIT_USER_EMAIL=$GIT_USER_EMAIL"\
            --env "GIT_USER_NAME=$GIT_USER_NAME"\
            --env "GITHUB_TOKEN=$GITHUB_TOKEN"\
            --env "TERM=xterm-256color"\
            --env "DISPLAY=$DISPLAY"\
            --env "XAUTHORITY=$XAUTH"\
            --env QT_X11_NO_MITSHM=1\
            --env NVIDIA_VISIBLE_DEVICES=all\
            --env NVIDIA_DRIVER_CAPABILITIES=all\
            --volume /home/$DOCKER_USER/.Xauthority:/home/$DOCKER_USER/.Xauthority:rw\
            --volume /tmp/.X11-unix/:/tmp/.X11-unix:rw\
            --network=host\
            --ipc=host\
            --group-add video\
            --workdir /inside\
            --runtime nvidia pytorch3d-wheel-arm64
