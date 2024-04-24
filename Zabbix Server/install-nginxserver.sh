#!/bin/bash

### PROJECT INFO
echo "# project         : 4RSEC Free Software Solutions"
echo "# title           : Instalação nginx server"
echo "# description     : Instalação e configuração do nginx web-server."
echo "# date            : 01/02/24"
echo "# version         : 6.4"
echo "# usage           : bash install-nginxserver.sh"
echo "# contato         : Ranlens Denck <ranlens.denck@protonmail.com>"
echo "# ATTENTION - EXECUTE TODO O BASH COMO ROOT"
### END PROJECT INFO
sleep 2.0
# Levaremos em consideração que a máquina já está configurada.
# Itens que devem estar configurados:
# Data Local do OS, Data local de hardware & Update OS

# Desabilitar SELinux
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# Atualização do OS e instalação dos utilitários dnf
sudo dnf check-update
sudo dnf -y install dnf-utils

# Adcionar o repositório do Nginx no Sistema Operacional Rocky Linux
sudo tee /etc/yum.repos.d/nginx-stable.repo<<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/9/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

# Atualização de todos os pacotes
sudo dnf update
# Instalação do Nginx Web Server
sudo dnf -y install nginx

# Habilitar inicialização automatica do serviço nginx
sudo systemctl enable --now nginx
sudo systemctl start nginx
# Versão do web server
nginx -v
# Configuração da Firewall para HTTP e HTTPS
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
# Lista de regras do Firewall
sudo firewall-cmd --permanent --list-all
