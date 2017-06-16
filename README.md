# Dev Infra
Automated provisioning of my development environment.

Currently makes too many assumptions to be generically useful but maybe handy as an example if you want to roll your own.

## Project Goal
Run a script, get a dev environment (currently just build agent and private docker hub for build artifacts)

## Requirements / Assumptions
- Docker
- Vault CLI tools
- Vault server
- Vault secrets (See terraform.sh)
- Google cloud storage to be used for private docker hub
- Build agent uses buildkite
- DNSimple used for DNS entries
- Certbot/Letsencrypt for HTTPS certificates

## Includes
- Build agent
- Private docker hub
- DNS entries for private docker hub
