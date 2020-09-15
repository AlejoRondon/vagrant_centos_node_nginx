//Linux 
//Nginx
//MariaDB
//PHP
#https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-8-es
#https://medium.com/@shoaibhassan_/install-wordpress-with-postgresql-using-apache-in-5-min-a26078d496fb

# Instalación de PostgreSQL
# https://comoinstalar.me/como-instalar-postgresql-en-centos-8/

# Creación de Base de Datos PostgreSQL, Descarga de WordPress y WP4PG para la conexión con PostgreSQL
# https://medium.com/@shoaibhassan_/install-wordpress-with-postgresql-using-apache-in-5-min-a26078d496fb

# Configuración PostgreSQL y Firewall
# https://desarrollowebtutorial.com/conexion-remota-a-postgresql-en-centos-7/

# Desbloquear SELinux para la conexión con la Base de Datos PostgreSQL
# https://stackoverrun.com/

#Paso 1: Instalar PostgreSQL
sudo dnf module list postgresql
sudo dnf module -y enable postgresql:12
#Tras habilitar el flujo de módulo de la versión 12, puede instalar el paquete postgresql-server para instalar PostgresSQL 12 y todas sus dependencias:
sudo dnf install -y postgresql-server postgresql-contrib

#Paso 2: Crear un nuevo clúster de base de datos para PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo setsebool -P httpd_can_network_connect_db 1

#Paso 3: Usar roles y bases de datos de PostgreSQL
sudo -i -u postgres

#Paso 4: Crear usuarios
sudo -u postgres createuser app_dbeduvialwp
sudo -u postgres psql -c "create user dbeduvialwpuser1 with password 'explorauser1';"
# sudo -u postgres psql -c "create user dbeduvialwpuser2 with password 'explorauser2';"
sudo -u postgres psql -c "create database dbeduvialwp;"
sudo -u postgres psql -c "grant all privileges on database dbeduvialwp to dbeduvialwpuser1;"
# sudo -u postgres psql -c "grant all privileges on database dbeduvialwp to dbeduvialwpuser2;"
sudo -u postgres psql -c '\l'

sudo cp /home/vagrant/documents/vagrant_centos_node_nginx/configuration_files/var/lib/pgsql/data/* /var/lib/pgsql/data/
sudo systemctl restart postgresql.service

#[root@localhost wordpress]# cp /var/lib/pgsql/data/pg_hba.conf /home/vagrant/documents/vagrant_centos_node_nginx/config_files2/
#[root@localhost wordpress]# cp /var/lib/pgsql/data/postgresql.conf /home/vagrant/documents/vagrant_centos_node_nginx/config_files2/
#[root@localhost wordpress]# cp /etc/php.ini /home/vagrant/documents/vagrant_centos_node_nginx/config_files2

