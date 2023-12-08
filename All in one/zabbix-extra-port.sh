#!/bin/bash

echo "##################################################################"
echo "#    Script extra, caso queira trocar as portas padrões          #"
echo "#    lemre-se que ao trocar as portas padrões, terá que fazer    #"
echo "#    coisa manualmente. Então fique atento!                      #"
echo "##################################################################"
sleep 4.0
echo "#############################################################################################"
echo "#                     Antes de fazer as configurações, vamos liberar duas portas.           #"
echo "#                        Vamos trocar a 10050 e a 10051 pelas 26050 e 26051                 #"
echo "#############################################################################################"
sleep 2.0
# Abra as portas permanentemente
sudo firewall-cmd --permanent --add-port=26050/tcp
sudo firewall-cmd --permanent --add-port=26051/tcp

# Recarregue o firewall para aplicar as alterações
sudo firewall-cmd --reload
echo "Pronto tudo feito por aqui!"


echo "#############################################################################################"
echo "#                   Pronto agora que estão liberadas, vamos fechar as outras duas.          #"
echo "#                      As portas 10050 e 10051 ficaram fechadas, por segurança.             #"
echo "#############################################################################################"
sleep 2.0

# Remova as portas permanentemente
sudo firewall-cmd --permanent --remove-port=10050/tcp
sudo firewall-cmd --permanent --remove-port=10051/tcp

# Recarregue o firewall para aplicar as alterações
sudo firewall-cmd --reload
echo "#############################################################################################"
echo "#               Agora vamos configurar os arquivos de configuração do zabbix.               #"
echo "#               Preste muita a atenção, as portas 10050 e 10051 foram fechadas,             #"
echo "#                      ou seja deveram ser adicionadas as novas.                            #"
echo "#############################################################################################"
sleep 2.0
