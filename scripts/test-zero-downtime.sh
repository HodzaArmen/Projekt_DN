#!/bin/bash

URL="https://todo.88.200.24.49.nip.io"
SUCCESS=0
FAIL=0

echo "🧪 Testing zero-downtime deployment"
echo "URL: $URL"
echo "Press Ctrl+C to stop"
echo ""

while true; do
  # ═════════════════════════════════════════════════════════
  # curl options: 
  #   -k: Ignoriraj SSL cert errors (staging cert)
  #   -s: Silent (no progress bar)
  #   -o /dev/null: Zavrzi response body
  #   -w "%{http_code}": Izpiši samo HTTP status code
  # ═════════════════════════════════════════════════════════
  RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" $URL 2>/dev/null)
  
  if [ "$RESPONSE" == "200" ]; then
    ((SUCCESS++))
    # \r = carriage return (overwrite ista vrstica)
    printf "\r✅ Success:  %5d | ❌ Failures: %5d" $SUCCESS $FAIL
  else
    ((FAIL++))
    # \n = nova vrstica (FAIL je pomemben, želimo ga videti!)
    printf "\n❌ FAILED!  HTTP %s | Success: %d | Failures: %d\n" "$RESPONSE" $SUCCESS $FAIL
  fi
  
  # 0.5s interval = 2 requesta/sekundo
  sleep 0.5
done
