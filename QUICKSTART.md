# Quick Start Guide

Schnellstart-Anleitung für das Mini-Kubernetes-Setup.

## Voraussetzungen

- ✅ OrbStack mit aktiviertem Kubernetes
- ✅ kubectl konfiguriert
- ✅ Git-Repository (lokal oder GitHub)

## Installation in 5 Schritten

### 1. Flux installieren

```bash
./scripts/install-flux.sh
```

### 2. Flux Bootstrap

```bash
./scripts/bootstrap-flux.sh
```

Wähle:
- **Option 1**: GitHub-Repository (empfohlen)
- **Option 2**: Lokales Repository

### 3. Warte auf Synchronisation

```bash
# Prüfe Status
flux get sources helm
flux get kustomizations

# Warte bis alle "Ready" sind (ca. 2-5 Minuten)
watch flux get kustomizations
```

### 4. CA-Zertifikat generieren

```bash
# Warte bis cert-manager bereit ist
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s

# Generiere Zertifikat
./scripts/generate-ca-cert.sh
```

### 5. DNS konfigurieren

```bash
./scripts/setup-dns.sh
```

## Zugriff

Nach erfolgreicher Installation:

```bash
# Öffne im Browser
open https://kite.mini.k8
```

**Hinweis**: Browser-Warnung wegen selbstsigniertem Zertifikat ist normal. "Erweitert" → "Trotzdem fortfahren" klicken.

## Verifizierung

```bash
# Prüfe alle Komponenten
./scripts/deploy-kite.sh

# Oder manuell
kubectl get pods -A
flux get helmreleases
```

## Nützliche Befehle

```bash
# Flux-Status
flux get sources helm
flux get helmreleases

# Pod-Status
kubectl get pods -A

# Services
kubectl get svc -A

# Ingress
kubectl get ingress -A

# Zertifikate
kubectl get certificates -A

# Logs
kubectl logs -n kube-system -l app=kite
```

## Troubleshooting

Siehe [docs/troubleshooting.md](docs/troubleshooting.md) für Details.

## Weitere Informationen

- [Vollständige Setup-Anleitung](SETUP.md)
- [GitOps-Workflow](docs/gitops-workflow.md)
- [README](README.md)

