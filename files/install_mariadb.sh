#!/bin/bash
sudo yum -y install mariadb mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

PASS="ThoughtWorks"

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE wikidatabase;
CREATE USER 'wiki'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON wikidatabse.* TO 'wikidatabase'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username:   wikii"
echo "Password:   ThoughtWorks"

