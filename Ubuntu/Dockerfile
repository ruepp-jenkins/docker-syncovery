FROM ubuntu:20.04
ARG SYNCOVERY_VERSION
ARG SYNCOVERY_DOWNLOADURL
LABEL maintainer="Stefan Ruepp <stefan@ruepp.info>"
LABEL github="https://github.com/MyUncleSam/docker-syncovery/"

ENV SYNCOVERY_HOME=/config
ENV SETUP_TEMP=/tmp/syncovery.tar.gz
ENV TZ=Europe/Berlin

# prepare folder(s)
RUN mkdir -p /syncovery

# copy files
ADD ./docker-entrypoint.sh /docker/entrypoint.sh

# install packages
# change time
# download and install syncovery
RUN apt-get update \
    && apt-get install -y bash wget openssl libcrypto++6 libssl-dev sqlite3 libsqlite3-0 libsmbclient tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata\
    && wget -O "$SETUP_TEMP" "${SYNCOVERY_DOWNLOADURL}" \
    && tar -xvf "$SETUP_TEMP" --directory /syncovery \
    && rm -f "$SETUP_TEMP" \
    && chmod +x /syncovery/SyncoveryCL \
    && chmod +x /docker/entrypoint.sh
    
EXPOSE 8999
VOLUME [ "/tmp", "/config" ]

ENTRYPOINT [ "/docker/entrypoint.sh" ]
