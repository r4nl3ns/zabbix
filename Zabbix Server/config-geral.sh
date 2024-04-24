#!/bin/bash

# Projeto de Implantação da Ferramenta de Monitoramento Zabbix
# Scrip de Configuração de ambiente RHEL

#--------------------------------------Instalação de Tools-----------------------------------------------
sudo dnf -y install net-snmp pacemaker corosync net-tools nano openssl mod_ssl net-snmp chrony glibc-langpack-pt
#--------------------------------------Habilitando Tools-------------------------------------------------
sudo systemctl enable snmpd
sudo systemctl enable pacemaker
sudo systemctl enable corosync
sudo systemctl enable chronyd
#--------------------------------------Startando Tools---------------------------------------------------
sudo systemctl start snmpd
sudo systemctl start pacemaker
sudo systemctl start corosync
sudo systemctl start chronyd
#--------------------------------------Conferindo status-------------------------------------------------
sudo systemctl status snmpd
sudo systemctl status pacemaker
sudo systemctl status corosync
sudo systemctl status chronyd
setenforce 0
#--------------------------------------Conferindo a Data-------------------------------------------------
sudo timedatectl set-timezone America/Sao_Paulo
sudo systemctl restart systemd-timedated
sudo timedatectl show --property=RTC
sudo timedatectl set-local-rtc 1
date -conferir se está correta a data
sleep 1.0
hwclock -conferir a saida
sleep 1.0
timedatectl status
echo "Parece estar tudo funcionando corretamente!"
sleep 1.0
#-----------------------------------------CHRONYD MANUAL-------------------------------------------------
#NTP SERVERS
sudo nano /etc/chronyd.conf
# Na opção (server) adicionar o server necessário, abaixo algumas opções de server para UTC -3
server 0.br.pool.ntp.org iburst
server 1.br.pool.ntp.org iburst
server 2.br.pool.ntp.org iburst
server 3.br.pool.ntp.org iburst


#--------------------------------------Baixando pacotes zabbix--------------------------------------------
cd /tmp/
rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
sudo dnf clean all
cd /

repo_file="/etc/yum.repos.d/zabbix.repo"

# Verificar se o arquivo de repositório existe
if [ -e "$repo_file" ]; then
    # Descomentar a linha excludepkgs
    sed -i 's/^excludepkgs=zabbix*/#excludepkgs=zabbix*/' "$repo_file"
    echo "Linha excludepkgs descomentada no arquivo $repo_file."
else
    echo "Arquivo $repo_file não encontrado."
fi

#--------------------------------------Desabilita o SELINUX--------------------------------------------
sudo nano /etc/selinux/config
#SELINUX=disable
sleep 1.0

echo "#############################################################################################"
echo "#                      Configurando Hostname e associando ao IP de rede.                    #"
echo "#############################################################################################"
sleep 2.0

# Verifica se /etc/hostname está vazio
if [ ! -s /etc/hostname ]; then
    # Solicita ao usuário que digite um nome de host
    read -p "O arquivo /etc/hostname está vazio. Digite um nome de host: " user_hostname

    # Adiciona o nome de host ao arquivo /etc/hostname
    echo "$user_hostname" | sudo tee /etc/hostname > /dev/null
else
    # Captura o nome do host do arquivo /etc/hostname
    user_hostname=$(cat /etc/hostname)
fi

# Captura o endereço IP da interface de rede
ip_address=$(hostname -I | awk '{print $1}')

# Adiciona a entrada no /etc/hosts
echo "$ip_address   $user_hostname" | sudo tee -a /etc/hosts > /dev/null

echo "Entrada adicionada ao /etc/hosts:"
grep "$user_hostname" /etc/hosts
sleep 2.0

#--------------------------------------Configura o Firewall do ambiente--------------------------------------
# Libera as portas 80 e 443 no firewall
sudo firewall-cmd --add-port=80/tcp --permanent
# Libera porta para https
sudo firewall-cmd --add-port=443/tcp --permanent
# Libera porta para o zabbix agent
sudo firewall-cmd --add-port=10050/tcp --permanent
# Libera porta para zabbix proxy
sudo firewall-cmd --add-port=10051/tcp --permanent
# Libera porta para banco de dados MySQL
sudo firewall-cmd --add-port=3306/tcp --permanent
# Libera porta para banco de dados PostgreSQL
sudo firewall-cmd --add-port=5432/tcp --permanent
# Aplica as regras no fw
sudo firewall-cmd --reload




