#!/bin/bash

# ANSI escape codes for red color
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~.${NC}"
echo -e "${RED}      ~&@@@@@@@@@@@@@@@@@@@@@@@@@@5.${NC}"
echo -e "${RED}       ^#@@@@@@@@@@@@@@@@@@@@@@@@Y${NC}"
echo -e "${RED}        :B@@@@@@@PJBJPPJ#@@@@@@@J          ^!!.      .!!~                         ^Y5!${NC}"
echo -e "${RED}         :B@@@@@@Y!G!Y5~B@@@@@@?           7@@P      5@@?                         ?@@Y   YG5${NC}"
echo -e "${RED}          .G@@@@@Y7B755!B@@@@@7             P@@!    ~@@G  :!7??7~:   :!!:   :!!:  7@@J ^7&@&7!~${NC}"
echo -e "${RED}           .G@@@@57B!Y5!B@@@@7              ^&@#.  .B@&^  ?#GPG#@&7  7@@J   J@@!  7@@J JB&@&GGY${NC}"
echo -e "${RED}            .P@@@@@#!Y@@@@@&!                ?@@Y  J@@J    ..:.!@@P  !@@J   J@@!  7@@J  .#@B.${NC}"
echo -e "${RED}              5@@@@@&@@@@@&~                  G@&^:&@B.  :P##BBB@@P  7@@?   J@@!  7@@J  .#@B${NC}"
echo -e "${RED}               Y@@@@@@@@@#^                   ^&@GG@@~   Y@@7..!@@P  !@@5^~7B@@!  7@@J  .#@#:..${NC}"
echo -e "${RED}                J@@@@@@@B:                     J@&&@Y    ^G@#GGP#@P  .G@@&&BP&&!  7@@J   J&@&#Y${NC}"
echo -e "${RED}                 ?@@@@@G:                       ::::       :^^: .:.    :^^.  .:.  .::.    .^^^.${NC}"
echo -e "${RED}                  7@@@G.${NC}"
echo -e "${RED}                   7@P.${NC}"
echo -e "${RED}                    ^.${NC}"

### PROJECT INFO
echo "# project         : 4RSEC Free Software Solutions"
echo "# title           : vault.sh"
echo "# description     : Instalação de servidor Hashicorp Vault."
echo "# date            : 09/12/23"
echo "# version         : 1.15.0"
echo "# usage           : bash Hashicorp Vault "
echo "# contato         : Ranlens Denck <ranlens.denck@protonmail.com>"
echo "# ATTENTION - EXECUTE TODO O BASH COMO ROOT"
### END PROJECT INFO
sleep 2.0
#-------------------------------------------------Instalar tools---------------------------------------------#
sudo dnf -y install nano
sudo dnf -y install chrony
sudo dnf -y install net-tools

# Definir a versão do HashiCorp Vault
VAULT_VERSION="1.15.0"

# URL de download para a versão específica do Vault
DOWNLOAD_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"

# Diretório de instalação
INSTALL_DIR="/usr/local/bin"

# Baixar e extrair o Vault
echo "Baixando e instalando o HashiCorp Vault ${VAULT_VERSION}..."
curl -LO $DOWNLOAD_URL
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo mv vault $INSTALL_DIR

# Limpar arquivos de instalação temporários
rm vault_${VAULT_VERSION}_linux_amd64.zip

# Adicionar ao PATH
echo "Adicionando o HashiCorp Vault ao PATH..."
echo "export PATH=\$PATH:$INSTALL_DIR" | sudo tee -a /etc/profile
source /etc/profile

# Exibir versão instalada
echo "HashiCorp Vault ${VAULT_VERSION} instalado com sucesso!"

# Verificar a instalação
vault --version
