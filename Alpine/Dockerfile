# NOT SUPPORTED!

FROM alpine:latest
#FROM frolvlad/alpine-glibc
ARG SYNCOVERY_VERSION
ARG SYNCOVERY_DOWNLOADURL
LABEL maintainer="Stefan Ruepp <stefan@ruepp.info>"
LABEL github="https://github.com/MyUncleSam/docker-syncovery/"

ENV SYNCOVERY_HOME=/config
ENV SETUP_TEMP=/tmp/syncovery.tar.gz

RUN mkdir -p /docker /syncovery /tmp /config
ADD ./docker-entrypoint.sh /docker/entrypoint.sh

# update
# install packages
# download and install glibc
# download and install syncovery
RUN apk update \
    && apk add bash wget openssl libressl-dev zlib zlib-dev sqlite sqlite-libs libcrypto1.1 libsmbclient \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q -O /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk \
    && wget -q -O /tmp/glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-bin-2.32-r0.apk \
    && wget -q -O /tmp/glibc-dev.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-dev-2.32-r0.apk \
    && wget -q -O /tmp/glibc-i18n.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-i18n-2.32-r0.apk \
    && apk add /tmp/glibc.apk /tmp/glibc-bin.apk /tmp/glibc-dev.apk /tmp/glibc-i18n.apk \
    && rm -R /tmp/* \
    && LD_LIBRARY_PATH=/lib:/usr/local/lib:/usr/bin \
    && export LD_LIBRARY_PATH \
    && wget -O "$SETUP_TEMP" "${SYNCOVERY_DOWNLOADURL}" \
    && tar -xvf "$SETUP_TEMP" --directory /syncovery \
    && rm -f "$SETUP_TEMP" \
    && chmod +x /syncovery/SyncoveryCL \
    && chmod +x /docker/entrypoint.sh

EXPOSE 8999
VOLUME [ "/tmp", "/config" ]

ENTRYPOINT [ "/docker/entrypoint.sh" ]