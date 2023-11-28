<h1 align="center">Zabbix 6.4</h1>
<p align="center">
  <img src="https://github.com/r4nl3ns/zabbix/raw/main/icons/zabbix_logo.png" alt="Zabbix 6.4 Logo">
</p>


<p align="center">
  <strong>Plataforma de Monitoramento e Gerenciamento de Redes</strong>
</p>

## 🚀 Introdução

Bem-vindo ao Zabbix 6.4, uma solução avançada para monitoramento de redes e sistemas. Este repositório contém a implementação do Zabbix 6.4.

## ✨ Recursos

- Monitoramento avançado de redes
- Alertas e notificações personalizáveis
- Interface amigável e intuitiva

## 🛠️ Instalação

Clone o repositório:

```bash
git clone https://github.com/r4nl3ns/zabbix-6.4.git
cd /zabbix
```
Permissões:

```bash
chmod +x /zabbix/*.sh
```



# Existe mais de uma opção de instalação.

- Zabbix All in One (tudo no mesmo servidor)
  Para isso execute o seguinte comando:
  ```bash
  cd /zabbix one server
  ./zabbix-6.4-install.sh
  ```

 - Zabbix em Alta Disponibilidade ( HA )
 Para isso seguiremos uma ordem. Os arquivos citados dentro do diretório `/modules` são definidos por ordem, e importância.
    O `config-ambiente`deve ser executado em **todas as máquinas** ele é responsável por instalar tudo que elas precisam, e fazer as devidas alterações, ou seja, não importa como ficará
    a sua estrutura de *VMS* o ambiente deve ser configurado, e é isso que esse *shell* faz.
    ```bash
    cd /modules
    ./config-ambiente.sh
    ```

  - Escolha qual Web Server usar.
  **Apache** *vs* **Nginx** - Em ambos os casos, a consiguração do *https* pode ocorrer alguns erros, algo que deve ser dado muita atenção, e se possível corrigir manualmente.
      ```bash
      # O servidor nginx será instalado e pré-configurado, mas é preciso verificar detalhadamente cada configuração
      ./nginx.sh
      ```
      ```bash
      # O servidor apache será instalado e pré-configurado, mas é preciso dar *muita* atenção a
      # configuração de certificado.
      ./apache-zbx-install.sh
      ```

 "continua..."
      
    




