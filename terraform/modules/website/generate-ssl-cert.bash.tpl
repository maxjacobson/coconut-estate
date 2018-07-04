#!/bin/bash

exec &> >(tee /var/log/generate-ssl-cert.log | logger --tag generate-ssl-cert --stderr 2>/dev/console)

set -ex

echo "Preparing website droplet's SSL cert"

cp /etc/nginx/nginx.conf /root/nginx-original.conf
cp /root/nginx.conf /etc/nginx/nginx.conf
nginx -t # validate configuration file
systemctl reload nginx

certbot --nginx \
  -d ${bare_domain} \
  -d ${www_domain} \
  -m ${ops_email} \
  --agree-tos \
  --redirect \
  -n \
  --config-dir /mnt/website/letsencrypt

certbot --nginx \
  -d ${api_domain} \
  -m ${ops_email} \
  --agree-tos \
  --redirect \
  -n \
  --config-dir /mnt/website/letsencrypt

systemctl stop nginx
certbot certonly --standalone \
  -d ${database_domain} \
  -m ${ops_email} \
  --agree-tos \
  -n \
  --config-dir /mnt/database/letsencrypt
systemctl start nginx

cp /mnt/database/letsencrypt/live/${database_domain}/privkey.pem /mnt/database/postgres/
cp /mnt/database/letsencrypt/live/${database_domain}/fullchain.pem /mnt/database/postgres
chown -R postgres:postgres /mnt/database/postgres
chmod 0600 /mnt/database/postgres/privkey.pem

systemctl enable postgresql@9.5-main
systemctl restart postgresql@9.5-main

echo "all done"
