#!/bin/bash
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
apt-get install -y apt-transport-https ca-certificates
apt-get --assume-yes update
apt-get --assume-yes install mongodb-org
systemctl start mongod
systemctl enable mongod
