#!/bin/bash

# install php, mysql

apt-get update
apt-get install -y python-software-properties
add-apt-repository ppa:ondrej/php5-oldstable
apt-get update
apt-get install -y php5 php5-mysql php5-cli php5-sqlite php5-mcrypt curl php5-xsl make build-essential sqlite3 libsqlite3-dev git
export DEBIAN_FRONTEND=noninteractive
apt-get install -q -y mysql-server-5.5

# php, mysql, apache configurations

cp -f /vagrant/php.ini /etc/php.ini
cp -f /vagrant/my.cnf /etc/mysql/my.cnf
cp -f /vagrant/.htaccess /var/www/phpci/public
cp -f /vagrant/vhost.conf /etc/apache2/sites-available/localhost
ln -s /etc/apache2/sites-available/localhost /etc/apache2/sites-enabled/localhost
ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.conf
rm -f /etc/apache2/sites-available/default
rm -f /etc/apache2/sites-enabled/000-default
# project installation

echo "CREATE DATABASE phpci" | mysql -u root
echo "create user 'root'@'10.0.2.2' identified by ''" | mysql -u root
echo "grant all privileges on *.* to 'root'@'10.0.2.2' with grant option" | mysql -u root
echo "flush privileges" | mysql -u root
cd /var/www/phpci
cp -f /vagrant/config.yml PHPCI/
curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin
mv /bin/composer.phar /bin/composer
composer install --dev --prefer-dist
service mysql restart
service apache2 restart
vendor/bin/phinx migrate -c phinx.php
# create admin user
echo "INSERT INTO phpci.user (email,name,is_admin,hash) VALUES ('root@localhost','PHPCI Admin',1,'\$2y\$10\$of0hBsXYe7NNPFkaVtTwd.Vuc2UAtFb.mLiY7aYl.OcptsztKrn42')" | mysql -u root
# configure global path

echo 'export PATH=$PATH:/var/www/phpci/vendor/bin' > /home/vagrant/.bash_profile
