#!/bin/bash

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
