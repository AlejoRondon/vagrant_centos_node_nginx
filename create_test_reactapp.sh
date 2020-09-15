#!/bin/sh
#https://www.linode.com/docs/development/nodejs/how-to-install-nodejs-and-nginx-on-centos-8/
#https://medium.com/@timmykko/deploying-create-react-app-with-nginx-and-ubuntu-e6fe83c5e9e7
#https://medium.com/@jgefroh/a-guide-to-using-nginx-for-static-websites-d96a9d034940
echo "<¬¬¬¬¬>CREATING TESTING REACT APP<¬¬¬¬¬>"
sudo mkdir /home/vagrant/documents
cd /home/vagrant/documents
sudo npx create-react-app testapp
cd testapp
sudo yarn add serve
#https://return2.net/deploy-react-app-build-to-any-subdirectory/
#https://stackoverflow.com/questions/43011207/using-homepage-in-package-json-without-messing-up-paths-for-localhost
sudo sed -i 's/"private": true,/"private": true,\n"homepage": ".",/g' package.json
#building react app
sudo yarn build 
# copying folder
sudo cp -r build/ /var/www/wordpress/   
# renaming "build" folder on /var/www/ to "testapp"                                                  
sudo mv /var/www/wordpress/build /var/www/wordpress/testapp.com
# yarn serve -s build 
sudo chown nginx:nginx /var/www/wordpress/testapp.com
sudo chmod -R 775 /var/www/wordpress/testapp.com 
sudo chcon -t httpd_sys_content_t /var/www/wordpress/testapp.com -R
sudo chcon -t httpd_sys_rw_content_t /var/www/wordpress/testapp.com -R

