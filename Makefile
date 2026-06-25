.PHONY: install
install: check-deps prepare
	skaffold run -m demo

.PHONY: uninstall
uninstall:
	skaffold delete -m demo

.PHONY: prepare
prepare:
	@if kind get clusters | grep -q "^kind$$"; then \
		echo "ℹ️ Cluster 'kind' already exists."; \
	else \
		kind create cluster --name kind --config=kindfile.yaml; \
	fi

.PHONY: clean
clean:
	kind delete cluster -n kind

.PHONY: test
test:
	@echo "from outside https://gitlab.alpha.mylittleforge.org ****************"
	curl -o /dev/null -sk https://gitlab.alpha.mylittleforge.org  -w "%{http_code}\n" --resolve gitlab.alpha.mylittleforge.org:443:172.18.0.200
	@echo "from inside (same namespace) ****************"
	kubectl -n alpha exec test -- curl -o /dev/null -w "%{http_code}\n" -sk https://gitlab.alpha.mylittleforge.org
	@echo "from outside https://gitlab.beta.mylittleforge.org ****************"
	curl -o /dev/null -sk https://gitlab.beta.mylittleforge.org  -w "%{http_code}\n" --resolve gitlab.beta.mylittleforge.org:443:172.18.0.201
	@echo "from inside beta to alpha: https://gitlab.alpha.mylittleforge.org ****************"
	kubectl -n beta exec test -- curl -o /dev/null -w "%{http_code}\n" -sk https://gitlab.alpha.mylittleforge.org

.PHONY: check-deps
check-deps:
	@missing=0; \
	for cmd in kind helm kubectl skaffold; do \
	  if ! command -v $$cmd >/dev/null 2>&1; then \
	    echo "❌ Missing dependency: $$cmd"; \
	    missing=1; \
	  fi; \
	done; \
	if [ $$missing -eq 1 ]; then \
	  echo "💥 One or more dependencies are missing. Please install them before continuing."; \
	  exit 1; \
	else \
	  echo "✅ All dependencies are installed."; \
	fi
