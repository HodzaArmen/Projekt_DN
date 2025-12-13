# DevOps: Automated Deployment Stack

## Pregled Projekta
Ta projekt avtomatizira namestitev full-stack spletne aplikacije **ToDo** z uporabo **Docker Compose**, **GitHub Actions CI/CD** in **TLS/HTTPS** zaščite. Aplikacijski sklad vsebuje več komponent, ki skupaj omogočajo zmogljivo in varno spletno aplikacijo.

### Komponente Aplikacijskega Skalda
1. **Web Application**: Flask aplikacija (custom Docker image) - Python spletna aplikacija za upravljanje nalog
2. **SQL Database**: SQLite baza podatkov za trajno shranjevanje nalog
3. **Cache**: Redis (Docker container) za hitrejši dostop do podatkov
4. **Reverse Proxy**: Nginx (Docker container) za usmerjanje prometa in TLS terminacijo
5. **Certificate Manager**: Certbot (Docker container) za avtomatsko obnavljanje Let's Encrypt certifikatov

### Ključne Značilnosti
- ✅ **4+ različni Docker containerji**: web, redis, nginx, certbot
- ✅ **Docker Compose**: celotni aplikacijski sklad se zažene z enim ukazom
- ✅ **Persistent Volumes**: podatki se shranjujejo v Docker volumes (todo_db, redis_data, certbot volumes)
- ✅ **Multi-stage Dockerfile**: optimiziran build proces z BuildX cache mounts
- ✅ **Minimalna končna slika**: Python Alpine image (~50MB) za produkcijo
- ✅ **GitHub Actions CI/CD**: avtomatski build, tag in publish Docker images v GitHub Container Registry
- ✅ **TLS/HTTPS**: podpora za Let's Encrypt certifikate in self-signed certifikate za lokalni razvoj
- ✅ **Health Checks**: vsi servisi imajo konfigurirane health checke
- ✅ **Security Best Practices**: non-root user, security headers, TLSv1.2+

---

## Hitri Začetek

### Predpogoji
- Docker (20.10+)
- Docker Compose (v2+)
- Git

---

### Deployment z Docker Compose

1. **Klonirajte repozitorij:**
   ```bash
   git clone https://github.com/HodzaArmen/Projekt_DN
   cd Projekt_DN
   ```

2. **Generirajte SSL certifikate za lokalni razvoj:**
   ```bash
   ./generate-ssl-certs.sh
   ```

3. **Zaženite celotni aplikacijski sklad:**
   ```bash
   docker compose up -d
   ```

4. **Preverite status servisov:**
   ```bash
   docker compose ps
   docker compose logs -f
   ```

5. **Dostop do aplikacije:**
   - HTTP: http://localhost:8080
   - HTTPS: https://localhost:443 (self-signed certifikat)

6. **Zaustavitev servisov:**
   ```bash
   docker compose down
   ```

7. **Zaustavitev in brisanje podatkov:**
   ```bash
   docker compose down -v
   ```

---

## CI/CD Pipeline

### GitHub Actions Workflow

Projekt vključuje avtomatizirano CI/CD pipeline, ki:

1. **Avtomatski Build**: 
   - Se sproži ob push na main/master ali pull requestu
   - Uporablja Docker BuildX za multi-platform builds (amd64, arm64)
   - Uporablja GitHub Actions cache za hitrejše builds

2. **Tagging Strategy**:
   - `latest` - najnovejša verzija iz main brancha
   - `<branch>-<sha>` - specifični commit
   - `v1.2.3` - semantic versioning za release tags
   - PR tags za pull requeste

3. **Publishing**:
   - Slike se avtomatsko objavijo v GitHub Container Registry (ghcr.io)
   - Dostopne na: `ghcr.io/hodzaarmen/projekt_dn/todo-app:latest`

4. **Testing**:
   - Avtomatsko testiranje deployment s Docker Compose
   - Health check validacija

### Uporaba Published Images

Za uporabo že zgrajenih slik iz registry:

```bash
docker pull ghcr.io/hodzaarmen/projekt_dn/todo-app:latest
```

Ali posodobite `docker-compose.yml`:
```yaml
web:
  image: ghcr.io/hodzaarmen/projekt_dn/todo-app:latest
  # odstranite 'build' sekcijo
```

---

## TLS/HTTPS Konfiguracija

### Lokalni Razvoj (Self-signed)

Za lokalni razvoj uporabite self-signed certifikate:

```bash
./generate-ssl-certs.sh
docker compose up -d
```

Opomba: Brskalnik bo opozoril na nezaupljiv certifikat - to je normalno za self-signed certifikate.

### Produkcija (Let's Encrypt)

Za produkcijsko okolje z Let's Encrypt certifikati:

1. **Uredite nginx konfiguracijsko datoteko** z vašo domeno
2. **Pridobite certifikat:**
   ```bash
   docker compose run --rm certbot certonly --webroot \
     -w /var/www/certbot \
     -d yourdomain.com \
     --email your-email@example.com \
     --agree-tos \
     --no-eff-email
   ```
3. **Ponovno zaženite nginx:**
   ```bash
   docker compose restart nginx
   ```

Certifikati se avtomatsko obnovijo vsakih 12 ur (preveri certbot service).

---

## Arhitektura

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTPS/HTTP
       ▼
┌─────────────┐
│    Nginx    │◄─── Let's Encrypt (Certbot)
│ (Port 443)  │
└──────┬──────┘
       │ HTTP
       ▼
┌─────────────┐      ┌─────────────┐
│  Flask Web  │─────►│    Redis    │
│ Application │      │   (Cache)   │
└──────┬──────┘      └─────────────┘
       │
       ▼
┌─────────────┐
│   SQLite    │
│  (Volume)   │
└─────────────┘
```

---

## Docker Volumes

Projekt uporablja naslednje persistent volumes:

- **todo_db**: SQLite baza podatkov z nalogami
- **redis_data**: Redis persistence (AOF)
- **certbot_www**: ACME challenge files
- **certbot_etc**: Let's Encrypt certifikati

---

## Multi-stage Build Optimization

Dockerfile uporablja multi-stage build za optimalen velikost slike:

1. **Builder Stage** (python:3.12-slim):
   - Namesti build dependencies
   - Kompajlira Python packages
   - Uporablja BuildX cache mounts za hitrejše builds

2. **Runtime Stage** (python:3.12-alpine):
   - Minimalna Alpine Linux slika (~50MB)
   - Kopira samo built artifacts
   - Non-root user za security
   - Health checks

---

## Lokalna Namestitev z Vagrant

### Vagrant Setup
1. Klonirajte repozitorij:  
   `git clone https://github.com/HodzaArmen/Projekt_DN`
2. Premaknite se v mapo projekta:  
   `cd Projekt_DN`
3. Zaženite VM preko Vagranta:  
   `vagrant up`
4. Dostop do aplikacije:  
   Odprite brskalnik in pojdite na `http://localhost:5000`
5. Vizualni prikaz aplikacije:  
<img width="755" height="398" alt="image" src="https://github.com/user-attachments/assets/3ccbe2c8-5888-47ee-a275-9e3111856b8a" />

---

### Namestitev v DigitalOcean Oblaku s Cloud-init
1. Ustvarite nov droplet in pri inicializaciji vnesite `cloud-init` YAML datoteko, ki je v repozitoriju.
2. Cloud-init bo samodejno:
   - namestil Python3, pip in Docker,
   - zagnal Redis container,
   - razpakiral ToDo aplikacijo,
   - namestil Python odvisnosti (Flask, Redis klient),
   - ustvaril systemd servis za avtomatski zagon aplikacije.
3. Dostop do aplikacije:  
   Odprite brskalnik in pojdite na `http://<IP_Dropleta>:5000`
4. Dostop do moje aplikacije (javna instanca):  
   [http://142.93.172.162:5000](http://142.93.172.162:5000)
5. Vizualni prikaz aplikacije:  
<img width="713" height="420" alt="image" src="https://github.com/user-attachments/assets/e6cdecfe-f439-4bec-b429-bee1f827690f" />

---

### Systemd Service
Aplikacija se zagnana kot **systemd service**, kar pomeni, da:
- Teče v ozadju po zagonu VM-ja.
- Samodejno se ponovno zažene ob morebitnem crashu.
- Zažene se z uporabnikom root in deluje v delovni mapi `/opt/todo_app/ToDo`.

---

## Člani Skupine
- Armen Hodža 
- Žan Luka Hojnik  

---

## Namen Projekta
Cilj projekta je pokazati avtomatizacijo postavitve več-komponentnega spletnega sklada (HTTP server, aplikacija, SQL baza, cache) tako lokalno kot v oblaku, z uporabo modernih DevOps orodij (Vagrant in cloud-init), ter omogočiti hitro in reproducibilno postavitev za razvoj in testiranje.
