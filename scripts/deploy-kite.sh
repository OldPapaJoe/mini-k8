#!/bin/bash

# Kite Deployment Helper
# Hilft beim Deployment und Verifizierung von Kite

set -e

echo "🪁 Kite Deployment Helper"
echo ""

# Prüfe Kubernetes-Verbindung
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes-Cluster ist nicht erreichbar"
    exit 1
fi

# Prüfe Flux
if ! command -v flux &> /dev/null; then
    echo "❌ Flux CLI ist nicht installiert"
    exit 1
fi

echo "✅ Voraussetzungen erfüllt"
echo ""

# Prüfe Flux-Status
echo "📊 Flux-Status:"
flux get sources helm | grep kite || echo "   Kite HelmRepository noch nicht synchronisiert"
echo ""

# Prüfe Kite-Deployment
echo "🔍 Prüfe Kite-Deployment..."
if kubectl get helmrelease kite -n kube-system &>/dev/null; then
    echo "   ✅ Kite HelmRelease existiert"
    flux get helmrelease kite -n kube-system
else
    echo "   ⚠️  Kite HelmRelease existiert noch nicht"
    echo "   Warte auf Flux-Synchronisation..."
fi

echo ""

# Prüfe Kite-Pods
echo "📦 Kite Pods:"
kubectl get pods -n kube-system -l app=kite || echo "   Noch keine Pods"

echo ""

# Prüfe Kite-Service
echo "🌐 Kite Service:"
kubectl get svc -n kube-system kite || echo "   Service existiert noch nicht"

echo ""

# Prüfe Ingress
echo "🔗 Kite Ingress:"
kubectl get ingress -n kube-system kite || echo "   Ingress existiert noch nicht"

echo ""

# Prüfe TLS-Zertifikat
echo "🔐 TLS-Zertifikat:"
if kubectl get certificate kite-tls -n kube-system &>/dev/null; then
    kubectl get certificate kite-tls -n kube-system
    kubectl describe certificate kite-tls -n kube-system | grep -A 5 "Status:" || true
else
    echo "   ⚠️  Zertifikat existiert noch nicht"
    echo "   Stelle sicher, dass:"
    echo "   1. cert-manager installiert ist"
    echo "   2. CA-Zertifikat generiert wurde: ./scripts/generate-ca-cert.sh"
    echo "   3. ClusterIssuer existiert: kubectl get clusterissuer ca-issuer"
fi

echo ""

# DNS-Check
echo "🌍 DNS-Check:"
if grep -q "kite.mini.k8" /etc/hosts 2>/dev/null; then
    echo "   ✅ DNS-Eintrag in /etc/hosts vorhanden"
    grep "kite.mini.k8" /etc/hosts
else
    echo "   ⚠️  DNS-Eintrag fehlt"
    echo "   Führe aus: ./scripts/setup-dns.sh"
fi

echo ""
echo "✅ Prüfung abgeschlossen!"
echo ""
echo "💡 Zugriff:"
echo "   HTTPS: https://kite.mini.k8"
echo "   Port-Forward: kubectl port-forward -n kube-system svc/kite 8080:8080"

