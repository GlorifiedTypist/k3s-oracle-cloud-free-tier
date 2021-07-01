#!/bin/bash

yum update -y oracle-cloud-agent
yum install -y mariadb-server.x86_64

systemctl stop oracle-cloud-agent

systemctl enable mariadb
systemctl start mariadb

cat > mysql_secure_installation.sql << EOF
UPDATE mysql.user SET Password=PASSWORD('root-${password}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
GRANT ALL ON *.* to k3s@'10.0.0.0/255.0.0.0' IDENTIFIED BY '${password}';
FLUSH PRIVILEGES;
EOF

mysql -uroot < mysql_secure_installation.sql
rm mysql_secure_installation.sql

firewall-cmd --permanent --add-port=3306/tcp

systemctl start oracle-cloud-agent
