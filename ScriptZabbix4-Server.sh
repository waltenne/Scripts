#!/bin/bash
# 
# Versão=1.0
# 
# Script para automatização da instação do Zabbix-Server
#
# Criado por: Waltenne Carvalho
# 
			
ERRO=/tmp/errorinstallZabbix.log

#Verifica se o usuario é "root"
if [ `whoami` != root ]; then
	echo "$BANNER_PRINCIPAL""
    -------------------------------------------------------------------
                             !!!!ATENCAO!!!!                            
           O usuario logado "$USER" nao e Administrador (ROOT)            
     Para executar esse programa, voce precisar ter permissoes de ROOT 
                    Saindo do Script em 2 segundos ...                
    -------------------------------------------------------------------"

	sleep 2
	exit 0
fi

echo "
   	-----------------------------------------------------------------
       !!! Script Automatico para Instalacao do Zabbix Server 4 !!!
     	          !!! Primeiramente Irei Atualizar o SO !!!     
  	-----------------------------------------------------------------"
yum install epel* -y
yum update -y
yum upgrade -y

iptables -A INPUT -p tcp -s localhost --dport 10050 -m state --state NEW,ESTABLISHED -j ACCEPT

  clear
  sleep 3
echo "
   	-----------------------------------------------------------------
                !!! Atualizacao do Sistema Concluida !!!	 
   	-----------------------------------------------------------------"
	 
  clear
  sleep 2

echo "
   	-----------------------------------------------------------------
               !!! Adicionando Repositorio Zabbix 4.0 !!!
   	-----------------------------------------------------------------"

rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm 

  sleep 2

echo "
   	-----------------------------------------------------------------
                      !!! Instalarei os pacotes !!!           
   	-----------------------------------------------------------------"
	
yum install zabbix-server-mysql zabbix-proxy-mysql zabbix-web-mysql mariadb-server zabbix-agent -y 
yum install php-cli php-common php-devel php-pear php-gd php-mbstring php-mysql php-xml -y
yum config-manager --enable rhel-7-server-optional-rpms -y

  clear
  sleep 3

echo "
   	-----------------------------------------------------------------
                     !!! Configuracao Servicos !!!         
   	-----------------------------------------------------------------"

systemctl enable httpd
systemctl start httpd
systemctl enable zabbix-agent
systemctl enable mariadb
systemctl start mariadb

	echo "
    -------------------------------------------------------
             !!!Aplicando configuracoes Zabbix!!!     
    -------------------------------------------------------"
	clear
	echo -n "Digite o nome do usuario do Banco de dados(Mysql):"
	read dbuserI
	clear
	echo -n "Digite a senha do usuario banco de dados(Mysql):"
	read dbpassI
	clear
	echo -n "Digite o nome do banco de dados(Mysql):"
	read dbnameI
	clear
	echo -n "Digite a senha do usuario root(Mysql):"
	read dbpassRoot
	clear

    mysqladmin -uroot password $dbpassRoot
    echo "create database $dbnameI character set utf8;" | mysql -uroot -p$dbpassI
    echo "GRANT ALL PRIVILEGES ON $dbnameI.* TO $dbuserI@localhost IDENTIFIED BY '$dbpassI';" | mysql -uroot -p$dbpassRoot    
	
sleep 1
	
	zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -u$dbuserI $dbnameI -p$dbpassI
	
    echo "DBHost=localhost
          DBName=$dbnameI
          DBUser=$dbuserI
          DBPassword=$dbpassI 
		  CacheSize=50M                      
          LogFile=/var/log/zabbix/zabbix_server.log" > /etc/zabbix/zabbix_server.conf
		  
sleep 1

	cat << EOF > /etc/httpd/conf.d/zabbix.conf 
#
# Zabbix monitoring system php web frontend
#

Alias /zabbix /usr/share/zabbix

<Directory "/usr/share/zabbix">
    Options FollowSymLinks
    AllowOverride None
    Require all granted

    <IfModule mod_php5.c>
        php_value max_execution_time 300
        php_value memory_limit 128M
        php_value post_max_size 16M
        php_value upload_max_filesize 2M
        php_value max_input_time 300
        php_value max_input_vars 10000
        php_value always_populate_raw_post_data -1
        php_value date.timezone America/Sao_Paulo
    </IfModule>
</Directory>

<Directory "/usr/share/zabbix/conf">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/app">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/include">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/local">
    Require all denied
</Directory>
EOF

sleep 1

	# Criando arquivo de configuração zabbix_agentd.conf
	echo -n "Digite o IP do servidor Zabbix:"
	read ipservidor
	echo -n "Digite o Hostname para essa maquina:"
	read srvhostname
	clear
	
sleep 1
	
cat << EOF > /etc/zabbix/zabbix_agentd.conf
Server=$ipservidor
Hostname=$srvhostname
StartAgents=1
DebugLevel=3
PidFile=/tmp/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
Timeout=3
EnableRemoteCommands=1
EOF

echo "date.timezone America/Sao_Paulo"  >> /etc/php.ini

systemctl restart httpd
zabbix_sever
systemctl enable zabbix_sever

sleep 1

echo "-------------------------------------------------------
                    !!!Instalacao Concluida!!!            
      -------------------------------------------------------"
sleep 1
echo "-------------------------------------------------------
            !!!Acesse do seu navegador IP/zabbix !!!    
      -------------------------------------------------------"
sleep 1
exit 0	


