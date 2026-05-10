#!/bin/sh
set -eu

echo "******************************************"
echo "************ BOOTSTRAP CRDS **************"
echo "******************************************"

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml

helm repo add projectcapsule https://projectcapsule.github.io/charts >/dev/null 2>&1 || true
helm repo update projectcapsule
helm show crds projectcapsule/capsule --version 0.12.4 | kubectl apply -f -
