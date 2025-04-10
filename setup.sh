#!/usr/bin/env bash

set -e

PI_DOMAIN="pi.siibarnut.com"
ESERVER_DOMAIN="eserver.siibarnut.com"
BANK_DOMAIN="bank.siibarnut.com"
BSERVER_DOMAIN="bserver.siibarnut.com"

echo "🔧 Installing NGINX and Certbot..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo "📁 Setting up NGINX config..."
sudo cp config/siibarnut.com.conf /etc/nginx/sites-available/siibarnut.com
sudo ln -sf /etc/nginx/sites-available/siibarnut.com /etc/nginx/sites-enabled/

echo "🔍 Testing NGINX config..."
sudo nginx -t

echo "🔄 Reloading NGINX..."
sudo systemctl reload nginx

echo "🔐 Requesting SSL certificates for all subdomains..."
sudo certbot --nginx -d $PI_DOMAIN -d $ESERVER_DOMAIN -d $BANK_DOMAIN -d $BSERVER_DOMAIN

echo "✅ HTTPS is now configured for:"
echo "  - $PI_DOMAIN"
echo "  - $ESERVER_DOMAIN"
echo "  - $BANK_DOMAIN"
echo "  - $BSERVER_DOMAIN"

echo "🧪 Testing auto-renewal..."
sudo certbot renew --dry-run

echo "🎉 Setup complete!"
