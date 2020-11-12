# cloud-code-server-init
Scripts to setup VSCode server with Lets Encrypt TLS on cloud instances

# GCP
## GCP Dependancies
- You must have set you instance to allow HTTPS traffic
- Your instance must have an external IP
- You must have 1 registered DNS zone
- You must have the Google Cloud SDK installed

## GCP Steps
1. SSH into the instance using the ubuntu user and clone this repo
2. Login `gloud auth login`
2. Run `setup-gcp.sh`