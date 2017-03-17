#!/usr/bin/env bash

cd /etc/systemd/system

# logstash_register.sh logstash_test1.service
SERVICE=$1

sudo vi $SERVICE.service
sudo systemctl disable $SERVICE
sudo systemctl enable $SERVICE
sudo systemctl stop $SERVICE
sudo systemctl start $SERVICE

# journalctl -f
# sudo systemctl status $SERVICE
# systemctl | grep tomcat

exit 0
