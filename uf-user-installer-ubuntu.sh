
#!/bin/bash

sudo apt-add-repository -y ppa:ondrej/php

sudo apt-get update

sudo apt-get -y install apache2

sudo apt-get -y install php7.0

sudo apt-get -y install php7.0-xml

sudo apt-get -y install php7.0-mbstring

sudo apt-get -y install php7.0-gd

sudo apt-get -y install php7.0-mysql

sudo apt-get -y install mysql-server

sudo a2enmod rewrite

sudo apt-get -y install git

sudo apt-get -y install curl

sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

sudo apt-get -y install -y nodejs

sudo apt-get -y install -y build-essential

sudo phpenmod pdo_mysql

sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


read -s -p "Type the password you just entered (MySQL): " rootpasswd
mysql -uroot -p${rootpasswd} -e "CREATE DATABASE userfrosting /*\!40100 DEFAULT CHARACTER SET utf8 */;"
read -s -p "Type a user password (MySQL): " PASSWDDB
mysql -uroot -p${rootpasswd} -e "CREATE USER 'userfrosting'@'localhost' IDENTIFIED BY '${PASSWDDB}';"
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON userfrosting.* TO 'userfrosting'@'localhost' IDENTIFIED BY '${PASSWDDB}';"
mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"




git clone https://github.com/userfrosting/UserFrosting.git userfrosting

sudo chown -R $(whoami) .config



path=$(pwd)


echo -e "<Directory ${path}/userfrosting/public/>\n Options Indexes FollowSymLinks\n AllowOverride All\n Require all granted\n </Directory>" | sudo tee -a /etc/apache2/apache2.conf

sudo sed -i -e "s#/var/www/html#${path}/userfrosting/public/#g" /etc/apache2/sites-enabled/000-default.conf

sudo  chgrp www-data ${path}/userfrosting/app/logs
sudo  chmod g+rwxs ${path}/userfrosting/app/logs

sudo  chgrp www-data ${path}/userfrosting/app/cache
chmod g+rwxs ${path}/userfrosting/app/cache

sudo chgrp www-data ${path}/userfrosting/app/sessions
sudo chmod g+rwxs ${path}/userfrosting/app/sessions

cd ./userfrosting

sudo composer install

php bakery bake

sudo service apache2 restart
