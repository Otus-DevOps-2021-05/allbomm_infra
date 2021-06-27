# allbomm_infra
allbomm Infra repository

## ДЗ №3 к уроку №5
### Способ  подключения  к someinternalhost  в  одну команду (через jump host):
```sh
ssh -J appuser@178.154.254.143:22 appuser@10.128.0.35:22
```

### Для подключения к someinternalhost командой
```sh
ssh someinternalhost
```
#### 1. В /etc/hosts добавляем
```sh
10.128.0.35 someinternalhost
```
#### 2. В ~/.ssh/config добавляем
```sh
Host 10.128.0.*
    ProxyJump 178.154.254.143
```

bastion_IP=178.154.254.143
someinternalhost_IP=10.128.0.35

#### _SSL подключен_
#### pritunl_url = https://otusvpn.allbomm.ru/


## ДЗ №4 к уроку №6
testapp_IP=84.201.174.126
testapp_port=9292

## ДЗ №5 к уроку №7 (Подготовка образов с помощью Packer)
<details>
<summary>Алгоритм выполнения</summary>

#### 1. В GitHub создана ветка packer-base
#### 2. Установлен Packer
#### 3. Создан "сервсиный аккаунт" в Yandex Cloud для Packer с ролью "editor"
#### 4. Создан "IAM key" для сервисного аккаунта
#### 5.1. Подготовлен образ для Packer [ubuntu16.json](packer/ubuntu16.json)

```json
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `key`}}",
            "folder_id": "{{user `folder_id`}}",
            "zone": "ru-central1-a",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "{{user `image`}}",
            "ssh_username": "ubuntu",
            "platform_id":  "standard-v2",
            "use_ipv4_nat": "true"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_puma.sh"
        }
    ]
}
```
#### 5.2. Подготовлен файл описания переменных [variables.json.example](packer/variables.json.example)
```json
{
	"key": "example.key.json",
	"folder_id": "1234567890cc40vndnc3",
	"image": "ubuntu-1604-lts"
}
```

#### 5.3. Подготовлен example-файл ключа (важно для прохождения тестов) [example.key.json](packer/example.key.json)
```json
{
   "id": "01234567890123456789",
   "service_account_id": "0123456789abcdefghij",
   "created_at": "2021-06-27T11:21:31.490950066Z",
   "key_algorithm": "RSA_2048",
   "public_key": "-----BEGIN PUBLIC KEY-----\nA..................Z\n-----END PUBLIC KEY-----\n",
   "private_key": "-----BEGIN PRIVATE KEY-----\nA................Z==\n-----END PRIVATE KEY-----\n"
}
```

#### 5.4. Подготовлены скрипты установки компонентов внутри системы
[install_ruby.sh](packer/scripts/install_ruby.sh)
```sh
#!/bin/bash
# sleep используется для обхода ошибки Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
sleep 30s
apt update -y
sleep 5s
apt install -y ruby-full ruby-bundler build-essential
```

[install_mongodb.sh](packer/scripts/install_mongodb.sh)
```sh
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
```

[install_puma.sh](packer/scripts/install_puma.sh)
```sh
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
```

#### 6. Проверен файл конфигурации и запущена ВМ
```cmd
packer validate -var-file=./variables.json ./ubuntu16.json
packer build -var-file=./variables.json ./ubuntu16.json
```

После выполнения команд сервис будет запущен через 2-4 минуты и будет поступен по ссылке:

http://GLOBAL-VM-IP:9292/


![Image 5-7-1](images/hw5-l7-1.png)

![Image 5-7-2](images/hw5-l7-2.png)

</details>
