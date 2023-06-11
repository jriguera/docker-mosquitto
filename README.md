# docker-mosquitto

Mosquitto Docker image based on Alpine, multi-arch.
Mosquitto is a message broker that implements the MQTT protocol


### Develop and test builds

Just type:

```
docker-build.sh
```

### Create final release and publish to Docker Hub

```
create-release.sh
```


# Usage

Given the docker image with name `mosquitto` from Github Package Repository:

```
docker run --name mqtt -p 1883:1883 -v $(pwd)/datadir:/mqtt -d ghcr.io/jriguera/docker-mosquitto/mosquitto:latest
```

You can also use this env variables to automatically define some settings:

```
MQTT_USERS: "user1:password user2:password2"
```

And use them:

```
docker run --name mqtt -p 1883:1883 -v $(pwd)/datadir:/mqtt -e MQTT_PERSISTENCE=false -e MQTT_USERS="user1:password user2:password2" -d  ghcr.io/jriguera/docker-mosquitto/mosquitto:latest

```

## Variables

See `mosquitto.sh` for more details.

```
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
```
 
# Author

Jose Riguera `<jriguera@gmail.com>`
