FROM debian:stable

ENV SYNCOVERY_HOME=/config
ENV SETUP_TEMP=/tmp/syncovery.tar.gz

RUN apt install wget && \
    mkdir /syncovery && \
    wget -O "$SETUP_TEMP" 'https://www.syncovery.com/release/SyncoveryCL-x86_64-7.98c-Web.tar.gz' && \
    tar -xvf "$SETUP_TEMP" --directory /syncovery && \
    rm -f "$SETUP_TEMP"

EXPOSE 8999

ENTRYPOINT [ "./syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0" ]