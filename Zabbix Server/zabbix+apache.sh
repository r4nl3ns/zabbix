#!/bin/bash

echo -e "\033[1;36m"  # Define a cor do texto para ciano brilhante

cat << "EOF"
: ___           _        _            /\/|             _       :
:|_ _|_ __  ___| |_ __ _| | __ _  ___|/\/_  ___     __| | ___  :
: | || '_ \/ __| __/ _` | |/ _` |/ __/ _` |/ _ \   / _` |/ _ \ :
: | || | | \__ \ || (_| | | (_| | (_| (_| | (_) | | (_| | (_) |:
:|___|_| |_|___/\__\__,_|_|\__,_|\___\__,_|\___/   \__,_|\___/ :
:    _                     _      )_)                          :
:   / \   _ __   __ _  ___| |__   ___                          :
:  / _ \ | '_ \ / _` |/ __| '_ \ / _ \                         :
: / ___ \| |_) | (_| | (__| | | |  __/                         :
:/_/   \_\ .__/ \__,_|\___|_| |_|\___|                         :
:        |_|                                                   :
EOF

echo -e "\033[0m"  # Restaura a cor do texto para o padrão


#------------------------------------------Instalação Tools----------------------------------------------


# Instalação do Apache versão (httpd)
sudo dnf -y install httpd mod_ssl
sudo systemctl enable httpd.service
sudo systemctl start httpd.service

# Ative o novo site e reinicie o Apache
systemctl enable httpd
systemctl restart httpd

# Abra a porta 443 no firewall (se aplicável)
# Certifique-se de ajustar isso conforme a configuração do seu firewall
firewall-cmd --add-service=https --permanent
firewall-cmd --reload

echo "Apache instalado e configurado com sucesso para o Zabbix na porta 443 com HTTPS."

sudo chown -R apache:apache /etc/httpd/
sudo chmod -R 755 /etc/httpd/

#certificado

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/httpd/ssl/private/private.monx.key \
  -out /etc/httpd/ssl/certificate.monx.crt \
  -subj "/C=/ST=/L=/O=/OU=/CN=monx.com/emailAddress=" \
  -passout pass:

# Editar o arquivo de configuração Apache SSL (/etc/httpd/conf.d/ssl.conf): 
	DocumentRoot "/usr/share/zabbix"
       ServerName example.com:443
       SSLCertificateFile /etc/httpd/ssl/certificate.monx.crt
       SSLCertificateKeyFile /etc/httpd/ssl/private/private.monx.key