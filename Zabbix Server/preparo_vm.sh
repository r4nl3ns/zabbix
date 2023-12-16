#!/bin/bash



sudo dnf -y install nano
sudo dnf -y install chrony
sudo dnf -y install net-tools

#desabilitar selinux
nano /etc/selinux/config
#SELINUX=disable

setenforce 0

#editar nano /etc/chrony.conf
date -conferir se está correta a data

#conferir relógio de hardware
hwclock -conferir a saida

#ambas as saídas, date e hwclock devem estar iguais.

--
#habilitando serviço
systemctl enable chronyd
#iniciando serviço
systemctl start chronyd
#validando serviço ativo
systemctl status chronyd

#verifica de onde está validando os pools
chronyc sources

--

#verifica a localidade que está sendo atribuída. deve ser: America/Sao_Paulo
timedatectl status

#seta automaticamente a localidade.
timedatectl set-timezone America/Sao_Paulo

#seta manualmente a localidade
tzselect
2
9
8
#confirmar opção: 1

--
#criar regra no firewall
firewall-cmd --permanent --add-service=ntp
#atualiza
firewall-cmd --reload

