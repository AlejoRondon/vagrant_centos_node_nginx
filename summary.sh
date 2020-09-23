echo "<*****>Installing Git in RHEL8 & Cloning VM Repo<*****>"
echo "<+++++>Installing Git"
sudo dnf install -y git
sudo mkdir /home/cammanager/documents
sudo cd /home/cammanager/documents
echo "<+++++>Installing cloning repo. Remember change PARQUE_EXPLORA_DEVELOPER_USER for your user"
sudo git clone --recurse-submodules -j8 https://PARQUE_EXPLORA_DEVELOPER_USER@bitbucket.org/parqueexploradevelopers/vagrant_centos_node_nginx.git
sudo curl -o output.zip https://github.com/AlejoRondon/vagrant_centos_node_nginx/archive/master.zip
echo "<+++++>Checking Git installation"
sudo git --version

echo "<*****>Installing Nginx<*****>"
sudo dnf -y update
sudo dnf install -y nginx tmux tar
echo "<+++++>Starting Nginx"
sudo systemctl start nginx
echo "<+++++>Enablig Nginx"
sudo systemctl enable nginx
echo "<+++++>Checking Nginx response"
curl http://localhost/
echo "<+++++>Creating Nginx directories"
sudo mkdir -p /etc/nginx/{sites-available,sites-enabled}
sudo mkdir -p /var/www
echo "<+++++>Checking status Nginx"
sudo systemctl status nginx

echo "<*****>Setting firewall<*****>"
#"https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8-es"
sudo systemctl enable firewalld
sudo systemctl start firewalld

echo "<+++++>Enabling service ports>"
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --permanent --zone=public --add-service=postgresql
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
sudo firewall-cmd --permanent --zone=public --add-service=dhcpv6-client
echo "<+++++>Enabling tcp ports>"
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --zone=public --permanent --add-port=20-22/tcp
sudo firewall-cmd --zone=public --permanent --add-port=3000-3010/tcp
sudo firewall-cmd --zone=public --permanent --add-port=5000-5010/tcp
sudo firewall-cmd --zone=public --permanent --add-port=9000-9010/tcp
sudo firewall-cmd --zone=public --permanent --add-port=30000-3010/tcp
echo "<+++++>Checking firewall state>"
sudo firewall-cmd --state
echo "<+++++>Reloading firewalld"
sudo firewall-cmd --reload
echo "<+++++>Checking active zones>"
sudo firewall-cmd --get-active-zones
echo "<+++++>Checking operating zone>"
sudo firewall-cmd --get-default-zone
# echo "<+++++>Listing opened ports"
# firewall-cmd --zone=public --list-ports --permanent
# echo "<+++++>Listing opened services"
# firewall-cmd --zone=public --list-services --permanent
echo "<+++++>Listing opened ports & Listing opened services>"
sudo firewall-cmd --list-all
echo "<+++++>Checking status firewalld>"
systemctl status firewalld.service


echo "<*****>Installing NANO editor<*****>"
sudo yum install -y nano
echo "<*****>Installing WGET package manager<*****>"
sudo yum install -y wget

echo "<*****>Installing PHP<*****>"
#PHP repo configuration
#https://linuxconfig.org/redhat-8-epel-install-guide
echo "<+++++>Configuring repositories to enable php v7.4>"
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo rpm -ql epel-release
sudo dnf repolist -v
sudo dnf repository-packages epel list
echo "<+++++>Installing php>"
sudo dnf module list php -y
sudo dnf module enable php:remi-7.4 -y
sudo dnf install -y php php-cli php-common
sudo dnf install -y php-mysql
sudo yum install -y php-pgsql php-pdo_pgsql
echo "<+++++>Checking php version>"
php -v
echo "<+++++>Starting php>"
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl restart httpd
echo "<+++++>Updating php configuration files"
sudo cp /home/cammanager/documents/vagrant_centos_node_nginx/configuration_files/etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf
sudo systemctl restart php-fpm
echo "<+++++>Checking php status>"
sudo systemctl status php-fpm

echo "<*****>Configuring database(Postgres) connection<*****>"
setsebool httpd_can_network_connect=1 httpd_can_network_connect_db=1

echo "<*****>"
echo "<------>STARTING UP WORDPRESS<------>"
echo "<------>https://code.tutsplus.com/articles/download-and-install-wordpress-via-the-shell-over-ssh--wp-24403"

sudo cd /var/www/
echo "<------>Downloading compressed Wordpress file"
sudo wget http://wordpress.org/latest.tar.gz
echo "<------>Uncompressing file"
sudo tar xfz latest.tar.gz
# sudo cp -r wordpress/ /var/www/  
echo "<------>Removing compressed file"
sudo rm -f latest.tar.gz
echo "<------>Creating info.php"
cd /var/www/wordpress
sudo bash -c 'echo "<?php phpinfo(); ?>" > info.php'
sudo chown root:root /var/www/wordpress/info.php
echo "<------>Updating wordpress file permissions"
sudo chown -R root /var/www/wordpress
sudo chgrp -R root /var/www/wordpress
sudo chown nginx:nginx /var/www/wordpress
sudo chmod -R 775 /var/www/wordpress 
sudo chcon -t httpd_sys_content_t /var/www/wordpress -R
sudo chcon -t httpd_sys_rw_content_t /var/www/wordpress -R
echo "<------>Updating nginx configuration files"
sudo cp /home/cammanager/documents/vagrant_centos_node_nginx/configuration_files/etc/nginx/nginx.conf /etc/nginx/nginx.conf 
sudo cp /home/cammanager/documents/vagrant_centos_node_nginx/configuration_files/etc/nginx/sites-available/wordpress /etc/nginx/sites-available/wordpress
echo "<------>Creating symbolic link to /etc/nginx/sites-available/wordpress"
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
echo "<------>Restarting NGINX & PHP-FPM services"
sudo systemctl restart php-fpm.service
sudo systemctl restart nginx.service

echo "<------>Download and configure the Fork version of WP4PG in your WordPress directory"
#https://medium.com/@shoaibhassan_/install-wordpress-with-postgresql-using-apache-in-5-min-a26078d496fb
cd /var/www/wordpress/wp-content/
sudo git clone https://github.com/kevinoid/postgresql-for-wordpress.git
sudo mv postgresql-for-wordpress/pg4wp pg4wp
sudo rm -rf postgresql-for-wordpress
sudo cp pg4wp/db.php db.php

echo "<------>Creating and editing wp-config.php"
cd /var/www/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/DATABASE_NAME/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/username_here/USERNAME/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/password_here/PASSWORD/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/localhost/HOST_IP/g' /var/www/wordpress/wp-config.php

echo "<------>Editing wordpress folder permissions"
sudo chown nginx:nginx /var/www/wordpress
sudo chmod -R 775 /var/www/wordpress 
sudo chcon -t httpd_sys_content_t /var/www/wordpress -R
sudo chcon -t httpd_sys_rw_content_t /var/www/wordpress -R
