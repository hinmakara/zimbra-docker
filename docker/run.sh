#!/bin/sh
sleep 5
sudo service ssh start
sudo service dnsmasq start
su - zimbra -c 'zmcontrol start'
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi
if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

