#!/bin/sh

set -e

# TODO: resolve duplication with other dummy? Could make a template file and
# interpolate the service name

# This will play the part of the website web service when first
# provisioning the droplet. The deploy script will overwrite this
# with the real binary before long
while true; do
  echo "Dummy is live"
  sleep 5
done
