# allbomm_infra
allbomm Infra repository

# Способ  подключения  к someinternalhost  в  одну команду:

ssh -J appuser@178.154.254.143:22 appuser@10.128.0.35:22

# В данном случае используется jump host.

# Для подключения к someinternalhost командой

ssh someinternalhost

# 1. В /etc/hosts добавляем

10.128.0.35 someinternalhost

# 2. В ~/.ssh/config добавляем

Host 10.128.0.*
    ProxyJump 178.154.254.143

bastion_IP=178.154.254.143

someinternalhost_IP=10.128.0.35

# pritunl_url=https://otusvpn.allbomm.ru/
