#!/bin/bash
# This script establishes SSH tunnel to the SSH-server in internet
# it's useful approach to traverse NAT and firewalls
# Don't forget to invoke this script from init scripts -
# the simplest way is to put it in /etc/rc.local
screen -S TUNNEL -d -m bash -c 'while echo ; do autossh -o TCPKeepAlive=yes -o ConnectTimeout=5 -v -p 21 -R 2222:127.0.0.1:22 tunnel@itsol.pro "while true; do echo -n .; sleep 1; done"; done'
