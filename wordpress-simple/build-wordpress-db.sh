# set the variables below, then upload this script to the target machine and run it as root
# this script will create a wordpress database and user
# and grant all privileges to the user on the database

mysqlAdminLogin=mysqldbadmin
mysqlAdminPassword=mysqldbpassword
wordpressDBName=wordpressdb
wordpressDBUser=wpdbuser
wordpressDBPassword=wpdbpassword

mysql -u root <<EOFMYSQL
CREATE DATABASE $wordpressDBName;
CREATE USER '$wordpressDBUser'@'%' IDENTIFIED BY '$wordpressDBPassword';
GRANT ALL PRIVILEGES ON $wordpressDBName . * TO '$wordpressDBUser'@'%';
FLUSH PRIVILEGES;
EOFMYSQL