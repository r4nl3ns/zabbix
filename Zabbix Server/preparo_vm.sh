# Permitir tráfego na porta 5432 (PostgreSQL)
sudo firewall-cmd --zone=public --add-port=5432/tcp --permanent

# Permitir tráfego na porta 3306 (MySQL)
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent