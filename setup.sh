#!/usr/bin/env bash

set -e

PI_DOMAIN="pi.siibarnut.com"
ESERVER_DOMAIN="eserver.siibarnut.com"
BANK_DOMAIN="bank.siibarnut.com"
BSERVER_DOMAIN="bserver.siibarnut.com"

NGINX_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"

echo "🔧 Installing NGINX and Certbot..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo "🌐 Applying HTTP-only config to allow Certbot validation..."
sudo cp config/siibarnut.http.conf "$NGINX_DIR/siibarnut.com"
sudo ln -sf "$NGINX_DIR/siibarnut.com" "$ENABLED_DIR/siibarnut.com"

sudo nginx -t && sudo systemctl reload nginx

echo "🔐 Requesting SSL certs..."
sudo certbot certonly --nginx -d $PI_DOMAIN -d $ESERVER_DOMAIN -d $BANK_DOMAIN -d $BSERVER_DOMAIN

echo "🔁 Switching to full HTTPS config..."
sudo cp config/siibarnut.ssl.conf "$NGINX_DIR/siibarnut.com"

sudo nginx -t && sudo systemctl reload nginx

echo "🧪 Testing cert auto-renewal..."
sudo certbot renew --dry-run

echo "✅ All done. HTTPS reverse proxy is active!"
