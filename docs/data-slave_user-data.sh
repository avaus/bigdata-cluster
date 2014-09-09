#!/bin/bash
#
# This is example of user data what you need
# to setup when you're starting up
# slave node.
#
# Basically what it does is that it will
# configure data-master ip address and
# restart required services.
#
# NOTE:
# replace x.x.x.x with your current
# data-master private ip address
#


echo "X.X.X.X data-master" >> /etc/hosts
sudo service datanode restart
sudo service nodemanager restart
