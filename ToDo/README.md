# Zaženi cert-generator (samo 1×)
docker compose up certgen

# Zaženi celoten stack
docker compose up --build

# Odpri
https://localhost:8443
Klikni Advanced → Proceed (self-signed cert)

# Stop
docker compose down -v 