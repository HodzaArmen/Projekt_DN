#!/bin/bash

# Exit on any error
set -e

echo "🚀 Deploying ToDo App to Kubernetes..."
echo ""

# ═════════════════════════════════════════════════════════
# KORAK 1: Ustvari namespace
# ZAKAJ: Vse ostalo bo v tem namespace
# ═════════════════════════════════════════════════════════
echo "📦 Creating namespace..."
kubectl apply -f k8s/01-namespace.yaml

# ═════════════════════════════════════════════════════════
# KORAK 2: Deploy Redis (storage + deployment)
# ZAKAJ VRSTNI RED: PVC mora obstajati PREDEN deployment referencira
# ═════════════════════════════════════════════════════════
echo "📦 Deploying Redis..."
kubectl apply -f k8s/02-redis-pvc.yaml
kubectl apply -f k8s/03-redis-deployment.yaml

# ═════════════════════════════════════════════════════════
# KORAK 3: Deploy Web Application
# ═════════════════════════════════════════════════════════
echo "📦 Deploying Web Application..."
kubectl apply -f k8s/04-web-pvc.yaml
kubectl apply -f k8s/05-web-deployment.yaml

# ═════════════════════════════════════════════════════════
# KORAK 4: Create Ingress (vhod v app)
# ═════════════════════════════════════════════════════════
echo "📦 Creating Ingress..."
kubectl apply -f k8s/06-ingress.yaml

echo ""
echo "✅ Deployment complete!"
echo ""

# ═════════════════════════════════════════════════════════
# KORAK 5: Wait for pods to be ready
# ZAKAJ: kubectl wait blokira dokler vsi podi niso ready
#        || true = ne faila če timeout (graceful)
# ═════════════════════════════════════════════════════════
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=todo-web -n todo-app --timeout=300s || true

echo ""
echo "📊 Current status:"
kubectl get all -n todo-app

echo ""
echo "🌐 Access your app at:"
echo "   https://todo.88.200.24.49.nip.io"
echo ""
echo "📝 Useful commands:"
echo "   kubectl get pods -n todo-app          # View pods"
echo "   kubectl logs -f <pod-name> -n todo-app  # View logs"
echo "   kubectl describe pod <pod-name> -n todo-app  # Debug pod"
