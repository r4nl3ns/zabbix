#!/bin/bash

# -------------------------------------------------Instalar ferramentas---------------------------------------------#
sudo dnf -y install nano
sudo dnf -y install chrony
sudo dnf -y install net-tools
sudo dnf -y install bind-utils

echo "----------------------------Baixar os pacotes necessários------------------------------------------------"
sleep 1.0
cd /tmp/
sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
sudo dnf clean all
cd /

# ----------------------------------Vamos instalar o script SQL que o banco precisa----------------------------#
sudo dnf -y zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

echo "Instalação feita com sucesso!"

# ------------------------------------------Agora vamos instalar o Postgresql-14 com a extensão TimescaleDB-----------------------------------#
# Verificar a lista de módulos disponíveis para PostgreSQL
sudo dnf module list postgresql

# Instalação do banco de dados PostgreSQL 14
sudo dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Desativar o repositório padrão do PostgreSQL
sudo dnf -qy module disable postgresql 

# Instalar o PostgreSQL 14
sudo dnf -y install postgresql14 postgresql14-server postgresql14-contrib

# Instalar a extensão TimescaleDB
sudo dnf -y install timescaledb-postgresql-14

echo "Instalação do PostgreSQL e TimescaleDB feita com sucesso!"

# ------------------------------------- Configurar o PostgreSQL e o TimescaleDB ------------------------------------- #
# Inicializa o PostgreSQL
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb

# Inicia o PostgreSQL
sudo systemctl start postgresql-14
# Habilita o PostgreSQL
sudo systemctl enable postgresql-14
# Verifica o status do PostgreSQL
sudo systemctl status postgresql-14

# Configura o TimescaleDB no PostgreSQL
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"

# Reinicia o PostgreSQL para aplicar as configurações do TimescaleDB
sudo systemctl restart postgresql-14

echo "Configuração do TimescaleDB concluída com sucesso!"

# ------------------------------------------Criação do usuário do banco de Dados----------------------------------------------#
# Criar usuário zabbix
sudo -u postgres createuser --pwprompt zabbix
# Criar banco de dados zabbix
sudo -u postgres createdb -O zabbix zabbix
# Populando as tabelas do banco de dados do postgresql-14
sudo zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
# Instalação dos pacotes de idiomas no frontend do Zabbix
sudo dnf install glibc-locale-source
