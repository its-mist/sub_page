# Remnawave Subscription Page

Standalone deployment of the Remnawave subscription page on a separate server.

## Requirements

- Clean server with Ubuntu 22.04+
- Docker and Docker Compose
- Domain with DNS A-record pointing to the server IP

## Deployment

### 1. Install Docker

```bash
curl -fsSL https://get.docker.com | sh
```

### 2. Clone the repo

```bash
git clone <repo-url> /opt/sub_page
cd /opt/sub_page
```

### 3. Configure environment

```bash
cp .env.example .env
nano .env
```

Set your values:

| Variable | Description | Example |
|---|---|---|
| `SUB_DOMAIN` | Domain for subscription page | `sub.example.com` |
| `PANEL_URL` | Public URL of the Remnawave panel | `https://panel.example.com` |
| `APP_PORT` | Internal port (default 3010) | `3010` |
| `META_TITLE` | Page title | `Remnawave Subscription` |
| `META_DESCRIPTION` | Page description | `page` |

### 4. Install Nginx and get SSL certificate

```bash
apt install -y nginx certbot python3-certbot-nginx

# Get certificate (DNS must already point to this server)
certbot certonly --standalone -d YOUR_DOMAIN
```

### 5. Configure Nginx

```bash
# Copy and edit the example config
cp nginx.conf.example /etc/nginx/sites-available/sub_page

# Replace SUB_DOMAIN with your actual domain
sed -i 's/SUB_DOMAIN/YOUR_DOMAIN/g' /etc/nginx/sites-available/sub_page

# Enable the site
ln -s /etc/nginx/sites-available/sub_page /etc/nginx/sites-enabled/

# Remove default site if it conflicts
rm -f /etc/nginx/sites-enabled/default

# Test and reload
nginx -t && systemctl reload nginx
```

### 6. Start the service

```bash
docker compose up -d
```

### 7. Verify

```bash
# Check container is running
docker compose ps

# Check logs
docker compose logs -f

# Test HTTPS
curl -I https://YOUR_DOMAIN
```

## What to change on the panel server

On the server where Remnawave panel is running, update the `.env` file to point subscriptions to the new domain:

```bash
# Edit /opt/remnawave/.env (or wherever your panel is installed)
# Change this line:
SUB_PUBLIC_DOMAIN=sub.new-domain.com

# Then restart the backend:
cd /opt/remnawave
docker compose restart remnawave
```

This ensures the panel generates subscription links with the new domain.

## Auto-renew SSL

Certbot sets up auto-renewal automatically. Verify with:

```bash
certbot renew --dry-run
```

## Update

```bash
docker compose pull
docker compose up -d
```
