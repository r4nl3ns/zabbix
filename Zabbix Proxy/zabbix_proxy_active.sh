#!/bin/bash
# Monitoramento ATIVO do proxy (O servidor Zabbix monitora o estado do servidor proxy)

# Instalação do Zabbix Proxy

cd /tmp/

sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
sudo dnf clean all

# Instalação do proxy e do agente
sudo dnf -y install zabbix-proxy-sqlite3 zabbix-selinux-policy zabbix-agent

# Após a instalação, é necessário configurar o proxy
sudo nano /etc/zabbix/zabbix_proxy.conf

# Configurações no arquivo zabbix_proxy.conf
sudo bash -c "cat <<EOL > /etc/zabbix/zabbix_proxy.conf
Server=IP_do_zbx-server
Hostname=$(hostname)
DBName=/etc/zabbix/banco/zabbix_proxy.db
EOL"

# Criação do diretório para o banco de dados
sudo mkdir -p /etc/zabbix/banco/
sudo chown -R zabbix:zabbix /etc/zabbix/banco

# Reiniciar e inicializar serviços
sudo systemctl enable zabbix-agent zabbix-proxy
sudo systemctl restart zabbix-agent zabbix-proxy

# Criação do diretório para as chaves PSK
sudo mkdir -p /etc/zabbix/keys
sudo chown -R zabbix:zabbix /etc/zabbix/keys

sudo nano /etc/zabbix/zabbix_agentd.conf

# Configurações no arquivo zabbix_agentd.conf
sudo bash -c "cat <<EOL > /etc/zabbix/zabbix_agentd.conf
Server=127.0.0.1
ServerActive=127.0.0.1
Hostname=$(hostname)
Timeout=30
EOL"

sudo systemctl restart zabbix-agent zabbix-proxy
sudo systemctl status zabbix-proxy
sudo tail -f /var/log/zabbix/zabbix_proxy.log
