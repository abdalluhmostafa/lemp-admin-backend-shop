#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2

# Backend - nodejs without db
# Dashboard - React 
# Python without ingress 


# Create backend Node js
# Create user with bash shell
sudo useradd $APP_USER -s /bin/bash

# Create paths
cd /var/www/

mkdir $APP_USER/backend -p
mkdir $APP_USER/dashboard -p
mkdir $APP_USER/python -p

chown $APP_USER.$APP_USER /var/www/$APP_USER -R

mkdir -p /home/$APP_USER/.ssh
chmod 700 /home/$APP_USER/.ssh

# Add SSH key to authorized_keys
cat > /home/$APP_USER/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxDUBpZVovZtajELVoGUNm1ZIwN53tvSgoJtcNVv+ewRi37/Pj8LKaV9rJ98lzbXUzVJTpXq19TjJ7Qn83hS5b36wDZ0BK19S3VihDg2QreIsR4WPrOXJEzNAJz69at5zY2rcusWrHpVC8wSvfp8qLEwJbBEvCdfbZJqF9RnXorVAlPw8PVE00VSHNZt3o3OHDYGI9+8MA1BO4e0ZmsJa9rJQfn6xrSA716KYQHMWR3PMyYaj2J8pikqRLUrC+AxynirXrzSHGX/zgW1qoG62cviSic0v42ow953b3/JngqdSRyVn5KUW/OQd+2QNRkyInlfaEvxiJ0SkDf6FObq7Lw== qts66@qts66-desktop
EOF

chmod 600 /home/$APP_USER/.ssh/authorized_keys
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

# Dashboard - React
cat > /etc/nginx/sites-available/dashboard.$DOMAIN_NAME <<EOF

server {

    server_name  	dashboard.$DOMAIN_NAME;
    root         /var/www/$APP_USER/dashboard/build;
    access_log /var/log/nginx/dashboard-$APP_USER-access.log;
    error_log /var/log/nginx/dashboard-$APP_USER-error.log;
    index index.php index.html index.htm;
    try_files \$uri \$uri/ \$uri/index.html =404;

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

	location / {
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
                autoindex off;
	}

        location ~ \.php$ {

		fastcgi_pass 127.0.0.1:$PHPFPM_PORT;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

    listen 80;


}

EOF


ln -s /etc/nginx/sites-available/backend.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/dashboard.$DOMAIN_NAME /etc/nginx/sites-enabled/

nginx -t

# Get the server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Print formatted information
cat <<EOF

/******************************************
    Project: $DOMAIN_NAME - info
*****************************************/

/******************************************
    Backend
*****************************************/
URL: https://backend.$DOMAIN_NAME

ssh $APP_USER@$SERVER_IP

Root directory: /var/www/$APP_USER/backend

--> Commands to start app
pm2 --name $APP_USER-backend start yarn -- run start --port 3000

Notes: 
- NodeJS
/******************************************
    Dashboard
*****************************************/

URL: https://dashboard.$DOMAIN_NAME

Root directory: /var/www/$APP_USER/dashboard

pm2 --name $APP_USER-dashboard start yarn -- run start --port 3001

Notes: 
- NodeJS

/******************************************
    Python app
*****************************************/


Root directory: /var/www/$APP_USER/pythob

pm2 --name $APP_USER-python start yarn -- run start --port 3001

Notes: 
- python
EOF