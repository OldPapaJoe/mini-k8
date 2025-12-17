# Troubleshooting

Häufige Probleme und Lösungen.

## Kubernetes-Cluster

### Cluster nicht erreichbar

```bash
# Prüfe OrbStack-Status
# Stelle sicher, dass Kubernetes in OrbStack aktiviert ist

# Prüfe kubectl-Konfiguration
kubectl config current-context
kubectl config get-contexts
```

### Nodes nicht Ready

```bash
# Prüfe Node-Status
kubectl get nodes
kubectl describe node <node-name>

# Prüfe Pods im kube-system Namespace
kubectl get pods -n kube-system
```

## Flux

### Flux CLI nicht gefunden

```bash
# Installiere Flux
./scripts/install-flux.sh

# Oder mit Homebrew
brew install fluxcd/tap/flux
```

### Bootstrap schlägt fehl

```bash
# Prüfe Kubernetes-Verbindung
kubectl cluster-info

# Prüfe GitHub-Zugriff
gh auth status

# Für lokales Repository: Stelle sicher, dass der Pfad korrekt ist
```

### Flux synchronisiert nicht

Siehe [GitOps-Workflow](gitops-workflow.md) für Details.

## Ingress & TLS

### Traefik nicht erreichbar

```bash
# Prüfe Traefik-Status
kubectl get pods -n ingress
kubectl get svc -n ingress

# Prüfe LoadBalancer-IP
kubectl get svc traefik -n ingress

# Für OrbStack: IP sollte 127.0.0.1 sein
```

### DNS-Auflösung funktioniert nicht

```bash
# Prüfe /etc/hosts
cat /etc/hosts | grep mini.k8

# Füge manuell hinzu
sudo ./scripts/setup-dns.sh

# Teste DNS-Auflösung
ping -c 1 kite.mini.k8
```

### TLS-Zertifikat-Fehler

```bash
# Prüfe cert-manager
kubectl get pods -n cert-manager
kubectl get clusterissuers

# Prüfe Certificates
kubectl get certificates -A
kubectl describe certificate kite-tls -n kube-system

# Prüfe CertificateRequests
kubectl get certificaterequests -A

# Generiere CA-Zertifikat neu falls nötig
./scripts/generate-ca-cert.sh
```

### Browser zeigt Zertifikat-Warnung

Das ist normal für selbstsignierte Zertifikate:

1. **Chrome/Edge**: Klicken Sie auf "Erweitert" → "Trotzdem fortfahren"
2. **Firefox**: Klicken Sie auf "Erweitert" → "Risiko akzeptieren und fortfahren"
3. **Safari**: Klicken Sie auf "Weiter" → "Trotzdem öffnen"

Alternativ können Sie das CA-Zertifikat in den Browser importieren.

## Kite Dashboard

### Kite nicht erreichbar

```bash
# Prüfe Kite-Status
kubectl get pods -n kube-system -l app=kite
kubectl logs -n kube-system -l app=kite

# Prüfe Service
kubectl get svc -n kube-system kite

# Port-Forward als Fallback
kubectl port-forward -n kube-system svc/kite 8080:8080
```

### Metriken werden nicht angezeigt

```bash
# Prüfe Metrics Server
kubectl get pods -n kube-system -l app=metrics-server
kubectl top nodes
kubectl top pods

# Prüfe Prometheus (falls installiert)
kubectl get pods -n monitoring -l app=prometheus
kubectl get svc -n monitoring prometheus

# Prüfe Kite-Konfiguration
kubectl get configmap -n kube-system kite -o yaml
```

## Ressourcen

### Zu wenig RAM

```bash
# Prüfe Ressourcenverbrauch
kubectl top nodes
kubectl top pods -A

# Deaktiviere Prometheus falls nicht benötigt
# Entferne prometheus aus clusters/orbstack/apps/kustomization.yaml
```

### Pods werden evicted

```bash
# Prüfe Node-Ressourcen
kubectl describe node

# Prüfe Events
kubectl get events --sort-by='.lastTimestamp'

# Reduziere Ressourcenlimits in HelmRelease-Values
```

## Allgemeine Debugging-Befehle

```bash
# Alle Pods
kubectl get pods -A

# Alle Services
kubectl get svc -A

# Alle Ingresses
kubectl get ingress -A

# Events
kubectl get events -A --sort-by='.lastTimestamp'

# Logs für alle Flux-Komponenten
kubectl logs -n flux-system -l app=source-controller
kubectl logs -n flux-system -l app=helm-controller
kubectl logs -n flux-system -l app=kustomize-controller
```

## Hilfe erhalten

- [Flux Dokumentation](https://fluxcd.io/docs/)
- [Kite GitHub Issues](https://github.com/zxh326/kite/issues)
- [Traefik Dokumentation](https://doc.traefik.io/traefik/)
- [cert-manager Dokumentation](https://cert-manager.io/docs/)

