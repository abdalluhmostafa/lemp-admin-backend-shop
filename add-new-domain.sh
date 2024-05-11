#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2
PHPFPM_PORT=$3

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

		fastcgi_pass 127.0.0.1:$PHPFPM_PORT;
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

		fastcgi_pass 127.0.0.1:$PHPFPM_PORT;
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



ln -s /etc/nginx/sites-available/backend.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/admin.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/shop.$DOMAIN_NAME /etc/nginx/sites-enabled/

nginx -t

#### 


#  Php 8.1

cd /etc/php/8.1/fpm/pool.d/

cp www.conf $APP_USER.conf

sed -i '/\/run\/php\/php8.1-fpm.sock/d' $APP_USER.conf

echo "listen = 127.0.0.1:$PHPFPM_PORT" >> $APP_USER.conf

sed -i "4s/www/$APP_USER/" $APP_USER.conf

sed -i "s/user = www-data/user = $APP_USER/g" $APP_USER.conf
sed -i "s/group = www-data/group = $APP_USER/g" $APP_USER.conf


systemctl restart php8.1-fpm.service
systemctl enable php8.1-fpm.service




#### mysql 8


DB_PASS=$(openssl rand -base64 12)

mysql -u root -e "CREATE DATABASE \`${APP_USER}_db\`;"

mysql -u root -e "CREATE USER '${APP_USER}_user'@'%' IDENTIFIED BY '$DB_PASS';"

mysql -u root -e "GRANT ALL PRIVILEGES ON \`${APP_USER}_db\`.* TO '${APP_USER}_user'@'%';"

mysql -u root -e "FLUSH PRIVILEGES;"

echo "DB-Name: ${APP_USER}_db, DB-User: ${APP_USER}_user, DB-Pass: $DB_PASS"