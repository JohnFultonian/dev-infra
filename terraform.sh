PUB_KEY="id_rsa.pub"
PRIV_KEY="id_rsa"
SSH_PRINT=$(ssh-keygen -l -f $HOME/.ssh/$PUB_KEY -E md5 | awk '{print $2}' | sed 's/^MD5://')
DOCKER_RUN="docker run -it -w /data -v $PWD/$1:/data -v ${HOME}/.ssh:/ssh/ hashicorp/terraform"
VAULT_READ="vault read -field=value"
#### VAULT SECRETS
# Assumes you have logged into vault and have access to the secrets

echo "Getting secrets from vault..."
echo "Getting digitalocean token..."
DO_TOKEN=$( $VAULT_READ secret/terraform_digital_ocean_api_key )
echo "Getting buildkite agent token..."
BUILDKITE_AGENT_TOKEN=$( $VAULT_READ secret/buildkite_agent_token )
echo "Getting registry google cloud storage token..."
REGISTRY_GCS_TOKEN=$( $VAULT_READ secret/registry_gcs_key )
echo "Getting registry htpasswd..."
REGISTRY_HTPASSWD=$( $VAULT_READ secret/registry_htpasswd )
echo "Getting dnsimple api token..."
DNSIMPLE_TOKEN=$( $VAULT_READ secret/dnsimple_token )
echo "Getting dnsimple account id..."
DNSIMPLE_ACCOUNT=$( $VAULT_READ secret/dnsimple_account )
echo "Getting bitbucket secret key..."
BITBUCKET_RSA=$( $VAULT_READ secret/bitbucket_rsa )
echo "Done! Executing terraform"

$DOCKER_RUN $2  \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=/ssh/${PUB_KEY}" \
  -var "pvt_key=/ssh/${PRIV_KEY}" \
  -var "ssh_fingerprint=${SSH_PRINT}" \
  -var "registry_gcs_token='${REGISTRY_GCS_TOKEN}'" \
  -var "registry_htpasswd='${REGISTRY_HTPASSWD}'" \
  -var "dnsimple_token=${DNSIMPLE_TOKEN}" \
  -var "dnsimple_account=${DNSIMPLE_ACCOUNT}" \
  -var "bitbucket_rsa=${BITBUCKET_RSA}" \
  -var "bitbucket_rsa_pub=${BITBUCKET_RSA_PUB}" \
  -var "agent_token=${BUILDKITE_AGENT_TOKEN}"
