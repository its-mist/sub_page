#!/bin/sh
set -e

if [ -z "$SUB_DOMAIN" ]; then
    echo "ERROR: SUB_DOMAIN is not set"
    exit 1
fi

if [ -d "/etc/letsencrypt/live/$SUB_DOMAIN" ]; then
    echo "Certificates for $SUB_DOMAIN already exist, skipping..."
    exit 0
fi

echo "Obtaining SSL certificate for $SUB_DOMAIN..."

EMAIL_ARG="--register-unsafely-without-email"
if [ -n "$CERTBOT_EMAIL" ]; then
    EMAIL_ARG="--email $CERTBOT_EMAIL"
fi

certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    $EMAIL_ARG \
    -d "$SUB_DOMAIN"

echo "Certificate obtained successfully."
