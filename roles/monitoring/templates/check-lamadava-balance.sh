#!/bin/bash

export EAS_LAMADAVA_APIK={{ lamadava_token }}

url="https://api.lamadava.com/sys/balance"
api_key=${EAS_LAMADAVA_APIK}
if [ -z "$api_key" ]; then
  echo "Set EAS_LAMADAVA_APIK env var"
  exit 1
fi

balance=$(curl -s -G "$url" --data-urlencode "access_key=$api_key" | jq -r '.amount')
balance=${balance%.*}
if [ "$balance" -le 0 ]; then
  exit 1
fi

exit $balance
