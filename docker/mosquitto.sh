#!/bin/bash
set -eo pipefail

# Defined in the Dockerfile but
# if undefined, populate environment variables with sane defaults
MQTT_PATH=${MQTT_PATH:-/mtqq}
MQTT_CONFIG=${MQTT_CONFIG:-/config}
MQTT_LOG=${MQTT_LOG:-stdout}
MQTT_PERSISTENCE=${MQTT_PERSISTENCE:-true}
MQTT_PORT_DEFAULT=${MQTT_PORT_DEFAULT:-1883}
MQTT_ADDRESS=${MQTT_ADDRESS:-}
MQTT_USER=${MQTT_USER:-""}
MQTT_PASSWORD=${MQTT_PASSWORD:-""}
MQTT_USERS_FILE=/etc/mosquitto/users

# If command starts with an option, prepend mosquitto
if [ "${1:0:1}" = '-' ]
then
	set -- mosquitto "$@"
fi

# Skip setup if they want an option that stops mosquitto
HELP=0
for arg
do
	case "$arg" in
		-h|--help|--version)
			HELP=1
			break
		;;
	esac
done

# Usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local def="${2:-}"

	local var_file="${var}_FILE"
	local val="${def}"

	if [ "${!var:-}" ] && [ "${!var_file:-}" ]
	then
		echo >&2 "Warning: both ${var} and ${var_file} are set (${var_file} takes priority)"
	fi
	if [ "${!var_file:-}" ]
	then
		val="$(< "${!var_file}")"
	elif [ "${!var:-}" ]
	then
		val="${!var}"
	fi
	export "${var}"="${val}"
}

# allow the container to be started with `--user`
if [ "$1" == "mosquitto" ] && [ "${HELP}" == "0" ] && [ "$(id -u)" == '0' ]
then
	chown -R mosquitto:mosquitto "${MQTT_PATH}" "${MQTT_CONFIG}"
	exec su-exec mosquitto "${BASH_SOURCE}" "$@"
fi

# if no configfile is provided, generate one based on the environment variables
if [ -r "${MQTT_CONFIG}/mosquitto.conf" ]
then
       	echo "* Copying configuration from ${MQTT_CONFIG}/mosquitto.conf ..."
	rm -rf /etc/mosquitto/*
	cp "${MQTT_CONFIG}/mosquitto.conf" /etc/mosquitto/
else
       	echo "* Using env variables to generate configuration ..."
       	touch "${MQTT_USERS_FILE}"
	sed -ie "s|^log_dest .*\$|log_dest $MQTT_LOG|g" /etc/mosquitto/mosquitto.conf
	sed -ie "s|^persistence .*\$|persistence $MQTT_PERSISTENCE|g" /etc/mosquitto/mosquitto.conf
	sed -ie "s|^port .*\$|port $MQTT_PORT_DEFAULT|g" /etc/mosquitto/mosquitto.conf
	if ! [ -z "${MQTT_ADDRESS}" ]
	then
		sed -ie "s|^bind_address .*\$|bind_address $MQTT_ADDRESS|g" /etc/mosquitto/mosquitto.conf
	fi
	file_env 'MQTT_USER'
	file_env 'MQTT_PASSWORD'
	if ! [ -z "${MQTT_USER}" ]
	then
		rm -f "${MQTT_USERS_FILE}"
       		echo "* Generating user and password  ..."
		touch "${MQTT_USERS_FILE}"
		mosquitto_passwd -b "${MQTT_USERS_FILE}" "${MQTT_USER}" "${MQTT_PASSWORD}"
		sed -ie "s|^allow_anonymous .*\$|allow_anonymous false|g" /etc/mosquitto/mosquitto.conf
	fi
fi
chown -R mosquitto:mosquitto /etc/mosquitto

exec "$@"
