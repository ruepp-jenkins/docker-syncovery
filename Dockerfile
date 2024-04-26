FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG SYNCOVERY_AMD64_DOWNLOADLINK
ARG SYNCOVERY_ARM64_DOWNLOADLINK

LABEL maintainer="Stefan Ruepp <stefan@ruepp.info>"
LABEL github="https://github.com/MyUncleSam/docker-syncovery/"
LABEL TARGETPLATFORM=${TARGETPLATFORM}
LABEL BUILDPLATFORM=${BUILDPLATFORM}

ENV SYNCOVERY_HOME=/config
ENV TZ=Europe/Berlin

ADD scripts/dockerfile/ /build

RUN /bin/bash /build/build.sh

EXPOSE 8999

VOLUME [ "/tmp", "/config" ]
CMD [ "/docker/start.sh" ]