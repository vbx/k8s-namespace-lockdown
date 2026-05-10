#!/bin/sh
set -eu

if ! kubectl get configmap coredns -n kube-system >/dev/null 2>&1; then
  exit 0
fi

CONFIGMAP=$(kubectl get configmap coredns -n kube-system -o yaml)
UPDATED_CONFIGMAP=$CONFIGMAP
CHANGED=0

remove_rewrite() {
  REWRITE_LINE=$1

  if ! echo "$UPDATED_CONFIGMAP" | grep -qF "$REWRITE_LINE"; then
    return
  fi

  UPDATED_CONFIGMAP=$(echo "$UPDATED_CONFIGMAP" | sed "\|$REWRITE_LINE|d")
  CHANGED=1
}

remove_rewrite "rewrite name gitlab.alpha.mylittleforge.org cilium-gateway-gateway.alpha.svc.cluster.local"
remove_rewrite "rewrite name gitlab.beta.mylittleforge.org cilium-gateway-gateway.beta.svc.cluster.local"

if [ "$CHANGED" -eq 0 ]; then
  exit 0
fi

echo "$UPDATED_CONFIGMAP" | kubectl replace -f -

kubectl rollout restart deployment coredns -n kube-system
