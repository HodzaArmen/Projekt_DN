# Automating deployment of application stacks

## Namen
Avtomatizacija postavitve TODO aplikacije z več storitvami, uporabo Docker Compose, multi-stage Docker buildov in CI/CD.

## Tehnologije
- Docker Compose
- Multi-stage Docker build za minimalno Python sliko
- GitHub Actions CI/CD za avtomatsko gradnjo in objavo slik
- TLS certifikati (self-signed)

## Servisi
- **web** – aplikacija Python/Flask
- **redis** 
- **certgen** – generira self-signed certifikate
- **nginx** 

## Struktura projekta
Projekt_DN/
- ToDo/
  - *aplikacija in Dockerfile*
- nginx/
  - *konfiguracija nginx (default.conf)*
- docker-compose.yml
  - *Docker Compose konfiguracija*
- .github/workflows/
  - *GitHub Actions CI/CD*

## Zagon aplikacije lokalno
1. Prepričaj se, da imaš nameščen Docker in Docker Compose.
2. V terminalu zaženi:
`docker compose up`
3. Dostop do aplikacije preko: `https://localhost:8443`

## CI/CD
- GitHub Actions avtomatsko gradi in push-a Docker slike (`todo-web` in `todo-worker`) na GitHub Container Registry (GHCR) ob pushu na `main` branch.
- Slike se hranijo kot `latest` tag.
