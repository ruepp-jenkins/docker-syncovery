FROM debian:stable

CMD './install.sh'

ENTRYPOINT [ "/syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0" ]