#!/bin/sh

# metallb provisioning
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-ip-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.0.200-172.18.0.205 # check ip range
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kind-l2-advertisement
  namespace: metallb-system
EOF


# init use cases
kubectl create namespace alpha
kubectl create namespace beta
sleep 1
kubectl apply -k alpha.ns -n alpha
sleep 1
kubectl apply -k beta.ns -n beta


# add rewrite in coredns
CONFIGMAP=$(kubectl get configmap coredns -n kube-system -o yaml)

# Ligne à injecter (échappée pour grep et sed)
REWRITE_LINE="rewrite name gitlab.alpha.mylittleforge.org cilium-gateway-gateway.alpha.svc.cluster.local"

# Vérifie si la ligne existe déjà
echo "$CONFIGMAP" | grep -qF "$REWRITE_LINE" && \
  echo "✅ Ligne déjà présente, rien à faire." && exit 0

# Sinon, injecte juste avant 'ready'
echo "$CONFIGMAP" | \
  sed "/^  Corefile: |/,/^  [^ ]/ s/^\(\s*\)ready/\1$REWRITE_LINE\n\1ready/" | \
  kubectl replace -f -

# Redémarre CoreDNS
kubectl rollout restart deployment coredns -n kube-system



# openssl s_client -connect 172.18.0.200:443 -debug