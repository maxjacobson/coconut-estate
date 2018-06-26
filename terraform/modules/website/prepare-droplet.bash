#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing website droplet"

sudo add-apt-repository --yes ppa:certbot/certbot
apt-get update
apt-get upgrade --yes
apt-get update
apt-get install --yes htop jq ncdu tree silversearcher-ag python-certbot-nginx
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

# Mount the volume
mkdir -p /mnt/website
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_website /mnt/website
echo /dev/disk/by-id/scsi-0DO_Volume_website  /mnt/website ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab
chown -R coconut:coconut /mnt/website

# Seed the service with a dummy command to run
application_binary_path="/mnt/website/website"
if [ ! -f "$application_binary_path" ]; then
  cp /root/website-dummy.bash "$application_binary_path"
  chmod 700 "$application_binary_path"
  chown coconut:coconut "$application_binary_path"
fi

mkdir -p /home/coconut/website/assets
chown -R coconut:coconut /home/coconut/website

systemctl enable website.service
systemctl start website.service

chmod +x /root/generate-ssl-cert.bash

echo "all done"
