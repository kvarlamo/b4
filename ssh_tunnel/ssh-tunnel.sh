#!/bin/bash
# This script establishes SSH tunnel to the SSH-server in internet
# it's useful approach to traverse NAT and firewalls
# Don't forget to invoke this script from init scripts -
# the simplest way is to put it in /etc/rc.local
screen -S TUN-it -d -m bash -c 'while echo ; do autossh -o TCPKeepAlive=yes -o ConnectTimeout=5 -v -p 21 -R 2222:127.0.0.1:22 tunnel@108.61.198.126 "while true; do echo -n .; sleep 6; done"; done'
screen -S TUN-tk -d -m bash -c 'while echo ; do autossh -o TCPKeepAlive=yes -o ConnectTimeout=5 -v -p 21 -R 2222:127.0.0.1:22 tunnel@62.76.191.179 "while true; do echo -n .; sleep 5; done"; done'
