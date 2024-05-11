#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2

hostnamectl set-hostname $APP_USER
sudo apt update -y
sudo apt install nginx -y 
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
sudo apt install certbot python3-certbot-nginx htop nload net-tools vim git curl -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm i -g yarn
sudo apt install zip unzip -y
sudo npm install -g npm@10.7.0
sudo npm rebuild node-sass
sudo npm install pm2 -g

sudo useradd $APP_USER

# Download the project
cd /var/www/
wget https://filebin.net/umroh7tt2413w0dt/project.zip
unzip project.zip
mv project $APP_USER
rm -rf project.zip
chown $APP_USER.$APP_USER /var/www/$APP_USER  -R

mkdir /home/$APP_USER

chown $APP_USER.$APP_USER /home/$APP_USER -R


## Backend Nginx config
cat > /etc/nginx/sites-available/backend.$DOMAIN_NAME <<EOF

server {

    server_name  	backend.$DOMAIN_NAME;
    root         /var/www/$APP_USER/backend/public;
	access_log /var/log/nginx/backend-$APP_USER-access.log;
	error_log /var/log/nginx/backend-$APP_USER-error.log;
	index index.php index.html index.htm;
######

      gzip on;
      include             /etc/nginx/mime.types;
      default_type        application/octet-stream;
      fastcgi_buffers 16 128k;
      fastcgi_buffer_size 256k;
      client_max_body_size 500M;
      client_body_buffer_size 256k;
      client_header_buffer_size 512k;
      client_header_timeout 2000s;
      client_body_timeout 2000s;
      send_timeout 2000s;
      fastcgi_connect_timeout 2000s;
      fastcgi_send_timeout 2000s;
      fastcgi_read_timeout 2000s;

## CloudFalre
real_ip_header CF-Connecting-IP;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.214.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;


###
	location / {
	        index index.php index.html index.htm;
        	try_files \$uri \$uri/ /index.php\$is_args\$args;

		#try_files \$uri \$uri/ =404;
                #try_files \$uri \$uri/ ;
                #try_files \$uri \$uri/ /index.php?\$args;
		#try_files \$uri \$uri/ =404;


#                autoindex off;
	}

#########
        location ~ \.php$ {

		fastcgi_pass 127.0.0.1:9001;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        }


    listen 80;

}

EOF

## Admin Nginx config
cat > /etc/nginx/sites-available/admin.$DOMAIN_NAME <<EOF

server {

    server_name  	admin.$DOMAIN_NAME;
    root         /var/www/$APP_USER/admin/build;
    access_log /var/log/nginx/admin-$APP_USER-access.log;
    error_log /var/log/nginx/admin-$APP_USER-error.log;
    index index.php index.html index.htm;
    try_files \$uri \$uri/ \$uri/index.html =404;

######

      gzip on;
      include             /etc/nginx/mime.types;
      default_type        application/octet-stream;
      fastcgi_buffers 16 128k;
      fastcgi_buffer_size 256k;
      client_max_body_size 500M;
      client_body_buffer_size 256k;
      client_header_buffer_size 512k;
      client_header_timeout 2000s;
      client_body_timeout 2000s;
      send_timeout 2000s;
      fastcgi_connect_timeout 2000s;
      fastcgi_send_timeout 2000s;
      fastcgi_read_timeout 2000s;

## CloudFalre
real_ip_header CF-Connecting-IP;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.214.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;


###
	location / {

        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;

                 ### cache
                #proxy_cache my_cache;
                #proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
                #proxy_cache_valid 200 302 10m;
                #proxy_cache_valid 404 1m;

                autoindex off;
	}


#     location /admin{
#   proxy_pass http://localhost:3000;
#   proxy_http_version 1.1;
#   proxy_set_header Upgrade \$http_upgrade;
#   proxy_set_header Connection 'upgrade';
#   proxy_set_header Host \$host;
#   proxy_cache_bypass \$http_upgrade;
#     }
#########
        location ~ \.php$ {

		fastcgi_pass 127.0.0.1:9001;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

######
##################### cache ###########################
        location ~* ^/.*\.(pdf)$ {
                add_header Access-Control-Allow-Origin *;
                  add_header Cache-Control "public";

       }

        location ~* ^/.*\.(js|css|png|jpg|jpeg|gif|svg|ico|woff)$ {
                expires 30d;
                #add_header Cache-Control "public, no-transform";
                  add_header Cache-Control "public";

        }

        location ~*  ^/.*\.(jpg|jpeg|gif|png|svg)$ {
                expires 365d;
                  add_header Cache-Control "public";

       }

        location ~*  ^/.*\.(pdf|css|html|js)$ {
                  add_header Cache-Control "public";
                expires 7d;
        }


    listen 80;


}

EOF

## shop Nginx config
cat > /etc/nginx/sites-available/shop.$DOMAIN_NAME <<EOF

server {
        index index.html index.htm;
        server_name shop.$DOMAIN_NAME;
        access_log /var/log/nginx/shop-$DOMAIN_NAME-access.log;
        error_log /var/log/nginx/shop-$DOMAIN_NAME-error.log;
location / {
  proxy_pass http://localhost:3000;
  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection 'upgrade';
  proxy_set_header Host \$host;
  proxy_cache_bypass \$http_upgrade;
}
location ~ /\.ht {
    deny all;
}



    listen 80;

}


EOF

# Phpmyadmin Nginx configration
cat > /etc/nginx/sites-available/phpmyadmin <<EOF

server {
        server_name phpmyadmin.$DOMAIN_NAME;

               access_log /var/log/nginx/phpmyadmin-access.log;
               error_log /var/log/nginx/phpmyadmin-error.log;

        index index.php index.html;
        root /var/www/phpmyadmin/;

        location / {
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }
        location ~ \.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.*)$;
                fastcgi_index index.php;
                fastcgi_pass 127.0.0.1:9002;
                include fastcgi_params;
                fastcgi_param PATH_INFO \$fastcgi_path_info;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }


    listen 80;


}

EOF


ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/

ln -s /etc/nginx/sites-available/backend.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/admin.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/shop.$DOMAIN_NAME /etc/nginx/sites-enabled/


rm -rf  /etc/nginx/sites-available/default 
rm -rf /etc/nginx/sites-enabled/default 

nginx -t

## Install PhpMyAdmin

cd /var/www/
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.2/phpMyAdmin-5.1.2-all-languages.tar.gz
tar xvf phpMyAdmin-5.1.2-all-languages.tar.gz
mv phpMyAdmin-5.1.2-all-languages/ phpmyadmin
mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php
apt install pwgen -y
pwgen -s 32 1 > x
secret=$(cat x)
sed -i '/blowfish_secret/d' /var/www/phpmyadmin/config.inc.php
echo "\$cfg['blowfish_secret'] = '$secret';" >> /var/www/phpmyadmin/config.inc.php
echo "\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" >> /var/www/phpmyadmin/config.inc.php
chown www-data.www-data /var/www/phpmyadmin/ -R
rm -rf x

#### 


# Install Php 8.1
sudo apt install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php

sudo apt install --no-install-recommends php8.1 -y


sudo apt install php8.1-mbstring php8.1-xml php8.1-bcmath php8.1-simplexml php8.1-intl php8.1-gd php8.1-curl php8.1-zip php8.1-gmp composer php8.1-fpm php8.1-mysql -y


cd /etc/php/8.1/fpm/pool.d/

cp www.conf phpmyadmin.conf

sed -i '/\/run\/php\/php8.1-fpm.sock/d' phpmyadmin.conf

echo "listen = 127.0.0.1:9002" >> phpmyadmin.conf

sed -i '4s/www/phpmyadmin/' phpmyadmin.conf

mv www.conf $APP_USER.conf

sed -i '/\/run\/php\/php8.1-fpm.sock/d' $APP_USER.conf

echo "listen = 127.0.0.1:9001" >> $APP_USER.conf

sed -i "4s/www/$APP_USER/" $APP_USER.conf

sed -i "s/user = www-data/user = $APP_USER/g" $APP_USER.conf
sed -i "s/group = www-data/group = $APP_USER/g" $APP_USER.conf


systemctl restart php8.1-fpm.service
systemctl enable php8.1-fpm.service


## Install PHP Composer

cd /tmp
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# php composer-setup.php
# php -r "unlink('composer-setup.php');"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

composer --version



#### Install mysql 8


wget https://dev.mysql.com/get/mysql-apt-config_0.8.19-1_all.deb

sudo dpkg -i mysql-apt-config_0.8.19-1_all.deb

#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C 


sudo apt update -y 

sudo apt install -y mysql-server mysql-client


mysql –V


sudo systemctl start mysql

sudo systemctl enable mysql


DB_PASS=$(openssl rand -base64 12)

mysql -u root -e "CREATE DATABASE \`${APP_USER}_db\`;"

mysql -u root -e "CREATE USER '${APP_USER}_user'@'%' IDENTIFIED BY '$DB_PASS';"

mysql -u root -e "GRANT ALL PRIVILEGES ON \`${APP_USER}_db\`.* TO '${APP_USER}_user'@'%';"

mysql -u root -e "FLUSH PRIVILEGES;"

echo "DB-Name: ${APP_USER}_db, DB-User: ${APP_USER}_user, DB-Pass: $DB_PASS"

# ## Edit the backend .env

# cd /var/www/$APP_USER/backend

# sed -i '/^APP_URL/d' .env
# sed -i "1iAPP_URL=$DOMAIN_NAME" .env
# sed -i "s/^DB_DATABASE=uzmart/DB_DATABASE=\${APP_USER}_db/" .env
# sed -i "s/^DB_USERNAME=root/DB_USERNAME=\${APP_USER}_user/" .env
# sed -i "s/^DB_PASSWORD=/DB_PASSWORD=$DB_PASS/" .env

# composer install and php artisan install:project

# composer install

# php artisan key:generate

# touch config/init.php

# echo " You need to add lisence keys here config/credential.php"

# php artisan migrate

# php artisan db:seed

# chmod -R 775 storage

# php artisan storage:link

# php artisan optimize:clear


# ## Admin

# cd /var/www/$APP_USER/admin/src/configs

# sed -i "s#export const BASE_URL = 'https://api.uzmart.org';#export const BASE_URL = 'https://backend.$DOMAIN_NAME';#" app-global.js
# sed -i "s#export const WEBSITE_URL = 'https://uzmart.org';#export const WEBSITE_URL = 'https://admin.$DOMAIN_NAME';#" app-global.js

