#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2

# Create backend Node js + postgresql and admin Node js only

sudo useradd $APP_USER

# Download the project
cd /var/www/

mkdir $APP_USER
chown $APP_USER.$APP_USER /var/www/$APP_USER  -R

mkdir /home/$APP_USER

chown $APP_USER.$APP_USER /home/$APP_USER -R


## Backend Nginx config - NodeJS
cat > /etc/nginx/sites-available/backend.$DOMAIN_NAME <<EOF

server {
        index index.html index.htm;
        server_name backend.$DOMAIN_NAME;
        access_log /var/log/nginx/backend-$DOMAIN_NAME-access.log;
        error_log /var/log/nginx/backend-$DOMAIN_NAME-error.log;
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

## Admin Nginx config - NodeJS

cat > /etc/nginx/sites-available/admin.$DOMAIN_NAME <<EOF

server {
        index index.html index.htm;
        server_name admin.$DOMAIN_NAME;
        access_log /var/log/nginx/admin-$DOMAIN_NAME-access.log;
        error_log /var/log/nginx/admin-$DOMAIN_NAME-error.log;
location / {
  proxy_pass http://localhost:3001;
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

nginx -t

#### 

