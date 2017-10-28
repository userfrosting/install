
#!/bin/bash
#Get the latest updates
sudo apt-get -y update

#Install Apache, PHP and MySQL
sudo apt-get -y install apache2

sudo apt-get -y install php7.0

sudo apt-get -y install php7.0-xml

sudo apt-get -y install php7.0-mbstring

sudo apt-get -y install php7.0-gd

sudo apt-get -y install php7.0-mysql

sudo apt-get -y install mysql-server --fix-missing

#Enable Apache extensions
sudo a2enmod rewrite

sudo phpenmod pdo_mysql

#Install Git and curl
sudo apt-get -y install git

sudo apt-get -y install curl

#Donwload and install node.js
cd ~
wget https://nodejs.org/dist/latest-v8.x/node-v8.8.1-linux-armv6l.tar.gz
sudo tar -xzf node-v8.8.1-linux-armv6l.tar.gz
node-v8.8.1-linux-armv6l/bin/node -v
cd node-v8.8.1-linux-armv6l/
sudo cp -R * /usr/local/
cd ~


#Donwload and install Composer
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1




#Databse setup
#Stop the MySQL service
sudo service mysql stop
#Create init file
sudo touch /etc/mysql/mysql-init
#Ask user to choose password for the root user
read -s -p "Choose a root password for MySQL: " rootpasswd
#Write commands to init file
sudo echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${rootpasswd}');" /etc/mysql/mysql-init
#Restart MySQL service
sudo service mysql restart
#Delete init file
sudo rm /etc/mysql/mysql-init
#Create database and name it userfrosting
sudo  mysql -uroot -p${rootpasswd} -e "CREATE DATABASE userfrosting /*\!40100 DEFAULT CHARACTER SET utf8 */;"
#Ask user to choose password for the user:"userfrosting"
read -s -p 'Choose a user password for MySQL user "userfrosting": ' userpasswd
#Create user "userfrosting" and set password chosesn by the user
sudo mysql -uroot -p${rootpasswd} -e "CREATE USER 'userfrosting'@'localhost' IDENTIFIED BY '${userpasswd}';"
#Give the user "userfrosting" all premissions <<== Need to give restricted premissions for security
sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON userfrosting.* TO 'userfrosting'@'localhost' IDENTIFIED BY '${userpasswd}';"
#Reload MySQL premissions
sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"




#Clone the main userfrosting repository to directory "userfrosting"
git clone https://github.com/userfrosting/UserFrosting.git userfrosting




#Main setup
#Gives bower necessary premissions to run without root
sudo chown -R $(whoami) .config

#Gets current directory
path=$(pwd)

#Appends the necessary config to the Apache conf file
echo -e "<Directory ${path}/userfrosting/public/>\n Options Indexes FollowSymLinks\n AllowOverride All\n Require all granted\n </Directory>" | sudo tee -a /etc/apache2/apache2.conf

#Finds the defualt directory path and replaces it with userfrosting
sudo sed -i -e "s#/var/www/html#${path}/userfrosting/public/#g" /etc/apache2/sites-enabled/000-default.conf

#Gives Apache write premissions to the necessary directories
sudo  chgrp www-data ${path}/userfrosting/app/logs
sudo  chmod g+rwxs ${path}/userfrosting/app/logs

sudo  chgrp www-data ${path}/userfrosting/app/cache
chmod g+rwxs ${path}/userfrosting/app/cache

sudo chgrp www-data ${path}/userfrosting/app/sessions
sudo chmod g+rwxs ${path}/userfrosting/app/sessions

#Change current directory to userfrosting
cd ./userfrosting

#Run composer and install PHP libaries
sudo composer install

#Run bakery to setup userfrosting
php bakery bake

#Restart the Apache servies when completed
sudo service apache2 restart
