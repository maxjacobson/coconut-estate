#!/bin/bash

set -e

group="$1"
shift
shift

# secrets_host="http://secrets.coconutestate.top"

json="$(curl --silent --fail "${secrets_host}/secrets?group=$group")"

for line in $(echo "$json" | jq --compact-output '.secrets[]'); do
  name="$(echo "$line" | jq --raw-output '.name')"
  value="$(echo "$line" | jq --raw-output '.value')"

  export "$name"="$value"
done

"$@"
