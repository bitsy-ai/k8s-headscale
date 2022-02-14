HEADSCALE_NAMESPACE ?= "headscale"

.venv:
	python3 -m venv .venv
	.venv/bin/pip install j2cli[yaml]

k8s/configmap.yml: .venv
	.venv/bin/j2 templates/configmap.j2 -o k8s/configmap.yml

k8s/deployment.yml: .venv
	.venv/bin/j2 templates/deployment.j2 -o k8s/deployment.yml

k8s/ingress.yml: .venv
	.venv/bin/j2 templates/ingress.j2 -o k8s/ingress.yml

k8s/service.yml: .venv
	.venv/bin/j2 templates/service.j2 -o k8s/service.yml

deploy: k8s/configmap.yml k8s/deployment.yml k8s/ingress.yml k8s/service.yml
	kubectl -n $(HEADSCALE_NAMESPACE) -f k8s/configmap.yml
	kubectl -n $(HEADSCALE_NAMESPACE) -f k8s/deployment.yml
	kubectl -n $(HEADSCALE_NAMESPACE) -f k8s/service.yml
	kubectl -n $(HEADSCALE_NAMESPACE) -f k8s/ingress.yml
