#!/bin/bash
##########################CONFIG##########################
#MySQL
#MySQL root user password
MYSQL_ROOT_PASSWORD="root"
#MySQL user that will connect to the database
MYSQL_USER_NAME="userfrosting"
#MySQL user password
MYSQL_USER_PASSWORD="password"
#MySQL database name
MYSQL_DATABASE_NAME="userfrosting"

#UserFrosting
#Root userfrosting user details
UF_ROOT_USER_NAME="admin"
UF_ROOT_FIRST_NAME="Pro"
UF_ROOT_LAST_NAME="Nub"
UF_ROOT_USER_EMAIL="nub@pro.com"
UF_ROOT_USER_PASSWORD="admin"
#Install directory
UF_INSTALL_DIR="/userfrosting"

#Other settings
#Best left to defualt
#MySQL user database premissions
MYSQL_USER_PRIVILEGES="SELECT, INSERT, DELETE"
MYSQL_USER_HOST="localhost"
##########################END##########################



#Add the PHP repository to Ubuntu
sudo apt-add-repository -y ppa:ondrej/php

#Get the latest updates
sudo apt-get -y update

#Install Apache, PHP and MySQL
sudo apt-get -y install apache2

sudo apt-get -y install php7.0

sudo apt-get -y install php7.0-xml

sudo apt-get -y install php7.0-mbstring

sudo apt-get -y install php7.0-gd

sudo apt-get -y install php7.0-mysql

echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections

sudo apt-get -y install mysql-server

#Enable Apache extensions
sudo a2enmod rewrite

sudo phpenmod pdo_mysql

#Install Git and curl
sudo apt-get -y install git

sudo apt-get -y install curl

#Donwload and install node.js
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

sudo apt-get -y install -y nodejs

sudo apt-get -y install -y build-essential

#Donwload and install Composer
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer




#Databse setup
#Create database and name it userfrosting
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${MYSQL_DATABASE_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
#Create user "userfrosting" and set password chosesn by the user
mysql -uroot -p${rootpasswd} -e "CREATE USER '${MYSQL_USER_NAME}'@'${MYSQL_USER_HOST}' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"
#Give the user "userfrosting" all premissions
mysql -uroot -p${rootpasswd} -e "GRANT ${MYSQL_USER_PRIVILEGES} ON ${MYSQL_DATABASE_NAME}.* TO '${MYSQL_USER_NAME}'@'${MYSQL_USER_HOST}' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"
#Reload MySQL premissions
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"




#Clone the main userfrosting repository to directory "userfrosting"
git clone https://github.com/userfrosting/UserFrosting.git userfrosting




#Main setup
#Gives bower necessary premissions to run without root
sudo chown -R $(whoami) .config


#Appends the necessary config to the Apache conf file
echo -e "<Directory ${UF_INSTALL_DIR}/public/>\n Options Indexes FollowSymLinks\n AllowOverride All\n Require all granted\n </Directory>" | sudo tee -a /etc/apache2/apache2.conf

#Finds the defualt directory path and replaces it with userfrosting
sudo sed -i -e "s#/var/www/html#${UF_INSTALL_DIR}/public/#g" /etc/apache2/sites-enabled/000-default.conf

#Gives Apache write premissions to the necessary directories
sudo  chgrp www-data ${UF_INSTALL_DIR}/app/logs
sudo  chmod g+rwxs ${UF_INSTALL_DIR}/app/logs

sudo  chgrp www-data ${UF_INSTALL_DIR}/app/cache
chmod g+rwxs ${UF_INSTALL_DIR}/app/cache

sudo chgrp www-data ${UF_INSTALL_DIR}/app/sessions
sudo chmod g+rwxs ${UF_INSTALL_DIR}/app/sessions

#Change current directory to userfrosting
cd .${UF_INSTALL_DIR}

#Run composer and install PHP libaries
sudo composer install

#Run asset builder
php bakery build-assets
#Run migrations
php bakery migrate

#Bakery setup
echo -e "${MYSQL_USER_HOST}\3306\${MYSQL_DATABASE_NAME}\${MYSQL_USER_NAME}\${MYSQL_USER_PASSWORD}\ \ \ " | php bakery setup

echo -e "${UF_ROOT_USER_NAME}\${UF_ROOT_USER_EMAIL}\${UF_ROOT_FIRST_NAME}\${UF_ROOT_LAST_NAME}\${UF_ROOT_USER_PASSWORD}" | php bakery create-admin


#Restart the Apache servies when completed
sudo service apache2 restart
