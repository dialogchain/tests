# Main Makefile for DialogChain

# Default target
.PHONY: help
help:
	@echo "DialogChain - Make Commands"
	@echo ""
	@echo "Development:"
	@echo "  make install      - Install the package in development mode"
	@echo "  make format       - Format code with black and isort"
	@echo "  make lint         - Run linters (flake8, mypy)"
	@echo ""
	@echo "Testing:"
	@echo "  make test         - Run all tests"
	@echo "  make test-unit    - Run unit tests"
	@echo "  make test-docker  - Run tests in Docker container"
	@echo "  make coverage     - Run tests with coverage report"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean        - Remove Python file artifacts"
	@echo "  make clean-all    - Remove all build and test artifacts"

# Variables
PYTHON = python3
PIP = pip

# Install the package in development mode
.PHONY: install
install:
	$(PIP) install -e .[dev]

# Format code
.PHONY: format
format:
	black .
	isort .

# Run linters
.PHONY: lint
lint:
	flake8 .
	mypy .

# Test commands
.PHONY: test test-unit test-integration test-mqtt test-http test-coverage test-docker test-docker-interactive

# Run all tests
test:
	./run_tests.sh

# Run unit tests
test-unit:
	./run_tests.sh -t unit

# Run integration tests
test-integration:
	./run_tests.sh -t integration

# Run MQTT tests
test-mqtt:
	./run_tests.sh -t mqtt

# Run HTTP tests
test-http:
	./run_tests.sh -t http

# Run tests with coverage
test-coverage:
	$(PYTHON) -m pytest --cov=../dialogchain --cov-report=term-missing -v tests/

# Run tests in Docker (non-interactive)
test-docker:
	./run_tests.sh -d

# Run tests in Docker with interactive shell
test-docker-interactive:
	docker build -t dialogchain-tests -f Dockerfile.test .
	docker run -it --rm --entrypoint /bin/bash dialogchain-tests

# Cleanup
.PHONY: clean clean-all docker-clean docker-clean-all
clean:
	find .. -type d -name "__pycache__" -exec rm -r {} +
	find .. -type d -name ".pytest_cache" -exec rm -r {} +
	find .. -type d -name ".mypy_cache" -exec rm -r {} +
	rm -f ../.coverage

clean-all: clean

# Docker cleanup
docker-clean:
	docker rmi make-test-env || true

docker-clean-all: docker-clean
	docker system prune -f

# Install test dependencies
.PHONY: deps
deps:
	cd .. && $(PIP) install -e .[test]
