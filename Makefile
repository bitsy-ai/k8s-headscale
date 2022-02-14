HEADSCALE_NAMESPACE ?= headscale
ENV_FILE ?= .env/.sandbox
.venv:
	python3 -m venv .venv
	.venv/bin/pip install j2cli[yaml]

clean:
	rm -rf k8s/
	mkdir k8s
	touch k8s/.gitkeep

k8s/config.yml:
	.venv/bin/j2 templates/config.j2 --filters=filters.py -o k8s/config.yml

k8s/sa.yml: .venv
	.venv/bin/j2 templates/sa.j2 --filters=filters.py -o k8s/sa.yml

k8s/deployment.yml: .venv
	.venv/bin/j2 templates/deployment.j2 --filters=filters.py -o k8s/deployment.yml

k8s/ingress.yml: .venv
	.venv/bin/j2 templates/ingress.j2 --filters=filters.py -o k8s/ingress.yml

k8s/service.yml: .venv
	.venv/bin/j2 templates/service.j2 --filters=filters.py -o k8s/service.yml

render: clean k8s/deployment.yml k8s/ingress.yml k8s/service.yml k8s/sa.yml k8s/config.yml

deploy: render
	kubectl -n $(HEADSCALE_NAMESPACE) apply -f k8s/config.yml
	kubectl -n $(HEADSCALE_NAMESPACE) apply -f k8s/sa.yml
	kubectl -n $(HEADSCALE_NAMESPACE) apply -f k8s/deployment.yml
	kubectl -n $(HEADSCALE_NAMESPACE) apply -f k8s/service.yml
	kubectl -n $(HEADSCALE_NAMESPACE) apply -f k8s/ingress.yml

clean-k8s-ns:
	kubectl delete all --all -n $(HEADSCALE_NAMESPACE)
env:
	shdotenv --env $(ENV_FILE)