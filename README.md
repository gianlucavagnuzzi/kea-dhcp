# Kea-Dhcp
Dhcp server based on Debian.

## Quick reference
* Where to file issues:
[GitHub](https://github.com/gianlucavagnuzzi/kea-dhcp/issues)

* Supported architectures: amd64 , armv7 , arm64v8

## How to use
### After first run it make conf file in `./data` dir. Change it with your parameters and ... relauch it!

### ...by docker run:
```
docker run --rm -d \
--net host \
-v ./data:/var/lib/kea \
-e DHCP4=1 -e DHCP6=0 -e TZ=Europe/Rome \
--name dhcp rardcode/kea-dhcp
```

### ...by docker-compose file:
```
services:
  kea-dhcp:
    image: rardcode/kea-dhcp
    container_name: kea-dhcp
    environment:
      - TZ=Europe/Rome
      #- DHCP4=0 # (decomment for disable DHCPv4 server, default enabled|1)
      #- DHCP6=1 # (enable DHCPv6 server, default disabled|0)
    volumes:
    - ./data:/var/lib/kea
    network_mode: host
    restart: unless-stopped
```
## Changelog
### v134.2361 - 20.03.2026
- Debian v.13.4
- kea-dhcp-server v.2.6.3-1
