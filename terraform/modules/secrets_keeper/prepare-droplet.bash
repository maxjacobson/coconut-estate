#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing secrets keeper droplet"

apt-get update
apt-get upgrade --yes
apt-get install --yes htop jq ncdu tree
apt-get autoremove --yes

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
chown coconut:coconut /mnt/secrets-keeper

cp /root/secrets-keeper-dummy.bash /home/coconut/secrets-keeper
chmod 700 /home/coconut/secrets-keeper
chown coconut:coconut /home/coconut/secrets-keeper
systemctl enable secrets-keeper.service
systemctl start secrets-keeper.service
