#!/bin/sh
docker run \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /home/core:/data \
  -v $(pwd)/static-content:/var/www haocen/certbot \
    certonly --standalone  -w /var/www  --agree-tos -d $DOMAIN --email $EMAIL


echo "Certificate provisioned, starting registry ....."

docker run -d -p 443:5000 --restart=always --name registry \
        -v /etc/letsencrypt:/etc/letsencrypt \
        -v $HOME:/data \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/etc/letsencrypt/live/$DOMAIN/fullchain.pem \
        -e REGISTRY_HTTP_TLS_KEY=/etc/letsencrypt/live/$DOMAIN/privkey.pem \
        -e REGISTRY_AUTH=htpasswd \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/data/htpasswd \
        -e REGISTRY_STORAGE=gcs \
        -e REGISTRY_STORAGE_GCS_BUCKET=jf-private-docker-registry \
        -e REGISTRY_STORAGE_GCS_KEYFILE=/data/gcs-key.json \
        -e REGISTRY_STORAGE_GCS_ROOTDIRECTORY=docker-registry \
        registry:2
