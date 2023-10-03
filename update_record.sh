#!/bin/bash -xe
#
# This script deliver dynamic DNS in Cloudflare.

DATE=$(date "+%Y/%m/%d %H:%M:%S")

# Please edit the following config file for your environment.
CURRENT=$(cd $(dirname $0);pwd)
CONFIG_FILE=${1:-${CURRENT}/.ddns-cloudflare.conf}

if [ ! -r "${CONFIG_FILE}" ]; then
    echo "${CONFIG_FILE} does not exist or unreadable." 1>&2
    exit 1
fi

source $CONFIG_FILE

# Check required commands.
curl --request PATCH \
  --url https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID} \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${API_TOKEN}" \
  --header "X-Auth-Email: ${AUTH_EMAIL}" \
  --data '{
  "content": "'"${NEW_RR_VALUE}"'",
  "name": "'"${HOST_NAME}"'",
  "type": "A",
  "comment": "Domain Update record '"${DATE}"'"
}'

if [ $? -eq 0 ]; then
    $LOGGER "UPSERT: ${HOST_NAME}, ${NEW_RR_VALUE}"
fi
