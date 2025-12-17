#!/bin/bash

# Flux Bootstrap Script
# Bootstrapt Flux in den Kubernetes-Cluster

set -e

echo "🚀 Bootstrap Flux GitOps..."

# Prüfe ob Flux installiert ist
if ! command -v flux &> /dev/null; then
    echo "❌ Flux CLI ist nicht installiert"
    echo "   Führe aus: ./scripts/install-flux.sh"
    exit 1
fi

# Prüfe Kubernetes-Verbindung
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes-Cluster ist nicht erreichbar"
    exit 1
fi

echo "✅ Voraussetzungen erfüllt"
echo ""

# Frage nach GitHub-Repository oder lokal
echo "Wie möchten Sie Flux bootstrappen?"
echo "  1) GitHub-Repository (empfohlen)"
echo "  2) Lokales Repository (file://)"
read -p "Wahl [1-2]: " choice

case $choice in
    1)
        read -p "GitHub Username: " GITHUB_USER
        read -p "Repository Name [mini-k8]: " REPO_NAME
        REPO_NAME=${REPO_NAME:-mini-k8}
        read -p "Branch [main]: " BRANCH
        BRANCH=${BRANCH:-main}
        
        echo ""
        echo "📦 Bootstrappe Flux mit GitHub..."
        flux bootstrap github \
            --owner="$GITHUB_USER" \
            --repository="$REPO_NAME" \
            --branch="$BRANCH" \
            --path=clusters/orbstack \
            --personal
        ;;
    2)
        REPO_PATH=$(pwd)
        read -p "Branch [main]: " BRANCH
        BRANCH=${BRANCH:-main}
        
        echo ""
        echo "📦 Bootstrappe Flux mit lokalem Repository..."
        flux bootstrap git \
            --url="file://$REPO_PATH" \
            --branch="$BRANCH" \
            --path=clusters/orbstack
        ;;
    *)
        echo "❌ Ungültige Wahl"
        exit 1
        ;;
esac

echo ""
echo "✅ Flux Bootstrap abgeschlossen!"
echo ""
echo "📊 Prüfe Flux-Status:"
flux get sources git
flux get sources helm

