# Deployment Guide

## Quick Start - Using Pre-built Images

If you want to use pre-built images from GitHub Container Registry instead of building locally:

### 1. Generate SSL Certificates
```bash
./generate-ssl-certs.sh
```

### 2. Create docker-compose.prod.yml

Create a file `docker-compose.prod.yml`:

```yaml
services:
  web:
    image: ghcr.io/hodzaarmen/projekt_dn/todo-app:latest
    environment:
      REDIS_HOST: redis
      REDIS_PORT: 6379
    depends_on:
      redis:
        condition: service_healthy
    expose:
      - "5000"
    volumes:
      - todo_db:/app/data
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000').read()"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    command: ["redis-server", "--appendonly", "yes"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    depends_on:
      web:
        condition: service_healthy
    ports:
      - "8080:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - certbot_www:/var/www/certbot:ro
      - certbot_etc:/etc/letsencrypt:ro
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    restart: unless-stopped

  certbot:
    image: certbot/certbot
    volumes:
      - certbot_www:/var/www/certbot
      - certbot_etc:/etc/letsencrypt
    entrypoint: /bin/sh -c
    command: >
      "trap exit TERM;
       while :; do
         certbot renew --webroot -w /var/www/certbot --quiet;
         sleep 12h;
       done"
    restart: unless-stopped

volumes:
  todo_db:
  redis_data:
  certbot_www:
  certbot_etc:
```

### 3. Start Services
```bash
docker compose -f docker-compose.prod.yml up -d
```

## Local Development - Building from Source

### 1. Generate SSL Certificates
```bash
./generate-ssl-certs.sh
```

### 2. Build and Start
```bash
docker compose up -d --build
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
