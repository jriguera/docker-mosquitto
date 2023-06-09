#!/usr/bin/env bash

HEALTHCHECK_CLIENT_ID=healthcheck
HEALTHCHECK_TOPIC='$SYS/broker/uptime'
MOSQUITTO_FINAL_CONFIG_DIR="${C_ETCDIR:-/etc/mosquitto}"

# find a listener using sockets
if SOCKET=$(sed -n '/^listener\s\+0 .*/{s/^listener\s\+0\s\+\(.*\)$/\1/p;h};${x;/./{x;q0};x;q1}' "${MOSQUITTO_FINAL_CONFIG_DIR}/mosquitto.conf")
then
    exec mosquitto_sub --unix ${SOCKET} -t ${HEALTHCHECK_TOPIC} -E -C 1 -i ${HEALTHCHECK_CLIENT_ID} -W 3
else
    exec mosquitto_sub -h 127.0.0.1 -t ${HEALTHCHECK_TOPIC} -E -C 1 -i ${HEALTHCHECK_CLIENT_ID} -W 3
fi