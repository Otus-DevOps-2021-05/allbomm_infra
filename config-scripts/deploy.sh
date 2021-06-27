#!/bin/bash
apt-get --assume-yes update
apt-get --assume-yes install git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
ps aux | grep puma
puma -d
