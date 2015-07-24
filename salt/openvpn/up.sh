#!/bin/bash

/sbin/iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
