# cloud-code-server-init
Scripts to setup VSCode server with Lets Encrypt TLS on cloud instances

# GCP
- You must have set you instance to allow HTTPS traffic
- Your instance must have an external IP
- You must have 1 registered DNS zone
- You must have jq and Google Cloud SDK installed
## GCP Step
1. SSH into the instance using the ubuntu user and clone this repo
2. Login `gloud auth login`
2. Run `dns-gcp.sh`