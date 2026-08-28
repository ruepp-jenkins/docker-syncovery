FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG SYNCOVERY_AMD64_DOWNLOADLINK
ARG SYNCOVERY_ARM64_DOWNLOADLINK

LABEL maintainer="Stefan Ruepp"
LABEL github="https://github.com/ruepp-jenkins/docker-syncovery"
LABEL TARGETPLATFORM=${TARGETPLATFORM}
LABEL BUILDPLATFORM=${BUILDPLATFORM}

ENV SYNCOVERY_HOME=/config
ENV TZ=Europe/Berlin

COPY scripts/dockerfile/ /build

RUN /bin/bash /build/build.sh

EXPOSE 8999 8889

VOLUME [ "/tmp", "/config", "/machine-id" ]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -fsS "http://127.0.0.1:${SYNCOVERY_SET_WEBPORT:-8999}/" > /dev/null || exit 1

CMD [ "/docker/start.sh" ]
