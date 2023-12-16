#!/bin/bash
# Monitoramento ATIVO do proxy ( O servidor zabbix monitora o estado do servidor proxy

# Instalação zabbix proxy

cd /tmp/

rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
dnf clean all

# Instalação do proxy e do agent
dnf -y install zabbix-proxy-sqlite3 zabbix-selinux-policy zabbix-agent

# Após a instação é necessário configurar o proxy
nano /etc/zabbix/zabbix_proxy.conf

serve=IP do zbx-server
hostname=nomedoproxy
mkdir /etc/zabbix/banco/
sudo chown -R zabbix:zabbix /etc/zabbix/banco
DBName=/etc/zabbix/banco/zabbix_proxy.db
--
# Restart e inicializa ambos
systemctl enable zabbix-agent zabbix-proxy
--
# Criação do dir para as chaves psk
mkdir /etc/zabbix/keys
sudo chown -R zabbix:zabbix /etc/zabbix/keys


nano /etc/zabbix/zabbix_agentd.conf

server=127.0.0.1
server ative=127.0.0.1
hostname=nomedoproxy
timeout=30

--

systemctl restart zabbix-agent zabbix-proxy
tail -f /var/log/zabbix/zabbix_proxy.log

