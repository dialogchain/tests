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

# Test commands delegate to tests/Makefile
.PHONY: test test-unit test-integration test-coverage test-docker
test:
	$(MAKE) -C tests test

test-unit:
	$(MAKE) -C tests test-unit

test-integration:
	$(MAKE) -C tests test-integration

test-coverage:
	$(MAKE) -C tests test-coverage

test-docker:
	$(MAKE) -C tests test-docker

# Cleanup
.PHONY: clean clean-all
clean:
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type d -name ".pytest_cache" -exec rm -r {} +
	find . -type d -name ".mypy_cache" -exec rm -r {} +
	rm -f .coverage

clean-all: clean
	$(MAKE) -C tests clean

docker-clean:
	$(MAKE) -C tests docker-clean

docker-clean-all:
	$(MAKE) -C tests docker-clean-all

# Install test dependencies
.PHONY: deps
deps:
	$(MAKE) -C tests deps
