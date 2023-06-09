# Mosquitto Docker
# docker build . -t mosquitto
# docker run --name mosquitto -v $(pwd)/datadir:/mqtt  mosquitto

ARG BASE=alpine:3.18
FROM $BASE

ARG VERSION=1
ARG APPVERSION=2.0
ARG TIME=1970-00-00T00:00:00.00Z
ARG HASH=undefined
ARG REPOSITORY="https://github.com/jriguera/docker-mosquitto"

ARG DATADIR=/mqtt
ARG CONFIGDIR=/config
ARG ETCDIR=/etc/mosquitto
ARG RUNDIR=/run/mosquitto
ARG PORT=1883
ARG UID=1000
ARG GUID=1000
ARG TZ=UTC
ARG USER=mosquitto
ARG GROUP=mosquitto

LABEL org.opencontainers.image.title="docker-mosquitto"
LABEL org.opencontainers.image.created="${TIME}}"
LABEL org.opencontainers.image.base.name="${BASE}"
LABEL org.opencontainers.image.description="Eclipse Mosquitto packed in a multi-arch container image based on alpine: https://mosquitto.org/"
LABEL org.opencontainers.image.authors="Jose Riguera <jriguera@gmail.com>"
LABEL org.opencontainers.image.url="${REPOSITORY}#readme"
LABEL org.opencontainers.image.documentation="${REPOSITORY}#readme"
LABEL org.opencontainers.image.source="${REPOSITORY}"
LABEL org.opencontainers.image.version="${VERSION}-${APPVERSION}}"
LABEL org.opencontainers.image.revision="${HASH}"
LABEL org.opencontainers.image.vendor="jriguera"
LABEL org.opencontainers.image.licenses="GPL-3"
LABEL es.riguera.jose.container.service=mosquitto
LABEL es.riguera.jose.container.port="${PORT}"
LABEL es.riguera.jose.container.version="${VERSION}-${APPVERSION}"
LABEL es.riguera.jose.container.appversion="${APPVERSION}"
LABEL es.riguera.jose.container.repository="${REPOSITORY}"
LABEL es.riguera.jose.container.hash="${HASH}"

ENV C_DATADIR="${DATADIR}"
ENV C_CONFIGDIR="${CONFIGDIR}"
ENV C_ETCDIR="${ETCDIR}"
ENV C_RUNDIR="${RUNDIR}"
ENV C_USERNAME="${USER}"
ENV C_GROUPNAME="${GROUP}"
ENV PORT="${PORT}"
ENV LANG=en_US.utf8
ENV LC_ALL=C.UTF-8

RUN set -xe                                                                         && \
    apk -U upgrade                                                                  && \
    # User/group
    addgroup -g "${GUID}" -S "${USER}"                                              && \
    adduser -h "${DATADIR}" -D -G "${GROUP}" -s /sbin/nologin -u "${UID}" "${USER}" && \
    # Installing Alpine packages
    apk add --no-cache \
        mosquitto~${APPVERSION} \
        mosquitto-libs~${APPVERSION} \
        mosquitto-clients~${APPVERSION} \
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
    cp "/usr/share/zoneinfo/${TZ}" /etc/localtime                                   && \
    echo "${TZ}" > /etc/timezone                                                    && \
    # clean up
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* "${ETCDIR}"/*

COPY *.sh /usr/local/bin/
COPY etc "${ETCDIR}"

RUN set -xe                                                                         && \
    chmod a+x /usr/local/bin/*                                                      && \
    ln -s /usr/local/bin/mosquitto.sh /usr/local/bin/docker-entrypoint.sh           && \
    ln -s /usr/local/bin/mosquitto.sh /docker-entrypoint.sh                         && \
    ln -s /usr/local/bin/mosquitto.sh /run.sh                                       && \
    ln -s /usr/local/bin/healthcheck.sh /healthcheck.sh                             && \
    mkdir -p /docker-entrypoint-initdb.d                                            && \
    mkdir -p "${DATADIR}" "${CONFIGDIR}" "${RUNDIR}"                                && \
    chown -R ${USER}:${GROUP} "${ETCDIR}" "${DATADIR}" "${CONFIGDIR}" "${RUNDIR}"

VOLUME "${CONFIGDIR}" "${DATADIR}"
EXPOSE "${PORT}"
HEALTHCHECK --interval=30s --retries=2 --timeout=5s --start-period=30s CMD /healthcheck.sh

ENTRYPOINT ["/run.sh"]

# Define default command
CMD ["mosquitto", "-c", "/etc/mosquitto/mosquitto.conf"]
