#!/bin/bash
# sleep используется для обхода ошибки Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
sleep 30s
apt update -y
sleep 5s
apt install -y ruby-full ruby-bundler build-essential
