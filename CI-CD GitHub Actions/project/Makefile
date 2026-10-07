# Mirrors the CI stages so the pipeline can be reproduced locally
IMAGE ?= campus-grade-api
TAG   ?= local

.PHONY: install lint test build run clean
install:
	pip install -r requirements-dev.txt
lint:
	flake8 app tests
test:
	pytest
build:
	./build.sh $(TAG)
run:
	docker run --rm -p 8000:8000 -e API_KEY=local-demo-key $(IMAGE):$(TAG)
clean:
	rm -rf build .pytest_cache .coverage coverage.xml junit.xml htmlcov
