#!/bin/bash

# Flux CLI Installation
# Installiert Flux CLI falls nicht vorhanden

set -e

echo "🔍 Prüfe Flux CLI Installation..."

if command -v flux &> /dev/null; then
    echo "✅ Flux CLI ist bereits installiert"
    flux --version
    exit 0
fi

echo "📦 Installiere Flux CLI..."

# Versuche Homebrew
if command -v brew &> /dev/null; then
    echo "   Verwende Homebrew..."
    brew install fluxcd/tap/flux
    flux --version
    echo "✅ Flux CLI erfolgreich installiert"
    exit 0
fi

# Fallback: Direkter Download
echo "   Lade Flux herunter..."
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

FLUX_VERSION=$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
FLUX_URL="https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_${OS}_${ARCH}.tar.gz"

echo "   Version: $FLUX_VERSION"
echo "   URL: $FLUX_URL"

mkdir -p ~/.local/bin
curl -L "$FLUX_URL" | tar -xz -C ~/.local/bin flux
chmod +x ~/.local/bin/flux

# Füge zu PATH hinzu falls nicht vorhanden
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "   Hinweis: Füge ~/.local/bin zu PATH hinzu"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.zshrc
    export PATH="$HOME/.local/bin:$PATH"
fi

flux --version
echo "✅ Flux CLI erfolgreich installiert"

