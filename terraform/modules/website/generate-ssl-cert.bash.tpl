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

echo "all done"
