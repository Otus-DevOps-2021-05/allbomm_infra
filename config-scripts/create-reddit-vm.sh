#!/bin/bash

yc compute instance create \
	--name reddit-app \
	--hostname reddit-app \
	--memory=4g  \
  --cores=2  \
  --core-fraction=100  \
	--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
	--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
	--metadata serial-port-enable=1 \
	--ssh-key ~/.ssh/appuser.pub
