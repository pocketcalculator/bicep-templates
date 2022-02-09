# general azure variables
subscription=null
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
dbServerName=mysqldb-$application-$environment-$location
mysqlAdminLogin=mysqldbadmin
mysqlAdminPassword=
wordpressDBName=wordpressdb
wordpressDBUser=wordpress
wordpressDBPassword=
localIP=`wget -O - v4.ident.me 2>/dev/null`

az mysql server update --resource-group $resourceGroupName --name $dbServerName --public Enabled
az mysql server firewall-rule create --resource-group $resourceGroupName --server $dbServerName --name "AllowAll" --start-ip-address $localIP --end-ip-address $localIP
mysql -h $dbServerName.mysql.database.azure.com -u$mysqlAdminLogin@$dbServerName -p$mysqlAdminPassword<<EOFMYSQL
CREATE DATABASE $wordpressDBName;
CREATE USER '$wordpressDBUser'@'%' IDENTIFIED BY '$wordpressDBPassword';
GRANT ALL PRIVILEGES ON $wordpressDBName . * TO '$wordpressDBUser'@'%';
FLUSH PRIVILEGES;
EOFMYSQL
az mysql server firewall-rule delete --name AllowAll --resource-group $resourceGroupName --server-name $dbServerName -y
az mysql server update --resource-group $resourceGroupName --name $dbServerName --public Disabled