# Original work by hlince 
https://hub.docker.com/r/hlince/syncovery - I created This repository with updated SyncoveryCL versions to be up2date.

# Docker compose

The following sample is running against an unraid host

    version: '2.2' services:   syncovery:
        cpu_shares: 256
        restart: unless-stopped
        image: hlince/syncovery
        volumes:
        - /mnt:/mnt
        - /boot:/boot
        - /mnt/user/appdata/syncovery:/config
        - /mnt/user/tmp/syncovery:/tmp
        ports:
        - 8999:8999

1. Run Command docker-compose up -d
2. Go to http://your-docker-host:8999
3. Use the username default and the password pass

# Github
repository of this container: https://github.com/Howard3/docker-syncovery
hlince original github repository: https://github.com/Howard3/docker-syncovery
