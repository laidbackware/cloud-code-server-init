#!/bin/bash
# Script to set VS Code server
# The FQDN of the server must be passed in, cannot be an IP address
# The user used to start the services must also be passed in.
# Usage `setup-code-server.sh jump.domain.com ubuntu`

set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

if [[ $# -ne 2 ]]; then
  echo "You must pass in FQDN and username"
  echo "Usage: setup-code-server.sh jump.domain.com ubuntu"
  exit
fi

FQDN=$1
USERNAME=$2

# Install caddy if it is not already insatlled
if ! command -v caddy &> /dev/null
then
    echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | tee -a /etc/apt/sources.list.d/caddy-fury.list
    apt update
    apt install caddy
fi

# Install jq if it is not already insatlled
if ! command -v jq &> /dev/null
then
    sudo apt update
    sudo apt install jq
fi

# Setup Caddy to proxy FQDN to code-server
cat >/etc/caddy/Caddyfile <<EOL
$FQDN

reverse_proxy 127.0.0.1:8080
EOL

systemctl reload caddy

curl -fsSL https://code-server.dev/install.sh | sh

systemctl enable --now code-server@$USERNAME

PASSWORD=cat /home/${USERNAME}/.config/code-server/config.yaml |grep password: |sed s/password://
echo "\n\n Your password is:$PASSWORD"

echo "\nYou URL is: https://$FQDN"