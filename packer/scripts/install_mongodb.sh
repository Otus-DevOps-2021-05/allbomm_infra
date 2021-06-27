#!/bin/bash
# sleep используется для обхода ошибки Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
sleep 5s
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
sleep 15s
apt update -y
sleep 5s
apt install -y mongodb-org
sleep 10s
systemctl start mongod
sleep 1s
systemctl enable mongod
