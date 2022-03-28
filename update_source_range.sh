#! /bin/bash

IP_ARRAY=$(./cf_generate_array.sh | jq 'del(.[-1])')
yq < values.yaml | jq ".controller.service.loadBalancerSourceRanges = $IP_ARRAY" | yq -y
