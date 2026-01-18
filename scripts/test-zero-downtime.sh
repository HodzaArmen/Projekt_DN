#!/bin/bash

URL="https://todo.88.200.24.49.nip.io"
SUCCESS=0
FAIL=0

echo "🧪 Testing zero-downtime deployment"
echo "URL: $URL"
echo "Press Ctrl+C to stop"
echo ""

while true; do
  RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" $URL 2>/dev/null)
  
  if [ "$RESPONSE" == "200" ]; then
    ((SUCCESS++))
    printf "\r✅ Success:  %5d | ❌ Failures: %5d" $SUCCESS $FAIL
  else
    ((FAIL++))
    printf "\n❌ FAILED!  HTTP %s | Success: %d | Failures: %d\n" "$RESPONSE" $SUCCESS $FAIL
  fi
  
  sleep 0.5
done
