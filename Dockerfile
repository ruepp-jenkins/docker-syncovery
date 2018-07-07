FROM debian:stable

CMD './install.sh'

EXPOSE 8999

ENV SYNCOVERY_HOME=/config

ENTRYPOINT [ "./syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0" ]