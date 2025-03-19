.PHONY: install
install:check-deps prepare
	helmfile apply
	./install.sh
	
.PHONY: uninstall
uninstall:
	helmfile destroy
	./uninstall.sh

.PHONY: prepare
prepare:
	sudo sysctl fs.inotify.max_user_watches=524288
	sudo sysctl fs.inotify.max_user_instances=512
	kind create cluster --name kind --config=kindfile.yaml || true

.PHONY: clean
clean:
	kind delete cluster -n kind

.PHONY: test
test:
	curl -o /dev/null -sk https://gitlab.alpha.mylittleforge.org  -w "%{http_code}\n" --resolve gitlab.alpha.mylittleforge.org:443:172.18.0.200
	kubectl -n alpha exec test -- curl -o /dev/null -w "%{http_code}\n" -sk https://gitlab.alpha.mylittleforge.org

	curl -o /dev/null -sk https://gitlab.beta.mylittleforge.org  -w "%{http_code}\n" --resolve gitlab.beta.mylittleforge.org:443:172.18.0.201
	kubectl -n beta exec test -- curl -o /dev/null -w "%{http_code}\n" -sk https://gitlab.alpha.mylittleforge.org

.PHONY: check-deps
check-deps:
	@missing=0; \
	for cmd in kind helm helmfile kubectl; do \
	  if ! command -v $$cmd >/dev/null 2>&1; then \
	    echo "❌ Missing dependency: $$cmd"; \
	    missing=1; \
	  fi; \
	done; \
	if ! helm plugin list 2>/dev/null | grep -q diff; then \
	  echo "❌ Missing Helm plugin: diff"; \
	  echo "   👉 Install it with: helm plugin install https://github.com/databus23/helm-diff"; \
	  missing=1; \
	fi; \
	if [ $$missing -eq 1 ]; then \
	  echo "💥 One or more dependencies are missing. Please install them before continuing."; \
	  exit 1; \
	else \
	  echo "✅ All dependencies are installed."; \
	fi
