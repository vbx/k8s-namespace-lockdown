#!/bin/sh
set -eu

echo "******************************************"
echo "*********** PATCH COREDNS ****************"
echo "******************************************"

# add rewrite in coredns
CONFIGMAP=$(kubectl get configmap coredns -n kube-system -o yaml)
UPDATED_CONFIGMAP=$CONFIGMAP
CHANGED=0

add_rewrite() {
  REWRITE_LINE=$1

  if echo "$UPDATED_CONFIGMAP" | grep -qF "$REWRITE_LINE"; then
    echo "Line already present: $REWRITE_LINE"
    return
  fi

  UPDATED_CONFIGMAP=$(echo "$UPDATED_CONFIGMAP" | \
    sed "/^  Corefile: |/,/^  [^ ]/ s/^\(\s*\)ready/\1$REWRITE_LINE\n\1ready/")
  CHANGED=1
}

add_rewrite "rewrite name gitlab.alpha.mylittleforge.org cilium-gateway-gateway.alpha.svc.cluster.local"
add_rewrite "rewrite name gitlab.beta.mylittleforge.org cilium-gateway-gateway.beta.svc.cluster.local"

if [ "$CHANGED" -eq 0 ]; then
  echo "No CoreDNS rewrite to add."
  exit 0
fi

echo "$UPDATED_CONFIGMAP" | kubectl replace -f -

kubectl rollout restart deployment coredns -n kube-system

# openssl s_client -connect 172.18.0.200:443 -debug
