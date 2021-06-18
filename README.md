# allbomm_infra
allbomm Infra repository

## Способ  подключения  к someinternalhost  в  одну команду (через jump host):
```sh
ssh -J appuser@178.154.254.143:22 appuser@10.128.0.35:22
```

## Для подключения к someinternalhost командой
```sh
ssh someinternalhost
```
### 1. В /etc/hosts добавляем
```sh
10.128.0.35 someinternalhost
```
### 2. В ~/.ssh/config добавляем
```sh
Host 10.128.0.*
    ProxyJump 178.154.254.143
```

bastion_IP=178.154.254.143
someinternalhost_IP=10.128.0.35

# _SSL подключен_
# pritunl_url = https://otusvpn.allbomm.ru/
