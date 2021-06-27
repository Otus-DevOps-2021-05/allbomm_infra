#!/bin/bash
yc compute instance create
--name auto-reddit-app
--hostname auto-reddit-app
--memory=512m
--cores=2
--core-fraction=5
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4
--metadata serial-port-enable=1
--metadata-from-file user-data=YC\metadata-homework-4.yaml
