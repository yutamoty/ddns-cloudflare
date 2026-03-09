#!/bin/bash -eu
#
# This script delivers dynamic DNS in Cloudflare.

DATE=$(date "+%Y/%m/%d %H:%M:%S")

# Load config file.
CURRENT=$(cd "$(dirname "$0")" && pwd)
CONFIG_FILE=${1:-${CURRENT}/.ddns-cloudflare.conf}

if [ ! -r "${CONFIG_FILE}" ]; then
    echo "${CONFIG_FILE} does not exist or is unreadable." 1>&2
    exit 1
fi

source "${CONFIG_FILE}"

# Validate required variables.
for var in ZONE_ID RECORD_ID API_TOKEN AUTH_EMAIL NEW_RR_VALUE HOST_NAME; do
    if [ -z "${!var:-}" ]; then
        echo "Error: ${var} is not set." 1>&2
        exit 1
    fi
done

LOGGER=${LOGGER:-echo}

# Build JSON payload safely using jq.
PAYLOAD=$(jq -n \
    --arg content "${NEW_RR_VALUE}" \
    --arg name "${HOST_NAME}" \
    --arg comment "Domain Update record ${DATE}" \
    '{content: $content, name: $name, type: "A", comment: $comment}')

# Update DNS record via Cloudflare API.
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    --request PATCH \
    --url "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${API_TOKEN}" \
    --header "X-Auth-Email: ${AUTH_EMAIL}" \
    --data "${PAYLOAD}")

if [ "${HTTP_STATUS}" -ge 200 ] && [ "${HTTP_STATUS}" -lt 300 ]; then
    ${LOGGER} "UPSERT: ${HOST_NAME}, ${NEW_RR_VALUE}"
else
    echo "Error: Cloudflare API returned HTTP ${HTTP_STATUS}" 1>&2
    exit 1
fi
