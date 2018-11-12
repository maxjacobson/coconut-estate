#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing api droplet"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade --yes
apt-get update
apt-get install --yes htop jq ncdu tree silversearcher-ag postgresql postgresql-contrib
apt-get autoremove --yes
curl -sSL https://agent.digitalocean.com/install.sh | sh

useradd coconut --create-home --shell /bin/bash --comment "Main user for service"
usermod -aG sudo coconut
echo "coconut ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/100-coconut

mkdir -p /home/coconut/.ssh
cp ~/.ssh/authorized_keys /home/coconut/.ssh/authorized_keys
chown coconut:coconut /home/coconut/.ssh/authorized_keys
chmod 0600 /home/coconut/.ssh/authorized_keys

# Maybe format the api volume
if ! blkid /dev/disk/by-id/scsi-0DO_Volume_api | grep --quiet ext4; then
  # format the disk (danger!)
  mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_api
fi

# Mount the api volume
mkdir -p /mnt/api
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_api /mnt/api
echo /dev/disk/by-id/scsi-0DO_Volume_api /mnt/api ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab

mkdir -p /mnt/api/binary
chown -R coconut:coconut /mnt/api

# Seed the service with a dummy command to run
application_binary_path="/mnt/api/binary/api"
if [ ! -f "$application_binary_path" ]; then
  cp /root/api-dummy.bash "$application_binary_path"
  chmod 700 "$application_binary_path"
  chown coconut:coconut "$application_binary_path"
fi

cp /root/secrets-fetcher.bash /mnt/api/binary/secrets-fetcher
chmod +x /mnt/api/binary/secrets-fetcher

systemctl enable api.service
systemctl start api.service

echo "all done"