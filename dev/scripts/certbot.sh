#!/bin/sh
docker run \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /home/core:/data \
  -v $(pwd)/static-content:/var/www haocen/certbot \
    certonly --standalone  -w /var/www  --agree-tos -d $DOMAIN --email $EMAIL

