REGISTRY_DOMAIN=$1

docker run -d -p 5000:5000 --restart=always --name registry \
        -v /etc/letsencrypt:/etc/letsencrypt \
        -v $HOME:/data \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/etc/letsencrypt/live/$REGISTRY_DOMAIN/fullchain.pem \
        -e REGISTRY_HTTP_TLS_KEY=/etc/letsencrypt/live/$REGISTRY_DOMAIN/privkey.pem \
        -e REGISTRY_AUTH=htpasswd \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/data/htpasswd \
        -e REGISTRY_STORAGE=gcs \
        -e REGISTRY_STORAGE_GCS_BUCKET=jf-private-docker-registry \
        -e REGISTRY_STORAGE_GCS_KEYFILE=/data/gcs-key.json \
        -e REGISTRY_STORAGE_GCS_ROOTDIRECTORY=docker-registry \
        registry:2
