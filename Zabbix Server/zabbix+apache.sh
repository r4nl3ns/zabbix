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

# Instalação do Apache versão (httpd)
dnf -y install httpd mod_ssl
systemctl enable httpd.service
systemctl start httpd.service
echo "---------------------------------------------------------------------------------"
echo " Cria os repositórios necessários para os certificados."
mkdir -p /etc/httpd/ssl/private
chmod 700 /etc/httpd/ssl/private
echo "---------------------------------------------------------------------------------"
echo " Configura dominio que será usado."

# Defina o nome do domínio
DOMINIO="monx.com"

# Caminho para os certificados SSL
SSL_PATH="/etc/httpd/ssl/private"

# Caminho para os certificados privados
SSL_PRIVATE_PATH="$SSL_PATH/private"
sleep 3.0


echo "##################################################################################################"
echo "#             Uma opção ao certificado manual, feito passo a passo é usar o CertBot,             #"
echo "#       ele é automatico, cria o certificado e já adiciona no virtualhost sem mais trabalhos.    #"
echo "#          CertBot ->  git clone https://github.com/letsencrypt/letsencrypt                      #"
echo "##################################################################################################"
sleep 5.0


# Gere um certificado autoassinado para SSL (certificado e chave aqui gerados, são para uso geral.)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/httpd/ssl/private/private.monx.key \
  -out /etc/httpd/ssl/certificate.monx.crt \
  -subj "/C=/ST=/L=/O=/OU=/CN=monx.com/emailAddress=" \
  -passout pass:

# Adicione o domínio ao arquivo /etc/hosts
echo "127.0.0.1 $DOMINIO" >> /etc/hosts

# Crie um arquivo de configuração para o site Zabbix
cat <<EOL > /etc/httpd/conf.d/zabbix-ssl.conf
<VirtualHost *:443>
  ServerAdmin ranlens.denck@protonmail.com
  ServerName $DOMINIO
  DocumentRoot /var/www/html

  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined

  SSLEngine on
  SSLCertificateFile $SSL_PATH/$DOMINIO.crt
  SSLCertificateKeyFile $SSL_PRIVATE_PATH/$DOMINIO.key

  <Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOL

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






Editar o arquivo de configuração Apache SSL (/etc/httpd/conf.d/ssl.conf): 
	DocumentRoot "/usr/share/zabbix"
       ServerName example.com:443
       SSLCertificateFile /etc/httpd/ssl/certificate.monx.crt
       SSLCertificateKeyFile /etc/httpd/ssl/private/private.monx.key