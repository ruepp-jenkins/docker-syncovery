FROM ubuntu:20.04

ARG SYNCOVERY_DOWNLOADLINK
ARG GUARD_DOWNLOADLINK
ARG REMOTE_DOWNLOADLINK

LABEL maintainer="Stefan Ruepp <stefan@ruepp.info>"
LABEL github="https://github.com/MyUncleSam/docker-syncovery/"

ENV SYNCOVERY_HOME=/config
ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
ENV SETUP_TEMP=/tmp/installers/

# download installer files for debian
RUN mkdir -p /docker/tmp \
    && mkdir -p /config \
    && mkdir -p /tmp \
    && mkdir -p /syncovery \
    && mkdir -p $SETUP_TEMP \
    && apt-get update \
    && apt-get install --no-install-recommends -y bash wget openssl ca-certificates libcrypto++6 libssl-dev sqlite3 libsqlite3-0 libsmbclient tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get autoclean -y && apt-get clean -y && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp \
    && wget -O "${SETUP_TEMP}/syncovery.tar.gz" "${SYNCOVERY_DOWNLOADLINK}" \
    && tar -xvf "${SETUP_TEMP}/syncovery.tar.gz" --directory /syncovery \
    && chmod +x /syncovery/SyncoveryCL \
    && wget -O "${SETUP_TEMP}/remote.tar.gz" "${REMOTE_DOWNLOADLINK}" \
    && tar -xvf "${SETUP_TEMP}/remote.tar.gz" --directory /syncovery \
    && chmod +x /syncovery/SyncoveryRS \
    && wget -O "${SETUP_TEMP}/guard.tar.gz" "${GUARD_DOWNLOADLINK}" \
    && tar -xvf "${SETUP_TEMP}/guard.tar.gz" --directory /syncovery \
    && chmod +x /syncovery/SyncoveryGuardian \
    && cd / \
    && rm -rf /tmp/*

ADD ./start.sh /docker/start.sh

RUN chmod +x /docker/start.sh

EXPOSE 8999
EXPOSE 8900
EXPOSE 8949

VOLUME [ "/tmp", "/config" ]

ENTRYPOINT [ "/docker/start.sh" ]