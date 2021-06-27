#!/bin/bash
# sleep используется для обхода ошибки Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
sleep 15s
sudo apt update -y
sleep 5s
sudo apt install -y git
sleep 5s
sudo apt install -y gem
sleep 5s
sudo gem install bundler
sleep 5s
cd /opt
sudo git clone -b monolith https://github.com/express42/reddit.git
sleep 5s
cd reddit
sudo bundle install
sleep 30s
sudo puma -d
sleep 5s
sudo tee /etc/systemd/system/puma.service<<EOF
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple

WorkingDirectory=/opt/reddit
ExecStart=/usr/local/bin/puma

Restart=always

[Install]
WantedBy=multi-user.target
EOF
sleep 1s
sudo systemctl daemon-reload
sleep 1s
sudo systemctl enable puma
sleep 1s
sudo systemctl restart puma
sleep 300s
