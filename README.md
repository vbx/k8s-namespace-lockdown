# 🔒 Namespace Confinement and Internal Routing via an API Gateway

This project demonstrates:

- **Blocking outbound (egress) traffic** from Kubernetes pods (confinement).
- **Internally routing traffic** through a **dedicated API Gateway**, replacing direct pod-to-pod communication (reusing gateways internally).
- **Reusing public domain names** by resolving them to internal services (since egress is forbidden).

---

## 🧱 Kubernetes Components Used

1. **Cilium Policies**: eBPF-based network policies for fine-grained control of traffic between pods and to external destinations.
2. **API Gateway**: Acts as an intermediary to route internal requests as if they were going to external services.
3. **DNS Rewrite via CoreDNS**: Allows redirecting DNS queries to internal IPs.

---

## 🧪 Kind Demo

If you use `mise`, install the declared tools first:

```bash
mise install
```

```bash
make install   # Creates the Kind cluster, bootstraps CRDs, then runs Skaffold
make test      # Runs tests to validate routing and network rules
make clean     # Deletes all created resources
```

The local workflow is driven by Skaffold:

- Helm releases install the platform components: Cilium, MetalLB, cert-manager and Capsule.
- Raw Kubernetes manifests from `manifests/` install the demo resources for `alpha`, `beta` and MetalLB config.
- `scripts/install.sh` only patches CoreDNS for the internal DNS rewrite.

Useful direct commands:

```bash
skaffold run -m platform
skaffold run -m demo
skaffold delete -m demo
skaffold delete -m platform
```
