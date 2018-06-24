#!/bin/sh

set -e

# This will play the part of the secrets-keeper web service when first
# provisioning the droplet. The deploy script will overwrite this
# with the real binary before long
while true; do
  echo "Dummy is live"
  sleep 5
done
