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
echo "# project         : Monx Free Software Solutions"
echo "# title           : zabbix-6.4-install.sh"
echo "# description     : Script para a instalação do Zabbix Server & Agent."
echo "# date            : 20/11/23"
echo "# version         : 6.4"
echo "# usage           : bash zabbix-6.4-install.sh"
echo "# contato         : Ranlens Denck <ranlens.denck@protonmail.com>"
echo "# ATTENTION - EXECUTE TODO O BASH COMO ROOT"
### END PROJECT INFO


echo "Vamos instalar os pacotes necessarios para trabalhar aqui."
dnf -y install net-tools
dnf -y install nano
dnf install openssl
echo "excludepkgs=zabbix*" | sudo tee -a /etc/yum.repos.d/rocky.repo
sleep 0.3

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado como root."
  exit 1
fi

# Captura o endereço IP da máquina
SEU_IP=$(hostname -I | awk '{print $1}')

# Domínio a ser associado ao IP
DOMINIO="monx.zabbix.com"

# Adiciona a entrada no /etc/hosts
echo "$SEU_IP $DOMINIO" >> /etc/hosts

echo "Entrada adicionada com sucesso em /etc/hosts."


echo "Adiciona o repositório Zabbix"
rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
echo "Limpar o cache do dnf!"
dnf clean all
echo "Agora vamos atualizar tudo!"
dnf -y update

echo "Muita atenção agora, vamos instalar o zabbix e tudo que ele precisa."
dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-selinux-policy zabbix-agent zabbix-web-service


echo "Vamos fazer as configuracoes necesarias, preciso de sua TOTAL ATENCAO!"
sleep 0.3

# Função para substituir ou adicionar uma linha em um arquivo
replace_or_add() {
    local file="$1"
    local search_pattern="$2"
    local replacement="$3"

    if grep -q "$search_pattern" "$file"; then
        # Substitui a linha existente
        sed -i "s|$search_pattern.*|$replacement|" "$file"
    else
        # Adiciona uma nova linha
        echo "$replacement" >> "$file"
    fi
}

# Função para validar a porta do MySQL
validate_mysql_port() {
    local port="$1"

    if [[ "$port" =~ ^[0-9]+$ ]] && ((port >= 1024 && port <= 49151)); then
        return 0  # Porta válida
    else
        return 1  # Porta inválida
    fi
}

# Local do arquivo de configuração do Zabbix Server
zabbix_config_file="/etc/zabbix/zabbix_server.conf"

# Verifica se o Zabbix Server está instalado
if ! command -v zabbix_server &> /dev/null; then
    echo "Erro: Zabbix Server não está instalado. Por favor, instale o Zabbix Server antes de executar este script."
    exit 1
fi

echo "---------------------------------------------------------------------------------"
echo "         Antes de fazer as configurações, vamos liberar duas portas."
echo "            Vamos trocar a 10050 e a 10051 pelas 26050 e 26051"
echo "---------------------------------------------------------------------------------"
# Abra as portas permanentemente
sudo firewall-cmd --permanent --add-port=26050/tcp
sudo firewall-cmd --permanent --add-port=26051/tcp

# Recarregue o firewall para aplicar as alterações
sudo firewall-cmd --reload
echo "Pronto tudo feito por aqui!"

echo "---------------------------------------------------------------------------------"
echo "     Pronto agora que estão liberadas, vamos fechar as outras duas."
echo "       As portas 10050 e 10051 ficaram fechadas, por segurança."
echo "---------------------------------------------------------------------------------"
# Remova as portas permanentemente
sudo firewall-cmd --permanent --remove-port=10050/tcp
sudo firewall-cmd --permanent --remove-port=10051/tcp

# Recarregue o firewall para aplicar as alterações
sudo firewall-cmd --reload
echo "Pronto tudo feito por aqui!"

echo "----------------------------------------------------------------------------------"
echo "Agora vamos configurar os arquivos de configuração do zabbix"
echo "Preste muita a atenção, as portas 10050 e 10051 foram fechadas, ou seja deveram"
echo "ser adicionadas as novas."
echo "----------------------------------------------------------------------------------"

# Pede ao usuário para configurar o Zabbix Server
read -p "Hostname do servidor do banco de dados (DBHost): " db_host
read -p "Nome do banco de dados (DBName): " db_name
read -p "Usuário do banco de dados (DBUser): " db_user
read -s -p "Senha do banco de dados (DBPassword): " db_password
echo # Adiciona uma nova linha após a senha para melhor formatação
read -p "Porta do banco de dados (DBPort, padrão 3306): " db_port

# Valida a porta do MySQL
while ! validate_mysql_port "$db_port"; do
    read -p "Porta inválida. Por favor, insira uma porta válida para o MySQL: " db_port
done

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
sleep 0.3

echo "Serviços do zabbix server funcionando."



# Configuração do zabbix-agent
echo "Agora vamos configurar os serviços do zabbix agent, para coletar dados do server local."

# Arquivo de configuração do Zabbix Server
zabbix_config_file="/etc/zabbix/zabbix_server.conf"

# Solicita ao usuário o valor para ListenPort
# Define a porta que o zabbix agent usara
read -p "Informe a porta para ListenPort: " listen_port

# Solicita ao usuário o valor para Hostname
# Define o Hostname ou IP da maquia local.
read -p "Informe o nome da máquina para Hostname: " hostname

# Atualiza o arquivo de configuração
sed -i "s/^ListenPort=.*/ListenPort=$listen_port/" "$zabbix_config_file"
sed -i "s/^Hostname=.*/Hostname=$hostname/" "$zabbix_config_file"
sed -i "s/^LogRemoteCommands=.*/LogRemoteCommands=1/" "$zabbix_config_file"

# Inicializa os serviços do zabbix-agent
systemctl start zabbix-agent
# Habilita a inicialização do serviço junto ao OS 
systemctl enable zabbix-agent
# Verifica o status do serviço
systemctl status zabbix-agent

# Inicializando serviços zabbix web
systemctl restart zabbix-web-service
systemctl enable zabbix-web-service
systemctl status zabbix-web-service

echo "------------------------------------------------------------------------------------------------------"

echo "Quase tudo pronto! agora precisamos fazer mais algumas configurações."

# Necessario desabilitar o selinux-policy
echo " Após essa configuração a máquina será reiniciada."
# Arquivo de configuração do SELinux
selinux_config_file="/etc/selinux/config"

# Verifica se o arquivo de configuração existe
if [ -e "$selinux_config_file" ]; then
    # Substitui SELINUX=enforcing por SELINUX=disabled
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' "$selinux_config_file"
    echo "SELinux desabilitado. Reinicie o sistema para aplicar as alterações."
else
    echo "Erro: Arquivo de configuração do SELinux não encontrado."
fi
sleep 0.3

echo "################################################################################################"
echo "		Agora vamos configurar o Apache, ele usara HTTPS 										 #"
echo "				Vamos liberar as portas 443	e 80												 #"
echo "################################################################################################"
# Liberar a porta 443 no firewall para o zabbix web
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload

#liberar a porta 80 para acessar o zabbix apartir do IP/zabbix
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload



















