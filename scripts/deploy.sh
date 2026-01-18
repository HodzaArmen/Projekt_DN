
#!/bin/bash
set -e

echo "🚀 Deploying ToDo App to Kubernetes..."
echo ""

echo "📦 Creating namespace..."
kubectl apply -f k8s/01-namespace.yaml

echo "📦 Deploying Redis..."
kubectl apply -f k8s/02-redis-pvc.yaml
kubectl apply -f k8s/03-redis-deployment.yaml

echo "📦 Deploying Web Application..."
kubectl apply -f k8s/04-web-pvc.yaml
kubectl apply -f k8s/05-web-deployment.yaml

echo "📦 Creating Ingress..."
kubectl apply -f k8s/06-ingress.yaml

echo ""
echo "✅ Deployment complete!"
echo ""
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
echo "   kubectl get pods -n todo-app"
echo "   kubectl logs -f <pod-name> -n todo-app"
echo "   kubectl describe pod <pod-name> -n todo-app"
