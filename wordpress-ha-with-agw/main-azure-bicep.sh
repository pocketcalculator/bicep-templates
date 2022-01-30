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
# mysql variables
mySqlHwFamily=Gen5
mySqlHwName=GP_Gen5_2
mySqlvCoreCapacity=2
mySqlHwTier=GeneralPurpose
# Private Endpoint supported only on General Purpose, settings below for low cost db
# mySqlHwName=B_Gen5_1
# mySqlvCoreCapacity=1
# mySqlHwTier=Basic
mySqlAdminLogin=mysqldbadmin
# storage variables

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

cat << EOF > ./compute/cloudInit.txt
#cloud-config
package_upgrade: true
packages:
  - binutils
  - curl
  - sysstat
  - collectd
  - collectd-utils
  - ghostscript
  - apache2
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
    <?php 
    phpinfo (); 
    ?>

- path: /tmp/heartbeat.php
  content: |
    <html>
        <body>
            <p>
                site is running.
            </p>
            <?php 
				echo gethostname(); 
			?>
        </body>
    </html>

- path: /tmp/wp-config.php
  content: |
      <?php
      define('DB_NAME', 'mysqldb-$application-$environment-$location');
      define('DB_USER', '$mySqlAdminLogin');
      define('DB_PASSWORD', '$dbpassword');
      define('DB_HOST', 'mysqldb-$application-$environment-$location.mysql.database.azure.com');
      \$table_prefix = 'wp_';
      if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
      }
      require_once ABSPATH . 'wp-settings.php';
      ?>


- path: /tmp/wordpress.conf
  content: |
   server {
      listen 80;
      server_name _;
      root /data/nfs/wordpress;

      index index.html index.htm index.php;

      location / {
          try_files \$uri \$uri/ /index.php\$is_args\$args;
      }

      location ~ \.php$ {
          include snippets/fastcgi-php.conf;
          fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
      }

      location = /favicon.ico { log_not_found off; access_log off; }
      location = /robots.txt { log_not_found off; access_log off; allow all; }
      location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
      }

      location ~ /\.ht {
          deny all;
      }

   }

runcmd: 
  - mkdir -p /data/nfs/wordpress
  - mount -t nfs nfs-$application-$environment-$location.file.core.windows.net:/nfs-$application-$environment/nfsshare /data/nfs -o vers=4,minorversion=1,sec=sys
  - wget http://wordpress.org/latest.tar.gz -P /data/nfs/wordpress
  - tar xzvf /data/nfs/wordpress/latest.tar.gz -C /data/nfs/wordpress --strip-components=1
  - cp /tmp/phpinfo.php /var/www/html
  - cp /tmp/heartbeat.php /var/www/html
  - cp /tmp/wp-config.php /data/nfs/wordpress/wp-config.php
  - cp /tmp/wordpress.conf  /etc/nginx/conf.d/wordpress.conf
  - chown -R www-data:www-data /data/nfs/wordpress
EOF

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./main.bicep \
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
		"mySqlAdminLogin=$mySqlAdminLogin"	
echo "Deployment for ${environment} ${application} environment is complete."