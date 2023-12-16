#!/bin/bash
#-------------------------------------------------Instalar tools---------------------------------------------#
sudo dnf -y install nano
sudo dnf -y install chrony
sudo dnf -y install net-tools
sudo dnf -y install bind-utils

echo ----------------------------Baixar os pacotes necessários------------------------------------------------
sleep 1.0
cd /tmp/
rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
sudo dnf clean all
cd /
#-------------------------------------Agora vamos instalar os pacotes que o Postgresql-14 precisa----------------------------#
sudo dnf -y install zabbix-sql-scripts zabbix-agent

echo "Instalação feita com sucesso!"
#------------------------------------------Agora vamos instalar o Postgresql-14----------------------------------------------#
# Verificar a lista de repositórios disponíveis para RHELL
dnf module list postgresql

# Instalação do banco de dados Postgresql 14
dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Desativar o repositório padrão do PostgreSQL
dnf -qy module disable postgresql 

# Instalar o PostgreSQL 14
dnf -y install postgresql14 postgresql14-server 

# Inicializa o Postgresql
/usr/pgsql-14/bin/postgresql-14-setup initdb

# Inicia o postgresql
systemctl start postgresql-14
# Habilita o postgresql
systemctl enable postgresql-14
# Verifica o status do postgresql
systemctl status postgresql-14

--
# Criar usuario zabbix
sudo -u postgres createuser --pwprompt zabbix
# Criar banco zabbix
sudo -u postgres createdb -O zabbix zabbix


# Instalação dos pacotes de idiomas no zabbix frontend
sudo yum install glibc-locale-source
