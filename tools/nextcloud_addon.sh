#!/bin/bash
clear
echo "just a thought/idea"
echo "a small/singel nextcloud environment, with access only over wireguard"
echo "without let's encrypt, just self-signed certificate"
echo "only for debian 12 and fedora 38, > out-of-the-box php 8.2"


echo ""
echo  -e "                    ${RED}To EXIT this script press any key${ENDCOLOR}"
echo ""
echo  -e "                            ${GREEN}Press [Y] , but not (N)ow :)${ENDCOLOR}"
read -p "" -n 1 -r
echo ""
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    exit 1
fi

### root check
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${RED}Sorry, you need to run this as root${ENDCOLOR}"
	exit 1
fi


#
# OS check
#
echo -e "${GREEN}OS check ${ENDCOLOR}"

. /etc/os-release

if [[ "$ID" = 'debian' ]]; then
 if [[ "$VERSION_ID" = '12' ]]; then
   echo -e "${GREEN}OS = Debian ${ENDCOLOR}"
   systemos=debian
   fi
fi

if [[ "$ID" = 'fedora' ]]; then
 if [[ "$VERSION_ID" = '38' ]]; then
   echo -e "${GREEN}OS = Fedora ${ENDCOLOR}"
   systemos=fedora
   fi
fi


if [[ "$systemos" = '' ]]; then
   clear
   echo ""
   echo ""
   echo -e "${RED}This script is only for Debian 12, Fedora 38${ENDCOLOR}"
   exit 1
fi



### check if script installed
if [[ -e /root/Wireguard-DNScrypt-VPN-Server.README ]]; then
     echo ""
else
	 exit 1
fi

ipv4network=$(sed -n 7p /root/Wireguard-DNScrypt-VPN-Server.README)
ipv6network=$(sed -n 9p /root/Wireguard-DNScrypt-VPN-Server.README)

#
# OS updates
#
echo -e "${GREEN}update upgrade and install ${ENDCOLOR}"

if [[ "$systemos" = 'debian' ]]; then
apt update && apt upgrade -y && apt autoremove -y
apt install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-redis php-igbinary php-apcu memcached php-memcached unzip libmagickcore-6.q16-6-extra -y
fi

if [[ "$systemos" = 'fedora' ]]; then
dnf upgrade --refresh -y && dnf autoremove -y
dnf install httpd mod_ssl libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-intl php-gmp php-bcmath php-imagick php-zip php-bz2 php-opcache php-common php-pecl-redis php-igbinary php-pecl-apcu memcached php-pecl-memcached unzip libmagickcore-6.q16-6-extra -y
#systemctl enable memcached
#systemctl start memcached
fi



read -p "Your apache https port: " -e -i 23443 httpsport
read -p "Your mariaDB port: " -e -i 3306 dbport
read -p "nextcloud logtimezone: " -e -i Europe/Berlin ltz 
read -p "nextcloud default phone region: " -e -i DE dpr

### self-signed  certificate
#openssl req -x509 -newkey rsa:4096 -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=XX/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1"
openssl req -x509 -newkey ec:<(openssl ecparam -name secp384r1) -days 1800 -nodes -keyout /etc/ssl/private/nc-selfsigned.key -out /etc/ssl/certs/nc-selfsigned.crt -subj "/C=DE/ST=Your/L=Nextcloud/O=Behind/OU=Wireguard/CN=10.$ipv4network.1"

### apache part
a2enmod ssl
a2enmod rewrite
a2enmod headers
#a2enmod env
#a2enmod dir
#a2enmod mime
#a2enmod setenvif


if [[ "$systemos" = 'debian' ]]; then
systemctl stop apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl stop httpd.service
fi



mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
echo "
Listen 2380

<IfModule ssl_module>
        Listen $httpsport
</IfModule>

<IfModule mod_gnutls.c>
        Listen $httpsport
</IfModule>
" >> /etc/apache2/ports.conf

echo "
<VirtualHost *:$httpsport>
   ServerName 10.$ipv4network.1
   DocumentRoot /var/www/nextcloud
   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/nc-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/nc-selfsigned.key

<Directory /var/www/nextcloud/>
  AllowOverride All
  Require host localhost
  Require ip 10.$ipv4network
</Directory>

<IfModule mod_headers.c>
   Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</IfModule>

</VirtualHost>
" >> /etc/apache2/sites-available/nc.conf

mkdir /var/www
mkdir /opt/nextcloud/data
cd /var/www
curl -o nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip
unzip -qq nextcloud.zip
chown -R www-data:www-data /var/www/nextcloud
chown -R www-data:www-data /opt/nextcloud/data

##php settings nextcloud
cp /etc/php/8.2/apache2/php.ini /etc/php/8.2/apache2/php.ini.bak
sed -i 's,^post_max_size =.*$,post_max_size = 10G,' /etc/php/8.2/apache2/php.ini
sed -i 's,^upload_max_filesize =.*$,upload_max_filesize = 10G,' /etc/php/8.2/apache2/php.ini
sed -i 's,^max_execution_time =.*$,max_execution_time = 3600,' /etc/php/8.2/apache2/php.ini
sed -i 's,^max_input_time =.*$,max_input_time = 3600,' /etc/php/8.2/apache2/php.ini
sed -i 's,^memory_limit =.*$,memory_limit = 512M,' /etc/php/8.2/apache2/php.ini
sed -i 's,^max_file_uploads =.*$,max_file_uploads = 20,' /etc/php/8.2/apache2/php.ini
sed -i 's,^output_buffering =.*$,output_buffering = 0,' /etc/php/8.2/apache2/php.ini
sed -i 's,^opcache.save_comments =.*$,opcache.save_comments = 1,' /etc/php/8.2/apache2/php.ini
sed -i 's,^opcache.revalidate_freq =.*$,opcache.revalidate_freq = 60,' /etc/php/8.2/apache2/php.ini
sed -i 's,^opcache.validate_timestamps =.*$,opcache.validate_timestamps = 0,' /etc/php/8.2/apache2/php.ini
sed -i 's,^opcache.jit =.*$,opcache.jit = 1255,' /etc/php/8.2/apache2/php.ini
sed -i 's,^opcache.jit_buffer_size =.*$,opcache.jit_buffer_size = 128M,' /etc/php/8.2/apache2/php.ini
sed -i 's,^apc.enable_cli =.*$,apc.enable_cli = 1,' /etc/php/8.2/apache2/php.ini



#nextcloud config.php
sed -i "/);/i\  'memcache.local' => '\\\OC\\\Memcache\\\APCu'," /var/www/nextcloud/config/config.php
sed -i "/);/i\  'memcache.locking' => '\\\OC\\\Memcache\\\Memcached'," /var/www/nextcloud/config/config.php
sed -i "/);/i\  'logtimezone' => '$ltz'," /var/www/nextcloud/config/config.php
sed -i "/);/i\  'default_phone_region' => '$dpr'," /var/www/nextcloud/config/config.php

#opcache optimieren , memcache.local’ => ‘\OC\Memcache\APCu
#redis usw


echo "
<?php
	phpinfo();
?>
" > /var/www/nextcloud/phpinfotest.php

a2ensite nc.conf


if [[ "$systemos" = 'debian' ]]; then
systemctl start apache2.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl start httpd.service
fi


### DB part


mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
echo "
[mysqld]
bind-address = 127.0.0.1
port = $dbport

slow_query_log_file    = /var/log/mysql/mariadb-slow.log
long_query_time        = 10
log_slow_rate_limit    = 1000
log_slow_verbosity     = query_plan
log-queries-not-using-indexes
" > /etc/mysql/my.cnf


echo ""
echo " Your database server will now be hardened - just follow the instructions."
echo " Keep in mind: your MariaDB root password is still NOT set!"
echo ""
mysql_secure_installation


randomkey1=$(date +%s | cut -c 3-)
read -p "sql databasename: " -e -i db$randomkey1 databasename
read -p "sql databaseuser: " -e -i dbuser$randomkey1 databaseuser
randomkey2=$(</dev/urandom tr -dc 'A-Za-z0-9.:_' | head -c 32  ; echo)
read -p "sql databaseuserpasswd: " -e -i $randomkey2 databaseuserpasswd
echo "
Database
databasename : $databasename
databaseuser : $databaseuser
databaseuserpasswd : $databaseuserpasswd
#
" >> /root/mysql_database_list.txt

mysql -uroot <<EOF
CREATE DATABASE $databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
GRANT ALL PRIVILEGES on $databasename.* to '$databaseuser'@'localhost' identified by '$databaseuserpasswd';
FLUSH privileges;
EOF


if [[ "$systemos" = 'debian' ]]; then
systemctl restart mariadb.service
fi

if [[ "$systemos" = 'fedora' ]]; then
systemctl restart mariadb.service
fi


echo " Setup your Nextcloud         :  https://10.$ipv4network.1:$httpsport"
echo " Your database name           :  $databasename"
echo " Your database user           :  $databaseuser"
echo " Your database password       :  $databaseuserpasswd"
echo " Your database host           :  localhost:$dbport"
echo " Your nextcloud data folder   :  /opt/nextcloud/data"












 

