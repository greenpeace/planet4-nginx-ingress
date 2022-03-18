#! /bin/bash
IP_ARRAY_4="$(curl -s https://www.cloudflare.com/ips-v4)"
printf '['
while IFS="" read -r p || [ -n "$p" ]
do
  printf '"%s", ' "$p"
done <<< $IP_ARRAY_4
printf '""]'