#!/bin/sh

cat <<EOF | kubectl delete -f -
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

kubectl delete -k alpha.ns -n alpha
kubectl delete -k beta.ns -n beta

