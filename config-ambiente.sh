#!/bin/bash

echo "
···········································································
:  ____             __ _                            /\/|             _      :
: / ___|___  _ __  / _(_) __ _ _   _ _ __ __ _  ___|/\/_  ___     __| | ___ :
:| |   / _ \| '_ \| |_| |/ _` | | | | '__/ _` |/ __/ _` |/ _ \   / _` |/ _ \:
:| |__| (_) | | | |  _| | (_| | |_| | | | (_| | (_| (_| | (_) | | (_| |  __/:
: \____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\___\__,_|\___/   \__,_|\___|:
:    _              _    |___/         _        )_)                         :
:   / \   _ __ ___ | |__ (_) ___ _ __ | |_ ___                              :
:  / _ \ | '_ ` _ \| '_ \| |/ _ \ '_ \| __/ _ \                             :
: / ___ \| | | | | | |_) | |  __/ | | | ||  __/                             :
:/_/   \_\_| |_| |_|_.__/|_|\___|_| |_|\__\___|                             :
···········································································                                 
"

echo "#############################################################################################"
echo "#                  Vamos instalar tudo que usaremos para esse ambiente zabbix.              #"
echo "#############################################################################################"
sleep 2.0

dnf -y install net-tools
dnf -y install nano
dnf -y install openssl
dnf -y install mod_ssl
dnf -y install net-snmp
systemctl enable snmpd
systemctl start snmpd
sleep 2.0


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


echo "#############################################################################################"
echo "#                      Vamos liberar as portas usadas pelo HTTPS no firewall.               #"
echo "#############################################################################################"
sleep 2.0
# Libera as portas 80 e 443 no firewall
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload
sleep 2.0



echo "#############################################################################################"
echo "#              Vamos configurar a hora, e adicionar o pacote de idiomas.                    #"
echo "#############################################################################################"
sleep 2.0


# Instala o pacote de idiomas para o português do Brasil
sudo dnf -y install -y glibc-langpack-pt

# Configura a localidade para o português do Brasil em UTF-8
echo 'LANG=pt_BR.utf8' | sudo tee /etc/locale.conf

# Configura o fuso horário para Brasília
sudo timedatectl set-timezone America/Sao_Paulo

# Reinicia o serviço de horário para aplicar as alterações
sudo systemctl restart systemd-timedated
sleep 2.0


echo "#############################################################################################"
echo "#                            Vamos atualizar todos os repositórios.                         #"
echo "#############################################################################################"
dnf -y update