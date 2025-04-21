#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2

# Generate a random password
DB_PASSWORD=$(openssl rand -base64 16)
DB_USERNAME="${APP_USER}_user"
DB_DATABASE="${APP_USER}_db"

# Create backend Node js + postgresql and admin Node js only
# Create user with bash shell
sudo useradd $APP_USER -s /bin/bash

# Download the project
cd /var/www/

mkdir $APP_USER
chown $APP_USER.$APP_USER /var/www/$APP_USER -R

mkdir -p /home/$APP_USER/.ssh
chmod 700 /home/$APP_USER/.ssh

# Add SSH key to authorized_keys
cat > /home/$APP_USER/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxDUBpZVovZtajELVoGUNm1ZIwN53tvSgoJtcNVv+ewRi37/Pj8LKaV9rJ98lzbXUzVJTpXq19TjJ7Qn83hS5b36wDZ0BK19S3VihDg2QreIsR4WPrOXJEzNAJz69at5zY2rcusWrHpVC8wSvfp8qLEwJbBEvCdfbZJqF9RnXorVAlPw8PVE00VSHNZt3o3OHDYGI9+8MA1BO4e0ZmsJa9rJQfn6xrSA716KYQHMWR3PMyYaj2J8pikqRLUrC+AxynirXrzSHGX/zgW1qoG62cviSic0v42ow953b3/JngqdSRyVn5KUW/OQd+2QNRkyInlfaEvxiJ0SkDf6FObq7Lw== qts66@qts66-desktop
EOF

chmod 600 /home/$APP_USER/.ssh/authorized_keys
chown $APP_USER.$APP_USER /home/$APP_USER -R

# Create PostgreSQL user and database
# Use proper quotes for PostgreSQL compatibility
sudo -u postgres psql -c "CREATE USER \"$DB_USERNAME\" WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE \"$DB_DATABASE\";"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_DATABASE\" TO \"$DB_USERNAME\";"

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

# Create output directories
mkdir -p /var/www/$APP_USER/backend
mkdir -p /var/www/$APP_USER/admin
chown $APP_USER.$APP_USER /var/www/$APP_USER/backend -R
chown $APP_USER.$APP_USER /var/www/$APP_USER/admin -R

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

## Postgresql DATABASE ## 
DB_DATABASE: $DB_DATABASE
DB_USERNAME: $DB_USERNAME
DB_PASSWORD: $DB_PASSWORD

--> Commands to start app
pm2 --name $APP_USER-backend start yarn -- run start --port 3000

Notes: 
- NodeJS + Postgresql
/******************************************
    Admin
*****************************************/

URL: https://admin.$DOMAIN_NAME

Root directory: /var/www/$APP_USER/admin

pm2 --name $APP_USER-admin start yarn -- run start --port 3001

Notes: 
- NodeJS
EOF