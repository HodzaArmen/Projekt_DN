# Deployment Guide

## Quick Start - Using Pre-built Images

If you want to use pre-built images from GitHub Container Registry instead of building locally:

### 1. Generate SSL Certificates
```bash
./generate-ssl-certs.sh
```

### 2. Start Services with Pre-built Image

Use the production compose override that's already included in the repository:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Or use the Makefile:

```bash
make up-prod
```

This will use the pre-built image from `ghcr.io/hodzaarmen/projekt_dn/todo-app:latest` instead of building locally.

## Local Development - Building from Source

### 1. Generate SSL Certificates
```bash
./generate-ssl-certs.sh
```

### 2. Build and Start
```bash
docker compose up -d --build
```

Or use the Makefile:

```bash
make up
```

### 3. View Logs
```bash
docker compose logs -f
```

### 4. Check Status
```bash
docker compose ps
```

## Production Deployment with Let's Encrypt

### 1. Update Nginx Configuration

Edit `nginx/default.conf` and replace `server_name _;` with your actual domain:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

### 2. Initial Setup (HTTP Only)

Comment out HTTPS server block temporarily, start services:
```bash
docker compose up -d
```

### 3. Obtain Let's Encrypt Certificate

```bash
docker compose run --rm certbot certonly --webroot \
  -w /var/www/certbot \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email
```

### 4. Update Nginx Configuration

Uncomment HTTPS server block and update certificate paths:
```nginx
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```

### 5. Restart Nginx

```bash
docker compose restart nginx
```

## Maintenance Commands

### View logs
```bash
docker compose logs -f [service_name]
```

### Restart a service
```bash
docker compose restart [service_name]
```

### Stop all services
```bash
docker compose down
```

### Stop and remove volumes (DATA LOSS!)
```bash
docker compose down -v
```

### Update to latest images
```bash
docker compose pull
docker compose up -d
```

## Troubleshooting

### Service won't start
```bash
docker compose logs [service_name]
```

### Health check fails
```bash
docker compose ps
docker inspect [container_name]
```

### Reset everything
```bash
docker compose down -v
rm -rf nginx/ssl
./generate-ssl-certs.sh
docker compose up -d --build
```

## Monitoring

### Check resource usage
```bash
docker stats
```

### Check disk usage
```bash
docker system df
docker volume ls
```

### Backup volumes
```bash
docker run --rm -v todo_db:/data -v $(pwd):/backup alpine tar czf /backup/todo_db_backup.tar.gz -C /data .
```

### Restore volumes
```bash
docker run --rm -v todo_db:/data -v $(pwd):/backup alpine tar xzf /backup/todo_db_backup.tar.gz -C /data
```
