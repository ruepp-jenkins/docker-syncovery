FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG SYNCOVERY_AMD64_DOWNLOADLINK
ARG SYNCOVERY_ARM64_DOWNLOADLINK

LABEL maintainer="Stefan Ruepp"
LABEL github="https://github.com/ruepp-jenkins/docker-refacto"
LABEL TARGETPLATFORM=${TARGETPLATFORM}
LABEL BUILDPLATFORM=${BUILDPLATFORM}

ENV SYNCOVERY_HOME=/config
ENV TZ=Europe/Berlin

ADD scripts/dockerfile/ /build

RUN /bin/bash /build/build.sh

EXPOSE 8999 8889

VOLUME [ "/tmp", "/config" ]
CMD [ "/docker/start.sh" ]