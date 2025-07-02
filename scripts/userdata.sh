#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd wget unzip
yum install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install -y mysql-community-server

systemctl enable httpd
systemctl start httpd
systemctl enable mysqld
systemctl start mysqld