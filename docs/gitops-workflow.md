# GitOps-Workflow

Dieses Dokument beschreibt den GitOps-Workflow mit Flux.

## Übersicht

Flux überwacht das Git-Repository und synchronisiert automatisch alle Änderungen in den Kubernetes-Cluster.

## Workflow

### 1. Änderungen vornehmen

Bearbeiten Sie die Manifeste im Repository:

```bash
# Beispiel: Kite-Konfiguration ändern
vim clusters/orbstack/apps/kite/helmrelease.yaml

# Änderungen committen
git add clusters/orbstack/apps/kite/helmrelease.yaml
git commit -m "Update Kite configuration"
git push
```

### 2. Automatische Synchronisation

Flux synchronisiert automatisch:

- **Polling**: Standardmäßig alle 5 Minuten
- **Webhook**: Bei GitHub-Webhook-Events (sofort)

### 3. Status prüfen

```bash
# Prüfe Git-Sources
flux get sources git

# Prüfe Helm-Sources
flux get sources helm

# Prüfe Helm-Releases
flux get helmreleases

# Prüfe Kustomizations
flux get kustomizations
```

### 4. Logs anzeigen

```bash
# Flux Controller Logs
kubectl logs -n flux-system -l app=helm-controller

# Spezifisches HelmRelease
flux logs helmrelease kite -n kube-system
```

## Manuelle Synchronisation

Falls Sie sofort synchronisieren möchten:

```bash
# Synchronisiere alle Kustomizations
flux reconcile kustomization apps --with-source

# Synchronisiere spezifisches HelmRelease
flux reconcile helmrelease kite -n kube-system
```

## Rollback

Um eine Änderung rückgängig zu machen:

```bash
# Revert Git-Commit
git revert HEAD
git push

# Oder zu vorherigem Commit zurückkehren
git reset --hard <commit-hash>
git push --force
```

## Best Practices

1. **Immer committen und pushen**: Flux arbeitet nur mit committeden Änderungen
2. **Beschreibende Commit-Messages**: Erleichtert das Tracking von Änderungen
3. **Branches für Tests**: Verwenden Sie separate Branches für Experimente
4. **Status prüfen**: Überwachen Sie Flux-Status nach Änderungen
5. **Ressourcenlimits**: Setzen Sie immer Limits für Produktions-Workloads

## Troubleshooting

### Flux synchronisiert nicht

```bash
# Prüfe Git-Source-Status
flux get sources git

# Prüfe Logs
kubectl logs -n flux-system -l app=source-controller

# Manuelle Synchronisation erzwingen
flux reconcile source git flux-system
```

### HelmRelease schlägt fehl

```bash
# Prüfe HelmRelease-Status
flux get helmreleases

# Prüfe Logs
flux logs helmrelease <name> -n <namespace>

# Prüfe Helm-Releases direkt
helm list -A
```

### Zertifikats-Probleme

```bash
# Prüfe cert-manager
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# Prüfe CertificateRequests
kubectl get certificaterequests -A
```

