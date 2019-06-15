#################################################################
# Dockerfile to build Zimbra Collaboration 8.8.12 container images
# Based on Ubuntu 16.04
# Created by Makara HIN
#################################################################

FROM ubuntu:16.04

MAINTAINER Makara HIN <hinmakara@gmail.com>

FROM ubuntu:16.04

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  wget \
  dialog \
  openssh-server \
  openssh-client \
  software-properties-common \
  dnsmasq \
  dnsutils \
  net-tools \
  sudo \
  rsyslog \
  unzip \
  nano \
  iputils-ping

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

COPY etc /etc/

RUN mkdir /tmp/zimbra-install

COPY start.sh /

COPY run.sh /

CMD ["/bin/bash", "/start.sh", "-d"]
