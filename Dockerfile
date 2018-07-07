FROM centos:7

ENV SYNCOVERY_HOME=/config
ENV SETUP_TEMP=/tmp/syncovery.tar.gz

ADD ./docker-entrypoint.sh /docker/entrypoint.sh

RUN yum update && yum -y install wget
RUN mkdir /syncovery && \
    wget -O "$SETUP_TEMP" 'https://www.syncovery.com/release/SyncoveryCL-x86_64-7.98c-Web.tar.gz' && \
    tar -xvf "$SETUP_TEMP" --directory /syncovery && \
    rm -f "$SETUP_TEMP" && \
    chmod +x /syncovery/SyncoveryCL && \
    chmod +x /docker/entrypoint.sh
    
EXPOSE 8999

ENTRYPOINT [ "/docker/entrypoint.sh" ]