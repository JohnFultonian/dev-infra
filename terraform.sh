PUB_KEY="id_rsa.pub"
PRIV_KEY="id_rsa"
SSH_PRINT=$(ssh-keygen -l -f $HOME/.ssh/$PUB_KEY -E md5 | awk '{print $2}' | sed 's/^MD5://')
DOCKER_RUN="docker run -it -w /data -v $PWD/$1:/data -v ${HOME}/.ssh:/ssh/ hashicorp/terraform"

echo $DOCKER_RUN
$DOCKER_RUN $2  \
  -var "do_token=${DO_TOKEN}" \
  -var "pub_key=/ssh/${PUB_KEY}" \
  -var "pvt_key=/ssh/${PRIV_KEY}" \
  -var "ssh_fingerprint=${SSH_PRINT}" \
  -var "agent_token=${BUILDKITE_TOKEN}"
