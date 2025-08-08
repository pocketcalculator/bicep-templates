#!/bin/bash

# general azure variables
subscription=null
location=eastus
applicationName=docker
applicationSuffix=$(cat /dev/urandom | tr -cd 'a-z0-9' | head -c 4)
application=${applicationName}${applicationSuffix}
environment=dev
owner=pocketcalculatorshow@gmail.com
resourceGroupName=rg-$applicationName-$environment-$location
# network variables
vnetCIDRPrefix=10.10
adminSourceIP=`wget -O - v4.ident.me 2>/dev/null`
# key vault variables
kvResourceGroup=rg-keyvault-prod-eastus2
kvName=kv-keyvault-prod-eastus2
# linuux vm variables
adminUsername=azureuser
# wordpress db variables
wordpressDBName=wordpressdb
wordpressDBUser=wpdbuser
wordpressDBPassword=wpdbpassword
wordpressTablePrefix=wp_
wordpressDomainName=wordpressdomain.com
wordpressDocRoot=/var/www/$wordpressDomainName/public_html
# storage variables
backupBlobStorageAccountName="bkup$application"
backupBlobContainerName="backup"

echo subscription = $subscription
echo location = $location
echo application = $application
echo environment = $environment
echo owner = $owner
echo resourceGroupName = $resourceGroupName
echo vnetCIDRPrefix = $vnetCIDRPrefix
echo adminSourceIP = $adminSourceIP
echo kvResourceGroup = $kvResourceGroup
echo kvName = $kvName
echo adminUsername = $adminUsername
echo wordpressDBName = $wordpressDBName
echo wordpressDBUser = $wordpressDBUser
echo wordpressDBPassword = $wordpressDBPassword
echo wordpressTablePrefix = $wordpressTablePrefix
echo wordpressDomainName = $wordpressDomainName
echo wordpressDocRoot = $wordpressDocRoot
echo backupBlobStorageAccountName = $backupBlobStorageAccountName
echo backupBlobContainerName = $backupBlobContainerName

cat << EOF > ./compute/cloudInit.txt
#cloud-config
package_upgrade: true
packages:
  - binutils
  - curl
  - mysql-server
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
  - certbot
  - python3-certbot-apache
  - python3
  - python-is-python3
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

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
      define('DB_USER', '$wordpressDBUser');
      define('DB_PASSWORD', '$wordpressDBPassword');
      define('DB_HOST', 'localhost');
      define( 'DB_CHARSET', 'utf8' );
      define( 'DB_COLLATE', '' );
      define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);
      define('FORCE_SSL_ADMIN', true);
      
      // in some setups HTTP_X_FORWARDED_PROTO might contain 
      // a comma-separated list e.g. http,https
      // so check for https existence
      // if ( strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https' ) !== false) 
      //   $_SERVER['HTTPS']='on';
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
      LogLevel warn
      ErrorLog /var/log/apache2/$wordpressDomainName-error.log
      CustomLog /var/log/apache2/$wordpressDomainName-access.log combined
      <Directory $wordpressDocRoot>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php index.html
        Require all granted
      </Directory>
      <Directory $wordpressDocRoot/wp-content>
        Options FollowSymLinks
        Require all granted
      </Directory>
    </VirtualHost>

runcmd:
  # Docker installation steps
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt update
  - apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  - systemctl start docker
  - systemctl enable docker
  - usermod -aG docker $adminUsername
  # WordPress and application setup
  - mkdir -p $wordpressDocRoot
  - /usr/bin/wget https://cacerts.digicert.com/BaltimoreCyberTrustRoot.crt.pem -P /usr/local/share/ca-certificates
  - /usr/bin/openssl x509 -outform der -in /usr/local/share/ca-certificates/BaltimoreCyberTrustRoot.crt.pem -out /usr/local/share/ca-certificates/certificate.crt
  - /usr/sbin/update-ca-certificates
  - /usr/bin/wget http://wordpress.org/latest.tar.gz -P $wordpressDocRoot
  - tar xzvf $wordpressDocRoot/latest.tar.gz -C $wordpressDocRoot --strip-components=1
  - cd /tmp; /usr/bin/curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  - chmod +x /tmp/wp-cli.phar; mv /tmp/wp-cli.phar /usr/bin/wp
  - cd /tmp; /usr/bin/wget https://azcopyvnext.azureedge.net/releases/release-10.30.0-20241018/azcopy_linux_amd64_10.30.0.tar.gz
  - cd /tmp; tar zxvf azcopy_linux_amd64_10.30.0.tar.gz
  - cp /tmp/azcopy_linux_amd64_10.30.0/azcopy /usr/bin; chmod 755 /usr/bin/azcopy
  - cd /tmp; /usr/bin/curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  - cp /tmp/phpinfo.php $wordpressDocRoot/phpinfo.php
  - cp /tmp/heartbeat.php $wordpressDocRoot/heartbeat.php
  - cp /tmp/wp-config.php $wordpressDocRoot/wp-config.php
  - cp /tmp/$wordpressDomainName.conf  /etc/apache2/sites-available/$wordpressDomainName.conf
  - chown -R www-data:www-data $wordpressDocRoot
  - a2ensite $wordpressDomainName
  - a2enmod rewrite
  - a2enmod headers
  - a2dissite 000-default.conf
  - systemctl reload apache2
EOF

echo "Creating deployment for ${environment} ${application} environment..."
az deployment group create \
	--resource-group $resourceGroupName \
	--name $application-deployment \
	--template-file ./docker.bicep \
	--parameters \
		"application=$application" \
		"environment=$environment" \
		"kvResourceGroup=$kvResourceGroup" \
		"kvName=$kvName" \
		"adminUsername=$adminUsername" \
    "backupBlobStorageAccountName=$backupBlobStorageAccountName" \
    "backupBlobContainerName=$backupBlobContainerName" \
    "adminSourceIP=$adminSourceIP" \
    "vnetCIDRPrefix=$vnetCIDRPrefix"
    
echo "Deployment for ${environment} ${application} environment is complete."

# Get the public IP address from the deployment outputs
echo "Retrieving public IP address..."

# First get the public IP resource ID from deployment outputs
publicIPResourceId=$(az deployment group show \
    --resource-group $resourceGroupName \
    --name $application-deployment \
    --query 'properties.outputs.webServerPublicIPResourceId.value' \
    --output tsv)

# Then get the actual IP address from the public IP resource
if [ ! -z "$publicIPResourceId" ] && [ "$publicIPResourceId" != "null" ]; then
    publicIP=$(az network public-ip show \
        --ids $publicIPResourceId \
        --query 'ipAddress' \
        --output tsv)
    
    fqdn=$(az deployment group show \
        --resource-group $resourceGroupName \
        --name $application-deployment \
        --query 'properties.outputs.webServerFQDN.value' \
        --output tsv)
else
    publicIP=""
    fqdn=""
fi

# Display the public IP address
if [ ! -z "$publicIP" ] && [ "$publicIP" != "null" ]; then
    echo ""
    echo "=========================================="
    echo "VM Public IP Address: $publicIP"
    if [ ! -z "$fqdn" ] && [ "$fqdn" != "null" ]; then
        echo "VM FQDN: $fqdn"
    fi
    echo "=========================================="
    echo ""
    echo "You can SSH to the VM using:"
    echo "ssh -i ~/.ssh/$adminUsername $adminUsername@$publicIP"
    if [ ! -z "$fqdn" ] && [ "$fqdn" != "null" ]; then
        echo "Or using FQDN:"
        echo "ssh -i ~/.ssh/$adminUsername $adminUsername@$fqdn"
    fi
    echo ""
else
    echo "Warning: Could not retrieve public IP address from deployment."
    echo "The VM may still be starting up. You can check the public IP in the Azure portal."
    echo "Resource Group: $resourceGroupName"
fi