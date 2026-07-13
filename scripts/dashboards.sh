#!/usr/bin/env bash
# Opens local port-forwards to the PoC's review dashboards. Ctrl+C stops all of them.
# Nothing is exposed to the internet — each UI is reachable only on your machine.
#
#   K8s (Headlamp) : http://localhost:8081
#   ArgoCD         : https://localhost:8082   (accept the self-signed cert)
#   Grafana        : http://localhost:8083
#   Prometheus     : http://localhost:8084
#   Alertmanager   : http://localhost:8085
set -euo pipefail
export PATH="$HOME/google-cloud-sdk/bin:$HOME/.local/bin:$PATH"

pids=()
cleanup() { echo; echo "stopping port-forwards..."; for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM

kubectl -n headlamp            port-forward svc/headlamp 8081:80                                        >/dev/null 2>&1 & pids+=($!)
kubectl -n argocd             port-forward svc/argocd-server 8082:443                                   >/dev/null 2>&1 & pids+=($!)
kubectl -n monitoring         port-forward svc/kube-prom-stack-grafana 8083:80                          >/dev/null 2>&1 & pids+=($!)
kubectl -n monitoring         port-forward svc/kube-prom-stack-kube-prome-prometheus 8084:9090          >/dev/null 2>&1 & pids+=($!)
kubectl -n monitoring         port-forward svc/kube-prom-stack-kube-prome-alertmanager 8085:9093        >/dev/null 2>&1 & pids+=($!)

cat <<'EOF'
Dashboards are up (leave this terminal open):

  K8s (Headlamp) : http://localhost:8081      (login: paste the Headlamp token)
  ArgoCD         : https://localhost:8082      (user: admin)
  Grafana        : http://localhost:8083       (user: admin / pass: poc-admin-2026)
  Prometheus     : http://localhost:8084
  Alertmanager   : http://localhost:8085

Headlamp token:   kubectl -n headlamp create token headlamp-admin
ArgoCD password:  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

Press Ctrl+C to stop.
EOF
wait
