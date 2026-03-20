
# https://hub.docker.com/_/debian/tags?name=slim
FROM debian:13.4-slim

# https://packages.debian.org/search?keywords=kea-dhcp4-server
# https://packages.debian.org/search?keywords=kea-dhcp6-server
ENV dhcpV4="kea-dhcp4-server=2.6.3-1"
ENV dhcpV6="kea-dhcp6-server=2.6.3-1"

LABEL org.opencontainers.image.authors="kom23 <vagnu00@gmail.com>"
LABEL Description="Dhcp server based on Debian."

ARG DEBIAN_FRONTEND=noninteractive

ENV DHCP4=1
ENV DHCP6=0

RUN set -xe && \
  : "---------- ESSENTIAL packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils \
     rsync \
     procps \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -xe && \
  : "---------- SPECIFIC packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     $dhcpV4 $dhcpV6 \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

ADD rootfs /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["kea-dhcp4", "-c", "/var/lib/kea/kea-dhcp4.conf"]
