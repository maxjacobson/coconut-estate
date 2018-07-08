#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing website droplet"

sudo add-apt-repository --yes ppa:certbot/certbot
apt-get update
apt-get upgrade --yes
apt-get update
apt-get install --yes htop jq ncdu tree silversearcher-ag python-certbot-nginx \
  postgresql postgresql-contrib
apt-get autoremove --yes
curl -sSL https://agent.digitalocean.com/install.sh | sh

useradd coconut --create-home --shell /bin/bash --comment "Main user for service"
usermod -aG sudo coconut
echo "coconut ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/100-coconut

mkdir -p /home/coconut/.ssh
cp ~/.ssh/authorized_keys /home/coconut/.ssh/authorized_keys
chown coconut:coconut /home/coconut/.ssh/authorized_keys
chmod 0600 /home/coconut/.ssh/authorized_keys

if ! blkid /dev/disk/by-id/scsi-0DO_Volume_website | grep --quiet ext4; then
  # format the disk (danger!)
  mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_website
fi

# Mount the website volume
mkdir -p /mnt/website
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_website /mnt/website
echo /dev/disk/by-id/scsi-0DO_Volume_website  /mnt/website ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab

mkdir -p /mnt/website/binary
chown -R coconut:coconut /mnt/website

if ! blkid /dev/disk/by-id/scsi-0DO_Volume_database | grep --quiet ext4; then
  # format the disk (danger!)
  mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_database
fi

# Mount the database volume
mkdir -p /mnt/database
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_database /mnt/database
echo /dev/disk/by-id/scsi-0DO_Volume_database  /mnt/database ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab

chown -R coconut:coconut /mnt/database

# Seed the service with a dummy command to run
application_binary_path="/mnt/website/binary/api"
if [ ! -f "$application_binary_path" ]; then
  cp /root/api-dummy.bash "$application_binary_path"
  chmod 700 "$application_binary_path"
  chown coconut:coconut "$application_binary_path"
fi

cp /root/secrets-fetcher.bash /mnt/website/binary/secrets-fetcher
chmod +x /mnt/website/binary/secrets-fetcher

systemctl enable api.service
systemctl start api.service

cp /root/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

pg_data_dir="/mnt/database/postgres/data_dir"
if [ ! -d "$pg_data_dir" ]; then
  mkdir -p /mnt/database/postgres
  chown -R postgres:postgres /mnt/database/postgres
  sudo -u postgres /usr/lib/postgresql/9.5/bin/initdb -D "$pg_data_dir"
fi

chmod +x /root/generate-ssl-cert.bash

echo "all done"
