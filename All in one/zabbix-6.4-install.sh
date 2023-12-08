#!/bin/bash

echo "##############################################################################"
echo "#                                                                            #"
echo "#           ______         ____  ____ _______   __    __ _  _                #"
echo "#          |___  /   /\   |  _ \|  _ \_   _\ \ / /   / /| || |               #"
echo "#             / /   /  \  | |_) | |_) || |  \ V /   / /_| || |_              #"
echo "#            / /   / /\ \ |  _ <|  _ < | |   > <   | '_ \__   _|             #"
echo "#           / /__ / ____ \| |_) | |_) || |_ / . \  | (_) | | |               #"
echo "#          /_____/_/    \_\____/|____/_____/_/ \_\  \___(_)|_|               #"
echo "#                                                                            #"
echo "#                                                                            #"
echo "##############################################################################"

### PROJECT INFO
echo "# project         : 4RSEC Free Software Solutions"
echo "# title           : zabbix-6.4-install.sh"
echo "# description     : Zabbix All in One."
echo "# date            : 20/11/23"
echo "# version         : 6.4"
echo "# usage           : bash zabbix-6.4-install.sh"
echo "# contato         : Ranlens Denck <ranlens.denck@protonmail.com>"
echo "# ATTENTION - EXECUTE TODO O BASH COMO ROOT"
### END PROJECT INFO
sleep 2.0

sudo dnf -y install chrony net-tools nano openssl mod_ssl net-snmp net-snmp-utils && sudo systemctl enable --now snmpd

#-------------------------------------------Instalação concluída com sucesso!---------------------------------
# Desabilitar SELinux
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# Editar o arquivo /etc/chrony.conf
nano /etc/chrony.conf
# Certifique-se de que a data está correta
date
# Conferir o relógio de hardware
hwclock

# Habilitar e iniciar o serviço Chrony
sudo systemctl enable --now chronyd
# Validar se o serviço Chrony está ativo
sudo systemctl status chronyd
# Verificar de onde está validando os pools
chronyc sources

# Setar automaticamente a localidade
timedatectl set-timezone America/Sao_Paulo

# Verificar a localidade atribuída (deve ser America/Sao_Paulo)
timedatectl status

# Criar regra no firewall para o serviço NTP
firewall-cmd --permanent --add-service=ntp

# Atualizar o firewall
firewall-cmd --reload
#-------------------------------------------Primeira parte finalizada!-----------------------------------------

# Desativar os pacotes Zabbix fornecidos pelo EPEL.
echo "Defino que (zabbix) deve ser excluído durante as operações do gerenciador de pacotes"
echo "excludepkgs=zabbix*" | sudo tee -a /etc/yum.repos.d/rocky.repo

echo "Adiciona o repositório Zabbix"
cd /tmp/
rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
echo "Limpar o cache do dnf!"
sudo dnf clean all
echo "Agora vamos atualizar tudo!"
sudo dnf -y update

echo "Muita atenção agora, vamos instalar o zabbix e tudo que ele precisa."
sudo dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

#-------------------------------------------Segunda parte finalizada!------------------------------------------

# Instalando o Postgresql referencia: https://www.postgresql.org/download/linux/redhat/
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
# Verificar o serviço
sudo systemctl status postgresql-14

# # Instalando PgAdmin referencia: https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/
# sudo dnf install -y https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-1-1.noarch.rpm
# sudo dnf install -y pgadmin4
# #configurar pgadmin web
# sudo /usr/pgadmin4/bin/setup-web.sh
# sudo systemctl start pgadmin4
# sudo systemctl enable pgadmin4

#-------------------------------------------Terceira parte finalizada!-----------------------------------------

# Vamos configurar o Banco de Dados postgresql-14.
echo "Defina uma senha segura para o seu banco de dados"
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix_db
echo "Vamos criar as tabelas do banco de dados!"
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix_db

#-------------------------------------------Quarta parte finalizada!-------------------------------------------


# Local do arquivo de configuração do Zabbix Server
zabbix_config_file="/etc/zabbix/zabbix_server.conf"

# Pede ao usuário para configurar o Zabbix Server
read -p "Hostname do servidor do banco de dados (DBHost): " db_host
read -p "Nome do banco de dados (DBName): " db_name
read -p "Usuário do banco de dados (DBUser): " db_user
read -s -p "Senha do banco de dados (DBPassword): " db_password
echo # Adiciona uma nova linha após a senha para melhor formatação
read -p "Porta do banco de dados (DBPort, padrão 3306): " db_port

# Remover linhas antigas do arquivo de configuração
sed -i '/^DBHost=/d' "$config_file"
sed -i '/^DBName=/d' "$config_file"
sed -i '/^DBUser=/d' "$config_file"
sed -i '/^DBPassword=/d' "$config_file"
sed -i '/^DBPort=/d' "$config_file"

# Adicionar novas linhas ao arquivo de configuração
echo "DBHost=$db_host" >> "$config_file"
echo "DBName=$db_name" >> "$config_file"
echo "DBUser=$db_user" >> "$config_file"
echo "DBPassword=$db_password" >> "$config_file"
echo "DBPort=$db_port" >> "$config_file"


# Atualiza o arquivo de configuração do Zabbix Server
replace_or_add "$zabbix_config_file" "ListenPort=" "ListenPort=10051"
replace_or_add "$zabbix_config_file" "# DBHost=" "DBHost=$db_host"
replace_or_add "$zabbix_config_file" "DBName=" "DBName=$db_name"
replace_or_add "$zabbix_config_file" "DBUser=" "DBUser=$db_user"
replace_or_add "$zabbix_config_file" "DBPassword=" "DBPassword=$db_password"
replace_or_add "$zabbix_config_file" "DBPort=" "DBPort=$db_port"

echo "Configuração do Zabbix Server concluída. Reinicie o serviço para aplicar as alterações."

# Inicializa o serviço do zabbix server.
systemctl start zabbix-server
# Habilita a inicialização do serviço junto ao OS 
systemctl enable zabbix-server 
# Verifica o status do serviço
systemctl status zabbix-server 

echo "Serviços do zabbix server funcionando."

# Configuração do zabbix-agent
echo "Agora vamos configurar os serviços do zabbix agent, para coletar dados do server local."

# Arquivo de configuração do Zabbix Server
zabbix_config_file="/etc/zabbix/zabbix_agentd.conf"

# Solicita ao usuário o valor para ListenPort
# Define a porta que o zabbix agent usara
read -p "Informe a porta para ListenPort: " listen_port

# Solicita ao usuário o valor para Hostname
# Define o Hostname ou IP da maquia local.
read -p "Informe o nome da máquina para Hostname: " hostname

# Solicita ao usuario o valor para o server local.
read -p "Informe o IP ou hostname do server:" $server


# Atualiza o arquivo de configuração
sed -i "s/^ListenPort=.*/ListenPort=$listen_port/" "$zabbix_config_file"
sed -i "s/^Hostname=.*/Hostname=$hostname/" "$zabbix_config_file"
sed -i "s/^Server=./*Server=$server/" "$zabbix_conf_file"
sed -i "s/^LogRemoteCommands=.*/LogRemoteCommands=1/" "$zabbix_config_file"	

# Inicializa os serviços do zabbix-agent
systemctl start zabbix-agent
# Habilita a inicialização do serviço junto ao OS 
systemctl enable zabbix-agent
# Verifica o status do serviço
systemctl status zabbix-agent

# Inicializando serviços zabbix web
systemctl restart zabbix-web-service
# Habilita a inicialização do serviço junto ao OS
systemctl enable zabbix-web-service
# Verifica o status do serviço
systemctl status zabbix-web-service

#-------------------------------------------Quinta parte finalizada!-------------------------------------------


# Configuração do servidor Nginx para acesso web do zabbix All in One

# Obtém o endereço IP da máquina
ip_address=$(hostname -I | awk '{print $1}')

# Atualiza a lista de pacotes
sudo apt update

# Instala o Nginx
sudo apt install -y nginx

# Gera um certificado autoassinado para o IP
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/zabbix.key -out /etc/nginx/ssl/zabbix.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=$ip_address"

# Inicia o serviço do Nginx
sudo systemctl start nginx

# Habilita o Nginx para iniciar no boot
sudo systemctl enable nginx

# Configuração do servidor Nginx para Zabbix na porta 443
cat <<EOF | sudo tee /etc/nginx/sites-available/zabbix
server {
    listen 443 ssl;
    server_name $ip_address;

    ssl_certificate /etc/nginx/ssl/zabbix.crt;
    ssl_certificate_key /etc/nginx/ssl/zabbix.key;

    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Cria um link simbólico para ativar o site
sudo ln -s /etc/nginx/sites-available/zabbix /etc/nginx/sites-enabled/

# Reinicia o Nginx para aplicar as configurações
sudo systemctl restart nginx

#--------------------------------------------------------------END----------------------------------------------------------------
echo " _  _   _____   _____ ______ _____ "
echo "| || | |  __ \\ / ____|  ____/ ____|"
echo "| || |_| |__) | (___ | |__ | |     "
echo "|__   _|  _  / \\___ \\|  __|| |     "
echo "   | | | | \\ \\ ____) | |____ |____ "
echo "   |_| |_|  \\_\\_____/|______\\_____|"
echo "                                    "

                                    