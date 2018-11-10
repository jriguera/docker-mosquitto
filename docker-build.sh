#!/usr/bin/env bash

DOCKER=docker
NAME="mosquitto"

pushd docker
    $DOCKER build \
      --build-arg  ARCH=$(dpkg --print-architecture) \
      --build-arg TZ=$(timedatectl  | awk '/Time zone:/{ print $3 }') \
      .  -t $NAME
popd
