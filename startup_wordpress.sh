#!/bin/sh
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
sudo cp /home/vagrant/documents/vagrant_centos_node_nginx/configuration_files/etc/nginx/nginx.conf /etc/nginx/nginx.conf 
sudo cp /home/vagrant/documents/vagrant_centos_node_nginx/configuration_files/etc/nginx/sites-available/wordpress /etc/nginx/sites-available/wordpress
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
sudo sed -i 's/database_name_here/dbeduvialwp/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/username_here/dbeduvialwpuser1/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/password_here/explorauser1/g' /var/www/wordpress/wp-config.php

echo "<------>Editing wordpress folder permissions"
sudo chown nginx:nginx /var/www/wordpress
sudo chmod -R 775 /var/www/wordpress 
sudo chcon -t httpd_sys_content_t /var/www/wordpress -R
sudo chcon -t httpd_sys_rw_content_t /var/www/wordpress -R


# sudo curl localhost/info.php
echo "<------>PLEASE VISIT localhost:8080/info.php on the host machine"


#Install wp-cli https://www.linode.com/docs/websites/cms/wp-cli/how-to-install-wordpress-using-wp-cli-on-centos-7/
# curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# chmod +x wp-cli.phar
# sudo mv wp-cli.phar /usr/local/bin/wp
# #
# ##Allow bash completion
# sudo yum -y install -y wget
# cd ~
# wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash
# sudo echo source /home/$USER/wp-completion.bash >> ~/.bashrc
# sudo source ~/.bashrc
# sudo echo autoload bashcompinit >> ~/.zshrc
# sudo echo bashcompinit >> ~/.zshrc
# sudo echo source /home/$USER/wp-completion.bash >> ~/.zshrc
# source ~/.zshrc