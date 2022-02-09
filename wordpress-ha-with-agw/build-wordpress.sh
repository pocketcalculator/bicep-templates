#!/bin/bash

# general azure variables
subscription=null
location=eastus2
application=application
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$application-$environment-$location
vnetCIDRPrefix=10.0
# key vault variables
kvResourceGroup=
kvName=
# linuux vm variables
adminUsername=azureuser
# mysql server variables
mySqlHwFamily=Gen5
mySqlHwName=GP_Gen5_2
mySqlvCoreCapacity=2
mySqlHwTier=GeneralPurpose
# Private Endpoint supported only on General Purpose, settings below for low cost db
# mySqlHwName=B_Gen5_1
# mySqlvCoreCapacity=1
# mySqlHwTier=Basic
mySqlAdminLogin=mysqldbadmin
# wordpress db variables
wordpressDBName=wordpressdb
wordpressDBUser=wordpress
wordpressDBPassword=
wordpressTablePrefix=wp_
wordpressDomainName=wordpress.com
wordpressDocRoot=/var/www/$wordpressDomainName/public_html
# storage variables
storageSuffix="$application$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 5)"
nfsStorageAccountName="nfs$storageSuffix"
blobStorageAccountName="blob$storageSuffix"
nfsShareName=nfsshare

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vnetCIDRPrefix = $vnetCIDRPrefix
echo kvResourceGroup = $kvResourceGroup
echo kvName = $kvName
echo adminUsername = $adminUsername
echo mySqlHwFamily = $mySqlHwFamily
echo mySqlHwName = $mySqlHwName
echo mySqlHwTier = $mySqlHwTier
echo mySqlvCoreCapacity = $mySqlvCoreCapacity
echo mySqlAdminLogin = $mySqlAdminLogin
echo wordpressDBName = $wordpressDBName
echo wordpressDBUser = $wordpressDBUser
echo wordpressDBPassword = $wordpressDBPassword
echo wordpressTablePrefix = $wordpressTablePrefix
echo wordpressDomainName = $wordpressDomainName
echo wordpressDocRoot = $wordpressDocRoot
echo nfsStorageAccountName = $nfsStorageAccountName
echo blobStorageAccountName = $blobStorageAccountName
echo nfsShareName = $nfsShareName

cat << EOF > ./compute/cloudInit.txt
#cloud-config
package_upgrade: true
packages:
  - binutils
  - curl
  - mysql-client
  - sysstat
  - collectd
  - collectd-utils
  - ghostscript
  - apache2
  - openssl
  - php
  - libapache2-mod-php
  - php-bcmath
  - php-curl
  - php-imagick
  - php-json
  - php-gd
  - php-intl
  - php-mbstring
  - php-soap
  - php-xml
  - php-xmlrpc
  - php-zip
  - php-fpm
  - php-mysql
  - nfs-common

write_files:

- path: /tmp/phpinfo.php
  content: |
    <?php phpinfo(); ?>

- path: /tmp/heartbeat.php
  content: |
    <html>
        <body>
            <p>
                site is running.
            </p>
            <?php echo gethostname(); ?>
        </body>
    </html>

- path: /tmp/wp-config.php
  content: |
      <?php
      define('DB_NAME', '$wordpressDBName');
      define('DB_USER', '$wordpressDBUser@mysqldb-$application-$environment-$location');
      define('DB_PASSWORD', '$wordpressDBPassword');
      define('DB_HOST', 'mysqldb-$application-$environment-$location.mysql.database.azure.com');
      define( 'DB_CHARSET', 'utf8' );
      define( 'DB_COLLATE', '' );
      define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);
      define('FORCE_SSL_ADMIN', true);
      
      // in some setups HTTP_X_FORWARDED_PROTO might contain 
      // a comma-separated list e.g. http,https
      // so check for https existence
      // if ( strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https' ) !== false) $_SERVER['HTTPS']='on';
      \$table_prefix = '$wordpressTablePrefix';

      if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
      }

      require_once ABSPATH . 'wp-settings.php';
       ?>

- path: /tmp/$wordpressDomainName.conf
  content: |
    <VirtualHost *:80>

      ServerAdmin webmaster@$wordpressDomainName
      ServerName $wordpressDomainName
      ServerAlias www.$wordpressDomainName
      DocumentRoot $wordpressDocRoot

      ErrorLog /var/log/apache2/$wordpressDomainName-error.log
      CustomLog /var/log/apache2/$wordpressDomainName-access.log combined

    </VirtualHost>

runcmd:
  - cd /tmp; wget -c https://dev.mysql.com/get/mysql-community-client_8.0.26-1ubuntu20.04_amd64.deb
  - cd /tmp; wget -c https://dev.mysql.com/get/mysql-community-client-core_8.0.26-1ubuntu20.04_amd64.deb            
  - cd /tmp; wget -c https://dev.mysql.com/get/mysql-community-client-plugins_8.0.26-1ubuntu20.04_amd64.deb
  - cd /tmp; wget -c https://dev.mysql.com/get/mysql-common_8.0.26-1ubuntu20.04_amd64.deb
  - cd /tmp; sudo apt install --yes --no-install-recommends ./mysql-community-client_8.0.26-1ubuntu20.04_amd64.deb ./mysql-community-client-core_8.0.26-1ubuntu20.04_amd64.deb ./mysql-community-client-plugins_8.0.26-1ubuntu20.04_amd64.deb ./mysql-common_8.0.26-1ubuntu20.04_amd64.deb
  - mkdir -p $wordpressDocRoot
  - mount -t nfs $nfsStorageAccountName.file.core.windows.net:/$nfsStorageAccountName/nfsshare $wordpressDocRoot -o vers=4,minorversion=1,sec=sys
  - /usr/bin/wget http://wordpress.org/latest.tar.gz -P $wordpressDocRoot
  - /usr/bin/wget https://cacerts.digicert.com/BaltimoreCyberTrustRoot.crt.pem -P /usr/local/share/ca-certificates
  - /usr/bin/openssl x509 -outform der -in /usr/local/share/ca-certificates/BaltimoreCyberTrustRoot.crt.pem -out /usr/local/share/ca-certificates/certificate.crt
  - /usr/sbin/update-ca-certificates
  - tar xzvf $wordpressDocRoot/latest.tar.gz -C $wordpressDocRoot --strip-components=1
  - cp /tmp/phpinfo.php $wordpressDocRoot/phpinfo.php
  - cp /tmp/heartbeat.php $wordpressDocRoot/heartbeat.php
  - cp /tmp/wp-config.php $wordpressDocRoot/wp-config.php
  - cp /tmp/$wordpressDomainName.conf  /etc/apache2/sites-available/$wordpressDomainName.conf
  - chown -R www-data:www-data $wordpressDocRoot
  - a2ensite $wordpressDomainName
  - a2dissite 000-default.conf
  - systemctl restart apache2

EOF

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./wordpress.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"kvResourceGroup=$kvResourceGroup" \
		"kvName=$kvName" \
		"adminUsername=$adminUsername" \
		"mySqlHwFamily=$mySqlHwFamily" \
		"mySqlHwName=$mySqlHwName" \
		"mySqlHwTier=$mySqlHwTier" \
		"mySqlvCoreCapacity=$mySqlvCoreCapacity" \
		"mySqlAdminLogin=$mySqlAdminLogin" \
    "nfsStorageAccountName=$nfsStorageAccountName" \
    "blobStorageAccountName=$blobStorageAccountName" \
    "nfsShareName=$nfsShareName"
echo "Deployment for ${environment} ${application} environment is complete."