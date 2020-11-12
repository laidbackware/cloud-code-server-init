#!/bin/bash

set -euo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install jq if it is not already insatlled
if ! command -v jq &> /dev/null
then
    sudo apt update
    sudo apt install jq
fi

HOSTNAME=jumpbox

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Lookup first DNS zone, extract the name and remove trailing dot
DNS_ZONE=$(gcloud dns managed-zones list --format json | \
            jq .[0].dnsName |tr -d '"' )
ZONE_NAME=$(gcloud dns managed-zones list --format json | \
            jq .[0].name |tr -d '"' )
EXTERNAL_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
FQDN="${HOSTNAME}.${DNS_ZONE}"

if nslookup $FQDN > /dev/null 2>&1
then
    echo "DNS record for ${FQDN} already exists. Exiting"
    echo $FQDN | sed 's/.$//' > g;iot ${SCRIPT_DIR}/hostname
    exit 1
fi

gcloud dns record-sets transaction start --zone=$ZONE_NAME

gcloud dns record-sets transaction add "$EXTERNAL_IP"  --name="${FQDN}" \
--ttl=300  --type=A --zone=$ZONE_NAME

gcloud dns record-sets transaction execute --zone=$ZONE_NAME

echo "\nCreated record: $FQDN = $EXTERNAL_IP"
echo "Please wait a few minutes for it to propogate"

echo $FQDN | sed 's/.$//' > ${SCRIPT_DIR}/hostname

$SCRIPT_DIR/setup-code-server.sh $FQDN ubuntu