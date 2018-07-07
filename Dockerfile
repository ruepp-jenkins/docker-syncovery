FROM debian:stable

CMD './install.sh'

EXPOSE 8999

ENTRYPOINT [ "/syncovery/SyncoveryCL SET /WEBSERVER=0.0.0.0" ]