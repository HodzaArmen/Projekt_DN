#!/bin/bash
set -e

COLOR=${1}

if [ -z "$COLOR" ]; then
  echo "Usage: $0 <blue|green>"
  echo ""
  echo "Current active version:"
  kubectl get service todo-web -n todo-app -o jsonpath='{.spec.selector.version}'
  echo ""
  exit 1
fi

if [[ "$COLOR" != "blue" && "$COLOR" != "green" ]]; then
  echo "❌ Error: Color must be 'blue' or 'green'"
  exit 1
fi

echo "🔍 Checking if $COLOR deployment exists..."
if !  kubectl get deployment todo-web-$COLOR -n todo-app &>/dev/null; then
  echo "❌ Error:  Deployment 'todo-web-$COLOR' not found!"
  echo ""
  echo "Deploy it first:"
  echo "  kubectl apply -f k8s/05-web-deployment-$COLOR.yaml"
  exit 1
fi

echo "📊 Checking if $COLOR pods are ready..."
READY=$(kubectl get deployment todo-web-$COLOR -n todo-app -o jsonpath='{.status.readyReplicas}')
DESIRED=$(kubectl get deployment todo-web-$COLOR -n todo-app -o jsonpath='{.spec.replicas}')

if [ "$READY" != "$DESIRED" ]; then
  echo "⚠️  Warning: Only $READY/$DESIRED pods ready!"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ !  $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

echo "🚀 Switching service to $COLOR..."
kubectl patch service todo-web -n todo-app -p "{\"spec\":{\"selector\":{\"version\":\"$COLOR\"}}}"

echo ""
echo "✅ Successfully switched to $COLOR!"
echo ""
echo "📊 Verify:"
echo "  curl -k https://todo.88.200.24.49.nip.io/health | jq .version"
echo ""
echo "Current service selector:"
kubectl get service todo-web -n todo-app -o jsonpath='{.spec.selector}'
echo ""
