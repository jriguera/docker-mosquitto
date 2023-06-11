#!/usr/bin/env bash
set -eo pipefail
[[ ${DEBUG} =~ (true|1|yes) ]] && set -x

# Defined in the Dockerfile but
# if undefined, populate environment variables with sane defaults
MOSQUITTO_DATA="${C_DATADIR:-/mtqq}"
MOSQUITTO_INPUT_CONFIG_DIR="${C_CONFIGDIR:-/config}"
MOSQUITTO_FINAL_CONFIG_DIR="${C_ETCDIR:-/etc/mosquitto}"
MOSQUITTO_USER="${C_USERNAME:-mosquitto}"
MOSQUITTO_GROUP="${C_GROUPNAME:-mosquitto}"
MOSQUITTO_RUNDIR="${C_RUNDIR:-/run/mosquitto}"

MOSQUITTO_INCLUDE_DIR="${MOSQUITTO_INCLUDE_DIR:-${MOSQUITTO_FINAL_CONFIG_DIR}/conf.d}"
MOSQUITTO_FINAL_TEMPLATE_CONFIG="${MOSQUITTO_FINAL_TEMPLATE_CONFIG:-${MOSQUITTO_FINAL_CONFIG_DIR}/mosquitto.conf.template}"
MOSQUITTO_USERS_FILE="${MOSQUITTO_USERS_FILE:-${MOSQUITTO_FINAL_CONFIG_DIR}/users}"

# Mosquitto configuration parameters and defaults
MQTT_PORT=${MQTT_PORT:-${PORT}}
MQTT_LOG_DST="${MQTT_LOG_DST:-stdout}"
MQTT_LOG_LEVEL=(${MQTT_LOG_LEVEL:-error warning notice information})
MQTT_LOG_CONNECTIONS="${MQTT_LOG_CONNECTIONS:-true}"
MQTT_ALLOW_ANONYMOUS="${MQTT_ALLOW_ANONYMOUS:-false}"
MQTT_PERSISTENCE="${MQTT_PERSISTENCE:-true}"
MQTT_AUTOSAVE="${MQTT_AUTOSAVE:-300}"
MQTT_AUTOSAVE_ON_CHANGES="${MQTT_AUTOSAVE_ON_CHANGES:-false}"
MQTT_MAX_CONNECTIONS="${MQTT_MAX_CONNECTIONS:-500}"
MQTT_MAX_QUEUED_MESSAGES="${MQTT_MAX_QUEUED_MESSAGES:-100}"
MQTT_SET_TCP_NODELAY="${MQTT_SET_TCP_NODELAY:-true}"
MQTT_MAX_KEEPALIVE="${MQTT_MAX_KEEPALIVE:-65535}"
MQTT_USE_USERNAME_AS_CLIENTID="${MQTT_USE_USERNAME_AS_CLIENTID:-false}"
MQTT_ALLOW_NO_CLIENTID="${MQTT_ALLOW_NO_CLIENTID:-true}"

# Define a list of user:password list separated by spaces
MQTT_USERS_LIST=(${MQTT_USERS:-})

# Usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="${1}"
    local def="${2:-}"

    local fvar="${var}_FILE"
    local val="${def}"
    if [[ -n "${!var:-}" ]] &&  [[ -r "${fvar}" ]]
    then
        echo "* Warning: both ${var} and ${fvar} are set, environment ${var} takes priority"
    fi
    [[ -r "${fvar}" ]] && val=$(< "${fvar}")
    [[ -n "${!var:-}" ]] && val="${!var}"
    export "${var}"="${val}"
}

# Render a template configuration file
# expand variables + preserve formatting
render_template() {
    local template="${1}"

    eval "echo \"$(cat ${template})\""
}

# If command starts with an option, prepend mosquitto
[[ ${1:0:1} = '-' ]] && set -- mosquitto "$@"

# allow the container to be started with `--user`
if [[ ${1} == 'mosquitto' ]] && [[ $(id -u) -eq 0 ]]
then
    chown -R "${MOSQUITTO_USER}:${MOSQUITTO_GROUP}" "${MOSQUITTO_DATA}" "${MOSQUITTO_FINAL_CONFIG_DIR}" "${MOSQUITTO_RUNDIR}"
    exec su-exec ${MOSQUITTO_USER} "${BASH_SOURCE}" "$@"
fi

if [[ ${1} == 'mosquitto' ]]
then
    # if no configfile is provided, generate one based on the environment variables
    if [[ -r "${MOSQUITTO_INPUT_CONFIG_DIR}/mosquitto.conf" ]]
    then
        echo "* Copying configuration from ${MOSQUITTO_INPUT_CONFIG_DIR}/mosquitto.conf ..."
        rm -rf "${MOSQUITTO_FINAL_CONFIG_DIR}"/*
        cp -v "${MOSQUITTO_INPUT_CONFIG_DIR}"/* "${MOSQUITTO_FINAL_CONFIG_DIR}"/
    else
        echo "* Generating default configuration from environment variables ..."
        render_template "${MOSQUITTO_FINAL_TEMPLATE_CONFIG}" > "${MOSQUITTO_FINAL_CONFIG_DIR}/mosquitto.conf"
    fi

    if [[ ! -r "${MOSQUITTO_INCLUDE_DIR}/default.conf" ]]
    then
        echo "* Generating default listener from environment variables ..."
        cat <<-EOF > "${MOSQUITTO_INCLUDE_DIR}/default.conf"
			listener ${MQTT_PORT:-1883} 0.0.0.0
			allow_anonymous ${MQTT_ALLOW_ANONYMOUS:-false}
			password_file ${MOSQUITTO_USERS_FILE}
			allow_zero_length_clientid ${MQTT_ALLOW_NO_CLIENTID:-true}
			auto_id_prefix generated-
			max_connections ${MQTT_MAX_CONNECTIONS:-500}
			max_keepalive ${MQTT_MAX_KEEPALIVE:-65535}
			set_tcp_nodelay ${MQTT_SET_TCP_NODELAY:-true}
			EOF
    else
        echo "* Default listener already defined in "${MOSQUITTO_INCLUDE_DIR}/default.conf", skipping..."
    fi

    if [[ ! -r "${MQTT_USERS_FILE}" ]]
    then
        if [[ "${#MQTT_USERS_LIST[@]}" -eq 0 ]] && ! [[ "${MQTT_ALLOW_ANONYMOUS}" =~ (true|TRUE|True) ]]
        then
            echo "* Warning: No MQTT_USERS variable with users and password defined, and MQTT_ALLOW_ANONYMOUS is not true"
            userpass="default:$(pwgen -s -1 10)"
            echo "* Generated a default user and password for the clients to connect: <${userpass}>"
            MQTT_USERS_LIST+=("${userpass}")
        fi
        touch "${MOSQUITTO_USERS_FILE}"
        for item in ${MQTT_USERS_LIST[@]}
        do
            userpass=(${item//:/ })
            echo "* Allowing user "${userpass[0]}" and its password ..."
            mosquitto_passwd -b "${MOSQUITTO_USERS_FILE}" "${userpass[0]}" "${userpass[1]}"
        done
        echo "* Generated users file in ${MOSQUITTO_USERS_FILE}"
    fi
fi

# Load dumps or execute other files
for f in /docker-entrypoint-initdb.d/*
do
	case "${f}" in
		*.sh)
			echo "* Running ${f} ..."
			( . "${f}" )
		;;
		*)
			echo "* Ignoring ${f} ..."
		;;
	esac
done

exec "$@"
