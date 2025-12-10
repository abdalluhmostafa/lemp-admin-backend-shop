#!/bin/bash

###########################################
# Server Deployment Script
# Purpose: Automated setup for Node.js applications with PostgreSQL
# Usage: ./script.sh <domain_name> <app_user>
# Author: Server Setup Automation
###########################################

# Check if required parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <domain_name> <app_user>"
    echo "Example: $0 example.com myapp"
    exit 1
fi

# Script parameters
DOMAIN_NAME=$1
APP_USER=$2

echo "Starting server setup for domain: $DOMAIN_NAME with user: $APP_USER"

###########################################
# SYSTEM CONFIGURATION
###########################################

# Set hostname to match the application user
echo "Setting hostname to $APP_USER..."
hostnamectl set-hostname $APP_USER

# Update system packages
echo "Updating system packages..."
sudo apt update -y

###########################################
# NGINX INSTALLATION AND CONFIGURATION
###########################################

# Install and configure Nginx web server
echo "Installing Nginx web server..."
sudo apt install nginx -y 

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Start Nginx service
sudo systemctl start nginx

# Check Nginx status
sudo systemctl status nginx

###########################################
# ESSENTIAL TOOLS INSTALLATION
###########################################

# Install SSL certificates, monitoring tools, and utilities
echo "Installing essential tools and utilities..."
sudo apt install certbot python3-certbot-nginx htop nload net-tools vim git curl zip unzip -y

###########################################
# NODE.JS INSTALLATION AND SETUP
###########################################

# Add NodeSource repository for Node.js 20.x
echo "Adding NodeSource repository for Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
echo "Installing Node.js..."
sudo apt install -y nodejs

# Install Yarn package manager globally
echo "Installing Yarn package manager..."
sudo npm i -g yarn

# Update npm to specific version
echo "Updating npm to version 10.7.0..."
sudo npm install -g npm@10.7.0

# Rebuild node-sass for compatibility
echo "Rebuilding node-sass..."
sudo npm rebuild node-sass

# Install PM2 process manager globally
echo "Installing PM2 process manager..."
sudo npm install pm2 -g

###########################################
# POSTGRESQL DATABASE INSTALLATION
###########################################

# Install PostgreSQL database server
echo "Installing PostgreSQL database server..."
sudo apt install postgresql postgresql-contrib -y

# Start and enable PostgreSQL service
echo "Starting and enabling PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Check PostgreSQL status
sudo systemctl status postgresql

###########################################
# DATABASE CONFIGURATION
###########################################

# Generate secure random password for database
echo "Generating database credentials..."
DB_PASSWORD=$(openssl rand -base64 16)
DB_USERNAME="${APP_USER}_user"
DB_DATABASE="${APP_USER}_db"

echo "Database credentials generated:"
echo "  - Database: $DB_DATABASE"
echo "  - Username: $DB_USERNAME"
echo "  - Password: [GENERATED]"

###########################################
# USER ACCOUNT SETUP
###########################################

# Create application user with bash shell
echo "Creating application user: $APP_USER"
sudo useradd $APP_USER -s /bin/bash

# Create application directory structure
echo "Setting up directory structure..."
cd /var/www/

# Create main application directory
mkdir $APP_USER

# Create subdirectories for different application components
mkdir -p /var/www/$APP_USER/backend
mkdir -p /var/www/$APP_USER/admin

# Set proper ownership for application directories
chown $APP_USER.$APP_USER /var/www/$APP_USER -R

###########################################
# SSH KEY CONFIGURATION
###########################################

# Create SSH directory for the application user
echo "Setting up SSH access for $APP_USER..."
mkdir -p /home/$APP_USER/.ssh
chmod 700 /home/$APP_USER/.ssh

# Add SSH public key for remote access
# Note: Replace this key with your actual public key
cat > /home/$APP_USER/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxDUBpZVovZtajELVoGUNm1ZIwN53tvSgoJtcNVv+ewRi37/Pj8LKaV9rJ98lzbXUzVJTpXq19TjJ7Qn83hS5b36wDZ0BK19S3VihDg2QreIsR4WPrOXJEzNAJz69at5zY2rcusWrHpVC8wSvfp8qLEwJbBEvCdfbZJqF9RnXorVAlPw8PVE00VSHNZt3o3OHDYGI9+8MA1BO4e0ZmsJa9rJQfn6xrSA716KYQHMWR3PMyYaj2J8pikqRLUrC+AxynirXrzSHGX/zgW1qoG62cviSic0v42ow953b3/JngqdSRyVn5KUW/OQd+2QNRkyInlfaEvxiJ0SkDf6FObq7Lw== qts66@qts66-desktop
EOF

# Set proper permissions for SSH key
chmod 600 /home/$APP_USER/.ssh/authorized_keys

# Set ownership for user home directory
chown $APP_USER.$APP_USER /home/$APP_USER -R

###########################################
# DATABASE USER AND DATABASE CREATION
###########################################

# Create PostgreSQL user with password
echo "Creating PostgreSQL user and database..."
sudo -u postgres psql -c "CREATE USER \"$DB_USERNAME\" WITH PASSWORD '$DB_PASSWORD';"

# Create PostgreSQL database
sudo -u postgres psql -c "CREATE DATABASE \"$DB_DATABASE\";"

# Grant all privileges on database to user
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_DATABASE\" TO \"$DB_USERNAME\";"

echo "Database setup completed successfully!"

###########################################
# NGINX VIRTUAL HOST CONFIGURATION
###########################################

echo "Configuring Nginx virtual hosts..."

# Backend API - Nginx configuration
# This serves the backend API on port 3001
cat > /etc/nginx/sites-available/backend.$DOMAIN_NAME <<EOF
server {
        index index.html index.htm;
        server_name backend.$DOMAIN_NAME;
        access_log /var/log/nginx/backend-$DOMAIN_NAME-access.log;
        error_log /var/log/nginx/backend-$DOMAIN_NAME-error.log;

        # Proxy all requests to Node.js backend API on port 3001
        location / {
            proxy_pass http://localhost:3001;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }

        # Deny access to .htaccess files
        location ~ /\.ht {
            deny all;
        }

        listen 80;
}
EOF

# admin/Admin panel - Nginx configuration
# This serves the admin admin on port 3002
cat > /etc/nginx/sites-available/admin.$DOMAIN_NAME <<EOF
server {
        index index.html index.htm;
        server_name admin.$DOMAIN_NAME;
        access_log /var/log/nginx/admin-$DOMAIN_NAME-access.log;
        error_log /var/log/nginx/admin-$DOMAIN_NAME-error.log;

        # Proxy all requests to Node.js admin on port 3002
        location / {
            proxy_pass http://localhost:3002;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }

        # Deny access to .htaccess files
        location ~ /\.ht {
            deny all;
        }

        listen 80;
}
EOF

###########################################
# ENABLE NGINX SITES
###########################################

# Create symbolic links to enable the sites
echo "Enabling Nginx sites..."
ln -s /etc/nginx/sites-available/backend.$DOMAIN_NAME /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/admin.$DOMAIN_NAME /etc/nginx/sites-enabled/

# Test Nginx configuration for syntax errors
echo "Testing Nginx configuration..."
nginx -t

# Reload Nginx to apply new configuration
echo "Reloading Nginx..."
sudo systemctl reload nginx

###########################################
# SUMMARY AND INFORMATION OUTPUT
###########################################

# Get the server's IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Display comprehensive setup information
cat <<EOF

/******************************************
    🚀 DEPLOYMENT COMPLETED SUCCESSFULLY!
    Project: $DOMAIN_NAME - Setup Information
*****************************************/

/******************************************
    📊 SYSTEM INFORMATION
*****************************************/
Server IP: $SERVER_IP
Hostname: $APP_USER
Operating System: $(lsb_release -d | cut -f2)
Node.js Version: $(node --version)
npm Version: $(npm --version)
PostgreSQL Version: $(sudo -u postgres psql -c "SELECT version();" | head -3 | tail -1)

/******************************************
    🔧 BACKEND API SERVER
*****************************************/
URL: https://backend.$DOMAIN_NAME
SSH Access: ssh $APP_USER@$SERVER_IP
Root Directory: /var/www/$APP_USER/backend

## PostgreSQL Database Configuration ##
Database Name: $DB_DATABASE
Database User: $DB_USERNAME
Database Password: $DB_PASSWORD
Connection String: postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_DATABASE

## Commands to Deploy and Start Backend ##
cd /var/www/$APP_USER/backend
# Clone your repository here
# git clone <your-backend-repo-url> .
# yarn install
pm2 --name $APP_USER-backend start yarn -- run start --port 3001

Notes: 
- Node.js + PostgreSQL backend API
- Handles authentication, data processing, and business logic
- Database automatically created and configured

/******************************************
    📱 ADMIN admin
*****************************************/
URL: https://admin.$DOMAIN_NAME
Local URL: http://localhost:3001
Root Directory: /var/www/$APP_USER/admin

## Commands to Deploy and Start admin ##
cd /var/www/$APP_USER/admin
# Clone your repository here
# git clone <your-admin-repo-url> .
# yarn install
pm2 --name $APP_USER-admin start yarn -- run start --port 3002

Notes: 
- Node.js admin interface
- Management panel for backend operations
- Separate port (3002) for admin access

/******************************************
    🛒 MAIN APPLICATION (SHOP)
*****************************************/
URL: https://$DOMAIN_NAME
Local URL: http://localhost:3000
Root Directory: /var/www/$APP_USER/shop

## Commands to Deploy and Start Shop ##
cd /var/www/$APP_USER/shop
# Clone your repository here
# git clone <your-shop-repo-url> .
# yarn install
pm2 --name $APP_USER-shop start yarn -- run start --port 3000

Notes: 
- Node.js e-commerce frontend
- Customer-facing application
- Main domain entry point

/******************************************
    📋 USEFUL COMMANDS
*****************************************/
# View PM2 processes
pm2 list

# View application logs
pm2 logs $APP_USER-backend
pm2 logs $APP_USER-admin  
pm2 logs $APP_USER-shop

# Restart applications
pm2 restart $APP_USER-backend
pm2 restart $APP_USER-admin
pm2 restart $APP_USER-shop

# Save PM2 configuration
pm2 save
pm2 startup

# Check Nginx status
sudo systemctl status nginx

# Check PostgreSQL status
sudo systemctl status postgresql

# Connect to PostgreSQL
sudo -u postgres psql -d $DB_DATABASE

Setup completed at: $(date)
EOF

echo ""
echo "🎉 Server setup completed successfully!"
echo "📧 Save the database credentials shown above in a secure location."
echo "🔐 Remember to install SSL certificates using certbot for production use."