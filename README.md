# allbomm_infra
allbomm Infra repository

## ДЗ №3 к уроку №5 (Знакомство с облачной инфраструктурой и облачными сервисами)

<details>
<summary>Информация для проверки</summary>

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

</details>

## ДЗ №4 к уроку №6 (Основные сервисы Yandex Cloud)

<details>
<summary>Информация для проверки</summary>

testapp_IP=84.201.174.126
testapp_port=9292

</details>

## ДЗ №5 к уроку №7 (Модели управления инфраструктурой. Подготовка образов с помощью Packer)

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

## ДЗ №6 к уроку №8 (Знакомство с Terraform)
<details>
<summary>Алгоритм выполнения</summary>

OS Windows 10 x64

Скачали terraform: https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_windows_amd64.zip
Переместили файл terraform.exe в C:\Windows\System32 для удобства использования

Проверяем версии:
```cmd
yc version
```

```
Yandex.Cloud CLI 0.77.0 windows/amd64
```

При необходимости выполняем:
```
yc components update
```

```cmd
terraform -v
```

```
Terraform v1.0.2
on windows_amd64
```

Создаём ветку terraform-1 из main
Выполняем команду для получения информации:
```
yc config list
```
Создаём файл .\allbomm_infra\terraform\main.tf с содержимым

```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "<OAuth>"
  cloud_id  = "<идентификатор облака>"
  folder_id = "<идентификатор каталога>"
  zone      = "ru-central1-a"
}
```

Инициализируем terraform командой:
```cmd
cd .\allbomm_infra\terraform
terraform init
```

Проверяем что после инициализации установился провайдер yandex-cloud
```cmd
terraform -v
```

```
Terraform v1.0.2
on windows_amd64
+ provider registry.terraform.io/yandex-cloud/yandex v0.61.0
```

Создаём сервисный аккаунт terraform-user в yandex cloud с ролью editor
```
# Узнаём FOLDER_ID
yc config list
# Создаём сервисный аккаунт terraform-user
yc iam service-account create --name terraform-user --folder-id $FOLDER_ID
# Получаем ID аккаунта terraform-user
yc iam service-account get terraform-user
# Добавляем роль editor аккаунту terraform-user
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCOUNT_ID
# Выгружаем key.json для аккаунта terraform-user
yc iam key create --service-account-id $ACCOUNT_ID --output C:/Users/MLW/.ssh/key-terraform-user.json
```

Редактируем файл main.tf (процесс был многоитерационный, но опишу одним пунктом)
Примечание: секция terraform закомментирована, с ней не проходите тесты, а без неё на Windows не работало.
```
#terraform {
#  required_providers {
#    yandex = {
#      source = "yandex-cloud/yandex"
#    }
#  }
#}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_compute_instance" "app" {
  name  = "reddit-app"

  resources {
    cores  = 2
    core_fraction = 100
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
```

Создаём файл вывода информации о виртуальной машине outputs.tf
```
output "external_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
```

Создаём файлы puma.service и deploy.sh, дла разворачивания сервисов внутри ВМ
files/puma.service
```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
files/deploy.sh
```
#!/bin/bash
sleep 15s
set -e
APP_DIR=${1:-$HOME}
sudo apt-get install -y git
sleep 5s
git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install
sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
```

Создаём файл variables.tf, содержащий описание входных переменных в main.tf
```
variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "public_key_path" {
  # Описание переменной
  description = "PUBLIC ssh key"
}
variable "image_id" {
  description = "Disk image"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "private_key_path" {
  description = "PRIVATE ssh key"
}
```

Создаём файлы terraform.tfvars и terraform.tfvars.example, содержащие значения переменных, объявленных в файле variables.tf
```
cloud_id = "0123456789abc"
folder_id = "0123456789abc"
zone = "ru-central1-a"
image_id = "0123456789abc"
public_key_path = "~/.ssh/ubuntu.pub"
subnet_id = "0123456789abc0"
service_account_key_file = "terraformkey.json"
private_key_path = "~/.ssh/ubuntu"
```

Выполняем команды:
```
terraform plan
terraform apply
```

И получаем вывод:
```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
Outputs:
external_ip_address_app = ***.***.***.***
```

Сервис доступен по адресу http://IP:9292

После проверки работы сервиса выполняем команду:
```
terraform destroy
```

Перед коммитом в .gitignore добавляем:
```
.terraform/
*.tfstate
*.tfvars
.terraform.lock.hcl
```

</details>

## ДЗ №7 к уроку №9 (Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform)
<details>
<summary>Алгоритм выполнения</summary>

Создаём ветку terraform-2 из main

Добавили в `main.tf` информацию об IP:

```
resource "yandex_vpc_network" "app-network" {
  name = "reddit-app-network"
}

resource "yandex_vpc_subnet" "app-subnet" {
  name           = "reddit-app-subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.app-network.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

```

Подготовили файлы для инстансов `app` и `db` в папке `terraform\modules\*`

Подготовили `storage-bucket.tf` файл

Подготовили 2 директории `terraform/stage` и `terraform/prod` для условного разделения окружения.

После проверки работы выполняем команду:

``` cmd
cd terraform/prod
# или cd terraform/stage
terraform init
terraform plan
terraform apply
```

Предварительно должен быть создан файл terraform.tfvars, по аналогии с terraform.tfvars.example

</details>

## ДЗ №8 к уроку №10 (Управление конфигурацией. Знакомство с Ansible)
<details>
<summary>Алгоритм выполнения</summary>

Создаём ветку ansible-1 из terraform-2

Добавили папку `.\ansible`

Добавили файл:

`.\ansible\requirements.txt`

```
ansible>=2.4
```

Произвели установку ansible по инструкции -- https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

Создали Inventory файл `.\ansible\inventory` на основе информации об инстансах, предварительно запущенных через terraform

```
[app]
appserver ansible_host=178.19.131.97

[db]
dbserver ansible_host=178.19.131.124
```

Создали файл `.\ansible\ansible.cfg`

```
[defaults]
inventory = ./inventory
remote_user = ubuntu
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
```

Cоздали файл `.\ansible\inventory.yml` по аналогии с inventory, но в формате yml (Альтернативный формат inventory файла)
```
app:
  hosts:
    appserver:
      ansible_host: 178.19.131.97

db:
  hosts:
    dbserver:
      ansible_host: 178.19.130.124

```

Создали файл плейбука `.\ansible\clone.yml`
```
---
- name: Clone
  hosts: app
  become: true
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/appuser/reddit
```
Проверка и запуск выполнялись практически после каждого изменения.

Для проверки необходимо выполнить:
```
cd ./allbomm_infra/ansible
ansible-playbook clone.yml -i inventory.yml
ansible all -m ping -i inventory.yml
```

</details>

## ДЗ №9 к уроку №11 (Продолжение знакомства с Ansible: templates, handlers, dynamic inventory, vault, tags)
<details>
<summary>Алгоритм выполнения</summary>

Создаём ветку ansible-2 из ansible-1

Создали файлы плейбуков `reddit_app.yml (reddit_app_one_play.yml)` и `reddit_app2.yml (reddit_app_multiple_plays.yml)`.

`reddit_app_one_play.yml`
```
---
- name: Configure hosts & deploy application
  hosts: all
  vars:
    mongo_bind_ip: 0.0.0.0
    db_host: 178.19.131.124
  tasks:
    - name: Change mongo config file
      become: true
      template:
        src: templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
      tags: db-tag
      notify: restart mongod

    - name: Add unit file for Puma
      become: true
      copy:
        src: files/puma.service
        dest: /etc/systemd/system/puma.service
      tags: app-tag
      notify: reload puma

    - name: enable puma
      become: true
      systemd: name=puma enabled=yes
      tags: app-tag

    - name: Add config for DB connection
      template:
        src: templates/db_config.j2
        dest: /home/ubuntu/db_config
      tags: app-tag

    - name: install git
      become: yes
      apt: name=git state=present
      tags: deploy-tag

    - name: Fetch the latest version of application code
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/ubuntu/reddit
        version: monolith
      tags: deploy-tag
      notify: reload puma

    - name: Bundle install
      bundler:
        state: present
        chdir: /home/ubuntu/reddit
      tags: deploy-tag


  handlers:
    - name: restart mongod
      become: true
      service:
        name: mongod
        state: restarted

    - name: reload puma
      become: true
      systemd:
        name: puma
        state: restarted
```

`reddit_app_multiple_plays.yml`
```
---
- name: Configure MongoDB
  hosts: db
  tags: db-tag
  become: true
  vars:
    mongo_bind_ip: 0.0.0.0
  tasks:
    - name: Change mongo config file
      template:
        src: templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
      notify: restart mongod

  handlers:
  - name: restart mongod
    service: name=mongod state=restarted

- name: Configure App
  hosts: app
  tags: app-tag
  become: true
  vars:
   db_host: 178.19.131.124
  tasks:
    - name: Add unit file for Puma
      copy:
        src: files/puma.service
        dest: /etc/systemd/system/puma.service
      notify: reload puma

    - name: Add config for DB connection
      template:
        src: templates/db_config.j2
        dest: /home/ubuntu/db_config
        owner: ubuntu
        group: ubuntu

    - name: enable puma
      systemd: name=puma enabled=yes

  handlers:
  - name: reload puma
    systemd:
      name: puma
      state: restarted

- name: Deploy App
  hosts: app
  tags: deploy-tag
  tasks:
    - name: install git
      become: yes
      apt: name=git state=present

    - name: Fetch the latest version of application code
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/ubuntu/reddit
        version: monolith
      notify: restart puma

    - name: Bundle install
      bundler:
        state: present
        chdir: /home/ubuntu/reddit

  handlers:
    - name: restart puma
      become: true
      systemd:
        name: puma
        state: restarted
```

Создали файлы плейбуков `site.yml`, `app.yml`, `db.yml`, `deploy.yml` на основе `reddit_app_*.yml`

`site.yml`
```
---
- import_playbook: db.yml
- import_playbook: app.yml
- import_playbook: deploy.yml
```

`app.yml`
```
---
- name: Configure App
  hosts: app
  become: true
  vars:
   db_host: "10.10.185.94"
  tasks:
    - name: Add unit file for Puma
      copy:
        src: files/puma.service
        dest: /etc/systemd/system/puma.service
      notify: reload puma

    - name: Add config for DB connection
      template:
        src: templates/db_config.j2
        dest: /home/ubuntu/db_config
        owner: ubuntu
        group: ubuntu

    - name: enable puma
      systemd:
        name: puma
        enabled: true

  handlers:
  - name: reload puma
    systemd:
      name: puma
      state: restarted
```

`db.yml`
```
---
- name: Configure MongoDB
  hosts: db
  become: true
  vars:
    mongo_bind_ip: 0.0.0.0
  tasks:
    - name: Change mongo config file
      template:
        src: templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
      notify: restart mongod

  handlers:
  - name: restart mongod
    service:
      name: mongod
      state: restarted
```

`deploy.yml`
```
---
- name: Deploy App
  hosts: app
  tasks:
    - name: install git
      become: true
      apt:
        name: git
        state: present

    - name: Fetch the latest version of application code
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/ubuntu/reddit
        version: monolith
      notify: restart puma

    - name: Bundle install
      bundler:
        state: present
        chdir: /home/ubuntu/reddit

  handlers:
    - name: restart puma
      become: true
      systemd:
        name: puma
        state: restarted
```

Создали плейбуки для packer `packer_app.yml` и `packer_db.yml`

`packer_app.yml`
```
---
- name: Ruby
  hosts: all
  become: true

  tasks:
    - name: Install Ruby
      apt:
        name: "{{ item }}"
        state: present
        update_cache: true
      loop:
        - ruby-full
        - ruby-bundler
        - build-essential
```

`packer_db.yml`
```
---
- name: Install MongoDB 4.2
  hosts: all
  become: true

  tasks:
  # Add mongo-db repo
  - name: Add key
    apt_key:
      url: https://www.mongodb.org/static/pgp/server-4.2.asc
      state: present

  - name: Add repo
    apt_repository:
      repo: deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse
      state: present


  - name: Install mongodb
    apt:
      name: mongodb-org
      state: present
      update_cache: true

  - name: Enable mongod
    systemd:
      name: mongod
      enabled: true
```

Изменили секции provisioners в файлах пакера `packer/app.json` и `packer/db.json`.

`packer/app.json`
```
{
    "builders": [
        {
          "type": "yandex",
          "service_account_key_file": "{{user `key_path`}}",
          "folder_id": "{{user `folder_id`}}",
          "source_image_family": "{{user `source_image_type`}}",
          "image_name": "reddit-base-{{timestamp}}",
          "image_family": "reddit-base",
          "subnet_id": "{{user `subnet_id`}}",
          "use_ipv4_nat": true,
          "ssh_username": "{{user `username`}}",
          "platform_id": "standard-v1",
          "serial_log_file": "console.log"
        }
    ],
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/packer_app.yml"
        }
    ]
}
```

`packer/db.json`
```
{
    "builders": [
        {
          "type": "yandex",
          "service_account_key_file": "{{user `key_path`}}",
          "folder_id": "{{user `folder_id`}}",
          "source_image_family": "{{user `source_image_type`}}",
          "image_name": "reddit-base-{{timestamp}}",
          "image_family": "reddit-base",
          "subnet_id": "{{user `subnet_id`}}",
          "use_ipv4_nat": true,
          "ssh_username": "{{user `username`}}",
          "platform_id": "standard-v1",
          "serial_log_file": "console.log"
        }
    ],
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/packer_db.yml"
        }
    ]
}
```

Обновили `.gitignore`, исключив файлы `*.retry`
```
# packer
packer/variables.json

# terraform
.terraform/
*.tfstate
*.tfvars
.terraform.lock.hcl
*.tfstate.*.backup
*.tfstate.backup

# ansible
*.retry
```

Попровили файлы `packer/key.json.example` и `packer/variables.json.example` для тестов

## Для проверки необходимо выполнить:
```sh
# ansible
cd allbomm_infra/ansible
ansible-playbook reddit_app_multiple_plays.yml
```
и
```sh
# packer
cd allbomm_infra/packer
packer build -var-file packer/variables.json packer/app.json
packer build -var-file packer/variables.json packer/db.json
```

и перейти по ссылке созданного сервиса
http://APP_SERVER_IP:9292/

</details>
