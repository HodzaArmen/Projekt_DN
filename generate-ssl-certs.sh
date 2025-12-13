#!/bin/bash
# Generate self-signed SSL certificates for local development

set -e

CERT_DIR="./nginx/ssl"
mkdir -p "$CERT_DIR"

echo "Generating self-signed SSL certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/key.pem" \
  -out "$CERT_DIR/cert.pem" \
  -subj "/C=SI/ST=Slovenia/L=Ljubljana/O=DevOps/CN=localhost"

echo "Self-signed certificates generated in $CERT_DIR"
echo "These are for local development only!"
