# docker-rpi-mosquitto

Mosquitto Docker image based on Alpine for the Raspberry Pi.

Mosquitto is a message broker that implements the MQTT protocol


### Develop and test builds

Just type:

```
docker build . -t mosquitto
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
MQTT_LOG=stdout
MQTT_PERSISTENCE=true
MQTT_ADDRESS=0.0.0.0
MQTT_USER=user
MQTT_PASSWORD=home
```

And use them:

```
docker run --name mqtt -p 1883:1883 -v $(pwd)/datadir:/mqtt -e MQTT_PERSISTENCE=false -e MQTT_USER=micasa -e MQTT_PASSWORD=home -d jriguera/mosquitto

```



# Author

Jose Riguera `<jriguera@gmail.com>`
