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

```bash
make install   # Installs all components (Cilium, API Gateway, etc.)
make test      # Runs tests to validate routing and network rules
make clean     # Deletes all created resources
