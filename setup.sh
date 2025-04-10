#!/usr/bin/env bash

set -e

PI_DOMAIN="pi.siibarnut.com"
ESERVER_DOMAIN="eserver.siibarnut.com"
BANK_DOMAIN="bank.siibarnut.com"
BSERVER_DOMAIN="bserver.siibarnut.com"

NGINX_CONF="/etc/nginx/sites-available/siibarnut.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/siibarnut.com"

echo "🔧 Installing NGINX and Certbot..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo "📁 Copying initial NGINX config (with SSL includes commented)..."
sudo cp config/siibarnut.com.conf "$NGINX_CONF"

# Comment out SSL includes to avoid nginx failure
sudo sed -i 's|include /etc/letsencrypt/options-ssl-nginx.conf;|# include /etc/letsencrypt/options-ssl-nginx.conf;|' "$NGINX_CONF"
sudo sed -i 's|ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|# ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|' "$NGINX_CONF"

sudo ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

echo "🔍 Testing NGINX config..."
sudo nginx -t

echo "🔄 Reloading NGINX..."
sudo systemctl reload nginx

echo "🔐 Requesting SSL certificates for all subdomains..."
sudo certbot --nginx -d $PI_DOMAIN -d $ESERVER_DOMAIN -d $BANK_DOMAIN -d $BSERVER_DOMAIN

echo "✅ Enabling SSL config now that certs are ready..."
sudo sed -i 's|# include /etc/letsencrypt/options-ssl-nginx.conf;|include /etc/letsencrypt/options-ssl-nginx.conf;|' "$NGINX_CONF"
sudo sed -i 's|# ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;|' "$NGINX_CONF"

echo "🔁 Reloading NGINX with full HTTPS support..."
sudo nginx -t && sudo systemctl reload nginx

echo "🧪 Testing auto-renewal..."
sudo certbot renew --dry-run

echo "🎉 Setup complete and HTTPS enabled!"
