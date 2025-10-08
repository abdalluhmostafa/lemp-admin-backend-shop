#!/bin/bash
DOMAIN_NAME=$1
APP_USER=$2

# Node + mongo _ saldwich
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

# Install PostgreSQL database server
echo "Installing PostgreSQL database server..."
sudo apt install postgresql postgresql-contrib -y

# Start and enable PostgreSQL service
echo "Starting and enabling PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Check PostgreSQL status
sudo systemctl status postgresql

sudo useradd $APP_USER -s /bin/bash

# Download the project
cd /var/www/
mkdir $APP_USER
mkdir -p /var/www/$APP_USER/backend
mkdir -p /var/www/$APP_USER/admin

chown $APP_USER.$APP_USER /var/www/$APP_USER  -R

mkdir /home/$APP_USER

mkdir /home/$APP_USER/.ssh

chmod 600 /home/$APP_USER/.ssh

touch /home/$APP_USER/.ssh/authorized_keys

# Add SSH key to authorized_keys
cat > /home/$APP_USER/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxDUBpZVovZtajELVoGUNm1ZIwN53tvSgoJtcNVv+ewRi37/Pj8LKaV9rJ98lzbXUzVJTpXq19TjJ7Qn83hS5b36wDZ0BK19S3VihDg2QreIsR4WPrOXJEzNAJz69at5zY2rcusWrHpVC8wSvfp8qLEwJbBEvCdfbZJqF9RnXorVAlPw8PVE00VSHNZt3o3OHDYGI9+8MA1BO4e0ZmsJa9rJQfn6xrSA716KYQHMWR3PMyYaj2J8pikqRLUrC+AxynirXrzSHGX/zgW1qoG62cviSic0v42ow953b3/JngqdSRyVn5KUW/OQd+2QNRkyInlfaEvxiJ0SkDf6FObq7Lw== qts66@qts66-desktop
EOF

chown $APP_USER.$APP_USER /home/$APP_USER -R




# Create PostgreSQL user and database
# Use proper quotes for PostgreSQL compatibility
sudo -u postgres psql -c "CREATE USER \"$DB_USERNAME\" WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE \"$DB_DATABASE\";"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_DATABASE\" TO \"$DB_USERNAME\";"


## Backend Nginx config
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

## admin Nginx config
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


# rm -rf  /etc/nginx/sites-available/default 
# rm -rf /etc/nginx/sites-enabled/default 

nginx -t