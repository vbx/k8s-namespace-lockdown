#!/bin/sh

echo "******************************************"
echo "************* INSTALL ********************"
echo "******************************************"

# Load test case : use kpt or kubectl if you want
kpt live init kpt/metallb-system
kpt live init kpt/alpha
kpt live init kpt/beta
kpt live apply kpt/metallb-system
kpt live apply kpt/alpha
kpt live apply kpt/beta

# add rewrite in coredns
CONFIGMAP=$(kubectl get configmap coredns -n kube-system -o yaml)
REWRITE_LINE="rewrite name gitlab.alpha.mylittleforge.org cilium-gateway-gateway.alpha.svc.cluster.local"

echo "$CONFIGMAP" | grep -qF "$REWRITE_LINE" && \
  echo "✅ Line already present, nothing to do." && exit 0
echo "$CONFIGMAP" | \
  sed "/^  Corefile: |/,/^  [^ ]/ s/^\(\s*\)ready/\1$REWRITE_LINE\n\1ready/" | \
  kubectl replace -f -

kubectl rollout restart deployment coredns -n kube-system

# openssl s_client -connect 172.18.0.200:443 -debug