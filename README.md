# Mini Kubernetes Setup mit Flux GitOps

Ein vollständiges Kubernetes-Setup auf OrbStack mit Flux GitOps, Kite Dashboard, Traefik Ingress, cert-manager und Monitoring.

## Übersicht

Dieses Repository enthält alle Konfigurationen für einen lokalen Kubernetes-Cluster auf OrbStack mit:

- **Flux GitOps**: Automatische Deployment-Verwaltung über Git
- **Kite Dashboard**: Modernes Kubernetes-Dashboard
- **Traefik Ingress**: HTTP/HTTPS-Routing
- **cert-manager**: Automatische TLS-Zertifikate
- **Metrics Server**: Grundlegende Kubernetes-Metriken
- **Prometheus** (optional): Erweiterte Metriken

## Voraussetzungen

- OrbStack installiert mit aktiviertem Kubernetes
- `kubectl` konfiguriert
- `flux` CLI installiert
- Git-Repository (lokal oder GitHub)

## Quick Start

### 1. Kubernetes verifizieren

```bash
kubectl cluster-info
kubectl get nodes
```

### 2. Flux Bootstrap

```bash
# Für GitHub-Repository
flux bootstrap github \
  --owner=<your-github-username> \
  --repository=mini-k8 \
  --branch=main \
  --path=clusters/orbstack

# Für lokales Repository (ohne GitHub)
flux bootstrap git \
  --url=file://$(pwd) \
  --branch=main \
  --path=clusters/orbstack
```

### 3. DNS-Konfiguration

```bash
./scripts/setup-dns.sh
```

Dies fügt folgende Einträge zu `/etc/hosts` hinzu:
- `127.0.0.1 kite.mini.k8`

### 4. Zugriff

Nach dem Deployment ist Kite erreichbar unter:
- **HTTPS**: `https://kite.mini.k8`
- **Fallback**: `kubectl port-forward -n kube-system svc/kite 8080:8080`

**Hinweis**: Das selbstsignierte Zertifikat wird im Browser eine Warnung anzeigen. Sie können das Zertifikat importieren oder die Warnung akzeptieren.

## Repository-Struktur

```
mini-k8/
├── clusters/
│   └── orbstack/
│       ├── flux-system/         # Flux Bootstrap-Manifeste
│       └── apps/                # App-Deployments
│           ├── traefik/         # Ingress Controller
│           ├── cert-manager/     # TLS-Zertifikate
│           ├── metrics-server/  # Kubernetes-Metriken
│           ├── prometheus/      # Erweiterte Metriken (optional)
│           └── kite/            # Kite Dashboard
├── scripts/                     # Setup-Skripte
└── docs/                        # Dokumentation
```

## Komponenten

### Flux GitOps

Verwaltet alle Deployments über Git. Änderungen werden automatisch synchronisiert.

### Traefik Ingress Controller

- Namespace: `ingress`
- Service: LoadBalancer/NodePort
- Port: 80 (HTTP), 443 (HTTPS)

### cert-manager

- Namespace: `cert-manager`
- Issuer: CA Issuer für selbstsignierte Zertifikate
- Automatische Zertifikats-Generierung und -Erneuerung

### Metrics Server

- Namespace: `kube-system`
- Bereitstellung grundlegender CPU/Memory-Metriken

### Prometheus (Optional)

- Namespace: `monitoring`
- Service: `prometheus.monitoring.svc.cluster.local:9090`
- Für erweiterte Metriken in Kite

### Kite Dashboard

- Namespace: `kube-system`
- Domain: `kite.mini.k8`
- Port: 8080
- Prometheus-Integration konfigurierbar

## Ressourcen

Optimiert für **12 GB RAM**:

- Flux: ~200-300 MB
- Traefik: ~100-200 MB
- cert-manager: ~100-150 MB
- Metrics Server: ~50-100 MB
- Prometheus (optional): ~200-500 MB
- Kite: ~100-200 MB
- **Gesamt**: ~650-1450 MB (ohne/mit Prometheus)

## GitOps-Workflow

1. Änderungen im Repository committen
2. Flux synchronisiert automatisch (Polling oder Webhook)
3. Deployments werden automatisch aktualisiert
4. Status über `flux get` oder Kite-Dashboard prüfen

## Troubleshooting

Siehe [docs/troubleshooting.md](docs/troubleshooting.md) für häufige Probleme und Lösungen.

## Weitere Informationen

- [GitOps-Workflow](docs/gitops-workflow.md)
- [Kite Dokumentation](https://github.com/zxh326/kite)
- [Flux Dokumentation](https://fluxcd.io/docs/)

