#!/bin/bash

exec &> >(tee /var/log/prepare-droplet.log | logger --tag prepare-droplet --stderr 2>/dev/console)

set -ex

echo "Preparing bastion droplet"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade --yes
apt-get update
apt-get install --yes htop jq ncdu tree silversearcher-ag
apt-get autoremove --yes
curl -sSL https://agent.digitalocean.com/install.sh | sh

useradd coconut --create-home --shell /bin/bash --comment "Main user for service"
usermod -aG sudo coconut
echo "coconut ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/100-coconut

mkdir -p /home/coconut/.ssh
cp ~/.ssh/authorized_keys /home/coconut/.ssh/authorized_keys
chown coconut:coconut /home/coconut/.ssh/authorized_keys
chmod 0600 /home/coconut/.ssh/authorized_keys

echo "all done"
