#!/bin/bash

# Kubernetes-Cluster-Verifizierung
# Prüft, ob Kubernetes in OrbStack läuft und konfiguriert ist

set -e

echo "🔍 Verifiziere Kubernetes-Cluster..."

# Prüfe kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl ist nicht installiert"
    exit 1
fi

# Prüfe Cluster-Verbindung
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes-Cluster ist nicht erreichbar"
    exit 1
fi

echo "✅ Kubernetes-Cluster ist erreichbar"

# Zeige Cluster-Info
echo ""
echo "📊 Cluster-Informationen:"
kubectl cluster-info

echo ""
echo "📋 Nodes:"
kubectl get nodes

echo ""
echo "📦 Namespaces:"
kubectl get namespaces

echo ""
echo "💾 Verfügbare Ressourcen:"
kubectl top nodes 2>/dev/null || echo "   (Metrics Server nicht installiert - das ist normal)"

echo ""
echo "✅ Kubernetes-Cluster ist bereit!"

