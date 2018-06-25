#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing secrets keeper droplet"

apt-get update
apt-get upgrade --yes
apt-get update
apt-get install --yes htop jq ncdu tree silversearcher-ag nginx
apt-get autoremove --yes
curl -sSL https://agent.digitalocean.com/install.sh | sh

useradd coconut --create-home --shell /bin/bash --comment "Main user for service"
usermod -aG sudo coconut
echo "coconut ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/100-coconut

mkdir -p /home/coconut/.ssh
cp ~/.ssh/authorized_keys /home/coconut/.ssh/authorized_keys
chown coconut:coconut /home/coconut/.ssh/authorized_keys
chmod 0600 /home/coconut/.ssh/authorized_keys

if ! blkid /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper | grep --quiet ext4; then
  # format the disk (danger!)
  mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper
fi

# Mount the volume
mkdir -p /mnt/secrets-keeper
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper /mnt/secrets-keeper
echo /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper /mnt/secrets-keeper ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab
mkdir -p /mnt/secrets-keeper/secrets
chown -R coconut:coconut /mnt/secrets-keeper

# Seed the service with a dummy command to run
application_binary_path="/mnt/secrets-keeper/secrets-keeper"
if [ ! -f "$application_binary_path" ]; then
  cp /root/secrets-keeper-dummy.bash "$application_binary_path"
  chmod 700 "$application_binary_path"
  chown coconut:coconut "$application_binary_path"
fi

systemctl enable secrets-keeper.service
systemctl start secrets-keeper.service

cp /root/nginx.conf /etc/nginx/nginx.conf
nginx -t # validate configuration file
systemctl reload nginx
