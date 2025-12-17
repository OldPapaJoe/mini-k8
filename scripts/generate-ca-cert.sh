#!/bin/bash

# Generiert CA-Zertifikat für cert-manager
# Erstellt selbstsigniertes CA-Zertifikat für lokale Entwicklung

set -e

CERT_DIR="/tmp/ca-cert"
SECRET_NAME="ca-key-pair"
NAMESPACE="cert-manager"

echo "🔐 Generiere CA-Zertifikat für cert-manager..."

# Erstelle temporäres Verzeichnis
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Generiere CA-Private Key
echo "   Generiere CA-Private Key..."
openssl genrsa -out ca.key 2048

# Generiere CA-Zertifikat (gültig für 1 Jahr)
echo "   Generiere CA-Zertifikat..."
openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
  -subj "/CN=mini-k8-ca/O=mini-k8"

# Base64 encodieren
CA_CRT=$(cat ca.crt | base64 | tr -d '\n')
CA_KEY=$(cat ca.key | base64 | tr -d '\n')

# Erstelle Secret-Manifest
cat > ca-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $NAMESPACE
type: Opaque
data:
  tls.crt: $CA_CRT
  tls.key: $CA_KEY
EOF

echo "   ✅ CA-Zertifikat generiert"
echo ""

# Prüfe ob cert-manager bereits installiert ist
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "📦 cert-manager Namespace existiert, warte auf Pods..."
    if kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n $NAMESPACE --timeout=60s 2>/dev/null; then
        echo "   ✅ cert-manager ist bereit"
        echo ""
        echo "🔐 Erstelle Secret im Cluster..."
        kubectl apply -f "$CERT_DIR/ca-secret.yaml"
        echo "   ✅ Secret erstellt"
        echo ""
        echo "✅ CA-Zertifikat ist konfiguriert!"
        echo "   Der ClusterIssuer kann jetzt Zertifikate ausstellen."
    else
        echo "   ⚠️  cert-manager Pods sind noch nicht bereit"
        echo "   Warte und versuche es erneut..."
        kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n $NAMESPACE --timeout=300s
        kubectl apply -f "$CERT_DIR/ca-secret.yaml"
        echo "   ✅ Secret erstellt"
    fi
else
    echo "⚠️  cert-manager Namespace existiert noch nicht"
    echo "   Installiere cert-manager zuerst über Flux"
    echo ""
    echo "📋 Nächste Schritte:"
    echo "   1. Warte bis cert-manager installiert ist:"
    echo "      kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n $NAMESPACE --timeout=300s"
    echo ""
    echo "   2. Führe dieses Script erneut aus:"
    echo "      ./scripts/generate-ca-cert.sh"
    echo ""
    echo "   Oder erstelle den Secret manuell:"
    echo "      kubectl apply -f $CERT_DIR/ca-secret.yaml"
fi

echo ""
echo "💾 Zertifikat gespeichert in: $CERT_DIR"

