#!/bin/bash
#
# Add new line to /etc/hosts if the hostname not found
#

HOSTNAME=$1
IP=$2

if [ "$HOSTNAME" == "" ] || [ "$IP" == "" ]; then
  echo "##############################################"
  echo "ERROR: You must give two parameters, hostname and ip!"
  echo "INFO:  Example: add_host.sh my_hostname 10.0.0.1"
  echo "##############################################"

  exit 1;
fi

FOUND=`grep $HOSTNAME /etc/hosts | wc -l`

if [ "$FOUND" == "0" ]; then
  echo "INFO: Adding $IP = $HOSTNAME to /etc/hosts"
  sudo echo "$IP $HOSTNAME" >> /etc/hosts
else
  echo "INFO: $HOSTNAME found from /etc/hosts will, skip it!"
fi
