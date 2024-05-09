#!/bin/bash

### PROJECT INFO
echo "# project         : 4RSEC Free Software Solutions"
echo "# title           : Integração do Tiflux com Zabbix"
echo "# description     : Shell script de integração entre o sistema Tiflux e o Zabbix."
echo "# date            : 08/05/24"
echo "# version         : 1.0"
echo "# usage           : bash tiflux_zabbix_rhel.sh"
echo "# contato         : Ranlens Denck <ranlens.denck@protonmail.com>"
echo "# ATTENTION - EXECUTE TODO O BASH COMO ROOT"
echo "# Doc             : https://guia-de-uso.tiflux.com/integracoes/terceiros/zabbix"
### END PROJECT INFO
sleep 2.0


# Install Ansible on Rocky Linux 8 & 9
sudo dnf -y install epel-release
sudo dnf -y install ansible


# Dir de hosts do Ansible /etc/ansible/hosts
