#!/bin/bash
set -e

# ═════════════════════════════════════════════════════════
# PARAMETER:  Nova verzija (default: v2.0)
# UPORABA: ./rolling-update.sh v3.0
# ═════════════════════════════════════════════════════════
NEW_VERSION=${1:-v2.0}

echo "🔄 Starting rolling update to version: $NEW_VERSION"
echo ""
echo "📊 Current pods:"
kubectl get pods -n todo-app -l app=todo-web

echo ""
echo "🚀 Triggering rolling update..."

# ═════════════════════════════════════════════════════════
# kubectl set env:  Spremeni APP_VERSION env variable
# 
# ZAKAJ TO DELUJE:
# - Kubernetes vidi da se pod template spremenil
# - Sproži rolling update po strategiji (maxSurge: 1, maxUnavailable:0)
# - 1 po 1 pod se zamenja na novo verzijo
# ═════════════════════════════════════════════════════════
kubectl set env deployment/todo-web APP_VERSION=$NEW_VERSION -n todo-app

echo ""
echo "📊 Watching rollout status..."
echo "   (Pritisni Ctrl+C da prekineš watch, rollout bo tekel naprej)"

# ═════════════════════════════════════════════════════════
# kubectl rollout status:  Spremlja progress rolling update
# ZAKAJ: Vidimo v real-time kako se podi zamenjujejo
# ═════════════════════════════════════════════════════════
kubectl rollout status deployment/todo-web -n todo-app

echo ""
echo "✅ Rolling update complete!"
echo ""
echo "📊 New pods:"
kubectl get pods -n todo-app -l app=todo-web -o wide
