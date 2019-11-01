# Mosquitto Docker

# docker build . -t mosquitto
# docker run --name mosquitto -v $(pwd)/datadir:/mqtt  mosquitto

ARG ARCH=arm32v6
FROM "${ARCH}/alpine:3.10"

ARG VERSION=1.6
ARG MYVERSION=jose1
ARG DATADIR=/mqtt
ARG CONFIGDIR=/config
ARG DEFAULTPORT=1883
ARG TLSPORT=8883
ARG UID=1000
ARG GUID=1000
ARG TZ=Europe/Amsterdam
ARG ARCH

LABEL org.label-schema.description="Mosquitto Docker image based on Alpine for the Raspberry Pi."
LABEL org.label-schema.name="rpi-mosquitto"
LABEL org.label-schema.version="${VERSION}-${MYVERSION}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.url="https://hub.docker.com/r/jriguera/rpi-mosquitto"
LABEL org.label-schema.vcs-url="https://github.com/jriguera/docker-rpi-mosquitto"
LABEL maintainer="Jose Riguera <jriguera@gmail.com>"
LABEL architecture="${ARCH}"

ENV MQTT_PATH="${DATADIR}"
ENV MQTT_CONFIG="${CONFIGDIR}"
ENV MQTT_LOG=stdout
ENV MQTT_PERSISTENCE=true
ENV MQTT_PORT_DEFAULT="${DEFAULTPORT}"
ENV MQTT_PORT_TLS="${TLSPORT}"

ENV LANG=en_US.utf8
ENV LC_ALL=C.UTF-8

RUN set -xe                                                                 && \
    apk -U upgrade                                                          && \
    # User/group
    addgroup -g "${GUID}" -S mosquitto                                             && \
    adduser -h "${DATADIR}" -D -G mosquitto -s /sbin/nologin -u "${UID}" mosquitto && \
    # Installing Alpine packages
    apk add --no-cache \
        mosquitto~${VERSION} \
        mosquitto-libs~${VERSION} \
        mosquitto-clients~${VERSION} \
        ca-certificates \
        pwgen \
        su-exec \
        tzdata \
        socat \
        net-tools \
        curl \
        bash \
                                                                            && \
    # Timezone
    cp "/usr/share/zoneinfo/${TZ}" /etc/localtime                           && \
    echo "${TZ}" > /etc/timezone                                            && \
    # clean up
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* /etc/mosquitto/*


COPY *.sh /usr/local/bin/
COPY etc /etc/mosquitto

RUN set -xe                                                                 && \
    chmod a+x /usr/local/bin/*                                              && \
    ln -s /usr/local/bin/mosquitto.sh /usr/local/bin/docker-entrypoint.sh   && \
    ln -s /usr/local/bin/mosquitto.sh /docker-entrypoint.sh                 && \
    ln -s /usr/local/bin/mosquitto.sh /run.sh                               && \
    mkdir -p /docker-entrypoint-initdb.d                                    && \
    mkdir -p "${DATADIR}"                                                   && \
    mkdir -p "${CONFIGDIR}"                                                 && \
    touch /etc/mosquitto/users                                              && \
    chown -R mosquitto:mosquitto /etc/mosquitto "${DATADIR}" "${CONFIGDIR}"

VOLUME "${CONFIGDIR}" "${DATADIR}"
EXPOSE "${DEFAULTPORT}" "${TLSPORT}"

ENTRYPOINT ["/run.sh"]
# Define default command
CMD ["mosquitto"]
