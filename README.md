# docker-rpi-mosquitto

Mosquitto Docker image based on Alpine
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


### Run

Given the docker image with name `mosquitto`:

```
docker run --name mqtt -p 1883:1883 -v $(pwd)/datadir:/mqtt -d jriguera/mosquitto
```

You can also use this env variables to automatically define some settings:

```
MQTT_USERS: "user1:password user2:password2"
```

And use them:

```
docker run --name mqtt -p 1883:1883 -v $(pwd)/datadir:/mqtt -e MQTT_PERSISTENCE=false -e MQTT_USERS="user1:password user2:password2" -d jriguera/mosquitto

```


# Author

Jose Riguera `<jriguera@gmail.com>`
