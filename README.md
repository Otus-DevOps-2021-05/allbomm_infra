# allbomm_infra
allbomm Infra repository

# ДЗ к уроку №3
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

### _SSL подключен_
### pritunl_url = https://otusvpn.allbomm.ru/


# ДЗ к уроку №4
testapp_IP=84.201.174.126
testapp_port=9292
