# general azure variables
subscription=null
location=eastus2
application=sczurek
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
dbServerName=mysqldb-$application-$environment-$location
mysqlAdminLogin=mysqldbadmin
mysqlAdminPassword=mysqldbpassword
wordpressDBName=wordpressdb
wordpressDBUser=wpdbuser
wordpressDBPassword=wpdbpassword
# get local IP
adminSourceIP=`wget -O - v4.ident.me 2>/dev/null`

# open mySQL Server access temporarily to populate DB
az mysql server firewall-rule create --resource-group $resourceGroupName --server $dbServerName --name "AllowAll" --start-ip-address $adminSourceIP --end-ip-address $adminSourceIP
# create target wordpress DB here
mysql --verbose -h $dbServerName.mysql.database.azure.com -u$mysqlAdminLogin@$dbServerName -p$mysqlAdminPassword<<EOFMYSQL
DROP DATABASE $wordpressDBName;
CREATE DATABASE $wordpressDBName;
CREATE USER '$wordpressDBUser'@'%' IDENTIFIED BY '$wordpressDBPassword';
GRANT ALL PRIVILEGES ON $wordpressDBName . * TO '$wordpressDBUser'@'%';
FLUSH PRIVILEGES;
EOFMYSQL
# restore wordpress DB here
mysql --verbose -h $dbServerName.mysql.database.azure.com -u$mysqlAdminLogin@$dbServerName -p$mysqlAdminPassword $wordpressDBName < /home/psczurek/pocketcalculatorshow_com_01-may-2023.sql
# lock down mySQL Server
az mysql server firewall-rule delete --name AllowAll --resource-group $resourceGroupName --server-name $dbServerName -y