#!/bin/bash

# DNS-Setup für .mini.k8 Domains
# Fügt Einträge zu /etc/hosts hinzu

set -e

HOSTS_FILE="/etc/hosts"
DOMAINS=(
    "kite.mini.k8"
)

echo "🌐 Konfiguriere DNS für .mini.k8 Domains..."

# Prüfe ob bereits Einträge existieren
for domain in "${DOMAINS[@]}"; do
    if grep -q "$domain" "$HOSTS_FILE" 2>/dev/null; then
        echo "   ⚠️  $domain existiert bereits in $HOSTS_FILE"
    else
        echo "   ➕ Füge $domain hinzu..."
        echo "127.0.0.1 $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
        echo "   ✅ $domain hinzugefügt"
    fi
done

echo ""
echo "📋 Aktuelle .mini.k8 Einträge:"
grep "mini.k8" "$HOSTS_FILE" || echo "   (keine gefunden)"

echo ""
echo "✅ DNS-Konfiguration abgeschlossen!"
echo ""
echo "💡 Hinweis: Für Änderungen an /etc/hosts wird sudo benötigt"

