#!/bin/bash

export EAS_LAMATOK_APIK={{ lamatok_token }}


url="https://api.lamatok.com/sys/balance"
api_key=${EAS_LAMATOK_APIK}
if [ -z "$api_key" ]; then
  echo "Set EAS_LAMATOK_APIK env var"
  exit 1
fi

response=$(curl -s -G "$url" --data-urlencode "access_key=$api_key")
# Check if the curl command was successful
if [ $? -ne 0 ]; then
  echo "API call failed"
  exit 1
fi

# Extract balance from the JSON response
balance=$(echo "$response" | jq -r '.amount' 2>/dev/null)
if [ -z "$balance" ]; then
  echo "Failed to parse balance from API response"
  exit 1
fi

# Remove the decimal part
balance=${balance%.*}

if ! [[ "$balance" =~ ^[0-9]+$ ]]; then
  echo "Balance is not a valid integer: $balance"
  exit 20
fi

if [ "$balance" -le 0 ]; then
  exit 1
fi

echo $balance
exit $balance
