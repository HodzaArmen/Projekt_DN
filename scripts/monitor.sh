#!/bin/bash

watch -n 2 "
echo '╔══════════════════════════════════════════╗'
echo '║              PODS                        ║'
echo '╚══════════════════════════════════════════╝'
kubectl get pods -n todo-app -o wide

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║            SERVICES                      ║'
echo '╚══════════════════════════════════════════╝'
kubectl get svc -n todo-app

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║            INGRESS                       ║'
echo '╚══════════════════════════════════════════╝'
kubectl get ingress -n todo-app

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║      PERSISTENT VOLUME CLAIMS            ║'
echo '╚══════════════════════════════════════════╝'
kubectl get pvc -n todo-app

echo ''
echo '╔══════════════════════════════════════════╗'
echo '║       TRAEFIK SERVICE (External IP)      ║'
echo '╚══════════════════════════════════════════╝'
kubectl get svc -n traefik
"
