#!/usr/bin/env bash

set -e

PI_DOMAIN="pi.siibarnut.com"
ESERVER_DOMAIN="eserver.siibarnut.com"
BANK_DOMAIN="bank.siibarnut.com"
BSERVER_DOMAIN="bserver.siibarnut.com"

NGINX_CONF="/etc/nginx/sites-available/siibarnut.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/siibarnut.com"
SOURCE_CONF="./config/siibarnut.com.conf"

echo "🔧 Installing NGINX and Certbot..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo "📁 Setting up NGINX config (SSL includes commented)..."
sudo cp "$SOURCE_CONF" "$NGINX_CONF"

# Step 1: Comment SSL includes to avoid file-not-found errors
sudo sed -i 's|include /etc/letsencrypt/options-ssl-nginx.conf;|# include /etc/letsencrypt/options-ssl-nginx.conf;|' "$NGINX_CONF"
sudo sed -i 's|ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|# ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|' "$NGINX_CONF"

# Step 2: Enable the site
sudo ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

echo "🔍 Testing NGINX config..."
sudo nginx -t

echo "🔄 Reloading NGINX..."
sudo systemctl reload nginx

# Step 3: Run Certbot to issue SSL certificates (creates the missing files)
echo "🔐 Requesting Let's Encrypt SSL certificates..."
sudo certbot --nginx -d $PI_DOMAIN -d $ESERVER_DOMAIN -d $BANK_DOMAIN -d $BSERVER_DOMAIN

# Step 4: Restore the original config with SSL includes
echo "✅ Re-enabling SSL includes..."
sudo sed -i 's|# include /etc/letsencrypt/options-ssl-nginx.conf;|include /etc/letsencrypt/options-ssl-nginx.conf;|' "$NGINX_CONF"
sudo sed -i 's|# ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|' "$NGINX_CONF"

# Step 5: Final test and reload
echo "🔁 Reloading NGINX with SSL enabled..."
sudo nginx -t && sudo systemctl reload nginx

# Step 6: Test auto-renewal
echo "🧪 Testing SSL auto-renewal..."
sudo certbot renew --dry-run

echo "🎉 Setup complete. All subdomains are now secured with HTTPS!"
