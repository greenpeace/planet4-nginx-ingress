#! /bin/bash

IP_ARRAY=$(./cf_generate_array.sh | jq 'del(.[-1])')
yq -iy ".controller.service.loadBalancerSourceRanges = $IP_ARRAY" values.yaml