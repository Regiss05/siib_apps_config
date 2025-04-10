#!/usr/bin/env bash

set -e

SUBDOMAIN=$1
PORT=$2
SITE_CONF="/etc/nginx/sites-available/siibarnut.com"
ENABLED_CONF="/etc/nginx/sites-enabled/siibarnut.com"

if [ -z "$SUBDOMAIN" ] || [ -z "$PORT" ]; then
  echo "❌ Usage: $0 <subdomain> <port>"
  exit 1
fi

echo "🧩 Adding $SUBDOMAIN -> localhost:$PORT"

# 1. Add to HTTP config block (for certbot validation)
if ! grep -q "$SUBDOMAIN" "$SITE_CONF"; then
  echo "🔧 Updating HTTP block with $SUBDOMAIN"
  sudo sed -i "/server_name/s/;/ $SUBDOMAIN;/" "$SITE_CONF"
fi

# 2. Reload nginx with updated HTTP config
echo "🔄 Reloading NGINX with updated HTTP config"
sudo nginx -t && sudo systemctl reload nginx

# 3. Issue SSL cert
echo "🔐 Requesting certificate for $SUBDOMAIN"
sudo certbot certonly --nginx -d "$SUBDOMAIN"

# 4. Append HTTPS block
echo "➕ Adding HTTPS reverse proxy block for $SUBDOMAIN"
sudo tee -a "$SITE_CONF" > /dev/null <<EOF

server {
    listen 443 ssl;
    server_name $SUBDOMAIN;

    ssl_certificate /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# 5. Final reload
echo "🚀 Reloading NGINX with HTTPS block for $SUBDOMAIN"
sudo nginx -t && sudo systemctl reload nginx

echo "✅ $SUBDOMAIN is now live on HTTPS and proxying to port $PORT"
