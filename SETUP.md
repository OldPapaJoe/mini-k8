# Setup-Anleitung

Schritt-für-Schritt Anleitung zum Einrichten des Kubernetes-Clusters mit Flux und Kite.

## Voraussetzungen prüfen

```bash
# Kubernetes-Cluster verifizieren
./scripts/setup-k8s.sh

# Flux CLI installieren (falls nicht vorhanden)
./scripts/install-flux.sh
```

## Schritt 1: Flux Bootstrap

### Option A: Mit GitHub-Repository (empfohlen)

```bash
# Erstelle zuerst ein GitHub-Repository
# Dann:
./scripts/bootstrap-flux.sh
# Wähle Option 1 und gib deine GitHub-Daten ein
```

### Option B: Mit lokalem Repository

```bash
# Initialisiere Git-Repository (falls noch nicht geschehen)
git init
git add .
git commit -m "Initial commit"

# Bootstrap Flux
./scripts/bootstrap-flux.sh
# Wähle Option 2
```

## Schritt 2: Warte auf Flux-Synchronisation

Flux beginnt automatisch mit der Synchronisation. Prüfe den Status:

```bash
# Prüfe Git-Source
flux get sources git

# Prüfe Helm-Repositories
flux get sources helm

# Prüfe Kustomizations
flux get kustomizations
```

Warte bis alle Komponenten synchronisiert sind (kann einige Minuten dauern).

## Schritt 3: Prüfe Komponenten-Status

```bash
# Traefik
kubectl get pods -n ingress
kubectl get svc -n ingress

# cert-manager
kubectl get pods -n cert-manager
kubectl get clusterissuers

# Metrics Server
kubectl get pods -n kube-system -l app=metrics-server

# Kite
kubectl get pods -n kube-system -l app=kite
```

## Schritt 4: CA-Zertifikat generieren

Nachdem cert-manager installiert ist:

```bash
# Generiere CA-Zertifikat
./scripts/generate-ca-cert.sh
```

Das Script:
1. Generiert ein selbstsigniertes CA-Zertifikat
2. Erstellt den Secret im cert-manager Namespace
3. Der ClusterIssuer kann jetzt Zertifikate ausstellen

## Schritt 5: DNS konfigurieren

```bash
# Füge DNS-Einträge zu /etc/hosts hinzu
./scripts/setup-dns.sh
```

Dies fügt `127.0.0.1 kite.mini.k8` zu `/etc/hosts` hinzu.

## Schritt 6: Warte auf TLS-Zertifikat

Das Zertifikat wird automatisch von cert-manager generiert:

```bash
# Prüfe Zertifikat-Status
kubectl get certificate -n kube-system kite-tls
kubectl describe certificate -n kube-system kite-tls

# Prüfe CertificateRequest
kubectl get certificaterequests -n kube-system
```

Warte bis das Zertifikat den Status "Ready" hat.

## Schritt 7: Zugriff testen

### HTTPS (empfohlen)

```bash
# Öffne im Browser
open https://kite.mini.k8
```

**Hinweis**: Der Browser zeigt eine Warnung wegen des selbstsignierten Zertifikats. Das ist normal. Klicken Sie auf "Erweitert" → "Trotzdem fortfahren".

### Port-Forward (Fallback)

```bash
kubectl port-forward -n kube-system svc/kite 8080:8080
# Öffne http://localhost:8080
```

## Schritt 8: Verifizierung

```bash
# Verwende das Deployment-Helper-Script
./scripts/deploy-kite.sh
```

Dies prüft alle Komponenten und zeigt den Status an.

## Optional: Prometheus installieren

Falls Sie erweiterte Metriken benötigen:

1. Prometheus ist bereits in der Konfiguration enthalten
2. Warte auf automatische Installation durch Flux
3. Konfiguriere Prometheus in Kite:
   - Öffne Kite Dashboard
   - Gehe zu Cluster-Einstellungen
   - Füge Prometheus-URL hinzu: `http://prometheus.monitoring.svc.cluster.local:9090`

## Troubleshooting

Siehe [docs/troubleshooting.md](docs/troubleshooting.md) für häufige Probleme.

## Nächste Schritte

- [GitOps-Workflow](docs/gitops-workflow.md) verstehen
- Weitere Services über Flux deployen
- Monitoring und Logging einrichten

