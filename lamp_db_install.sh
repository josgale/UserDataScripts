#!/bin/bash

# update, install lamp and dependancys 
yum update -y
yum install -y install httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json

# set timezone
timedatectl set-timezone America/New_york

# start and enable httpd mariadb
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

# set php.info page
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# create db for wiki
mysql -u user -p
echo "CREATE DATABASE wiki_database;"
echo "CREATE USER 'wiki_user'@'localhost' IDENTIFIED BY 'PASSWORD';"
echo "GRANT ALL PRIVILEGES ON wiki_database.* TO 'wiki_user'@'localhost';"
echo "FLUSH PRIVILEGES;"
echo "exit"

# install mediawiki
wget https://releases.wikimedia.org/mediawiki/1.24/mediawiki-1.24.2.tar.gz
tar -zxpvf mediawiki-1.24.2.tar.gz
mv mediawiki-1.24.2 /var/www/html/mediawiki
chown -R apache:apache /var/www/html/mediawiki/
chmod 755 /var/www/html/mediawiki/

# install firewall and open port 80
yum install -y firewalld
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload

# enable tls
yum install -y mod_ssl
cd /etc/pki/tls/certs
sudo ./make-dummy-cert localhost.crt
sed -i '/SSLCertificateKeyFile/s/^/#/g' /etc/httpd/conf.d/ssl.conf
sudo systemctl restart httpd