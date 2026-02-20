#!/bin/sh
set -e

echo "Renewing certificates..."
docker compose run --rm certbot certonly \
    --webroot \
    -w /var/www/certbot \
    --non-interactive \
    --agree-tos \
    --force-renewal \
    -d "$SUB_DOMAIN"

echo "Reloading nginx..."
docker compose exec nginx nginx -s reload

echo "Done."
