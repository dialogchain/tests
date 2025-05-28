.PHONY: test test-ansible test-molecule setup clean

# Variables
VENV = venv
ANSIBLE_CMD = ansible-playbook -i inventory/hosts
MOLECULE_CMD = molecule test
PYTHON = python3
PIP = pip3

# Default target
all: test

# Setup environment
setup:
	@echo "Setting up test environment..."
	$(PYTHON) -m venv $(VENV)
	. $(VENV)/bin/activate && \
	$(PIP) install --upgrade pip && \
	$(PIP) install -r requirements.txt

# Install Ansible dependencies
install-deps:
	@echo "Installing Ansible dependencies..."
	ansible-galaxy install -r requirements.yml

# Run all tests
test: test-ansible test-molecule

# Run Ansible tests
test-ansible: install-deps
	@echo "Running Ansible tests..."
	$(ANSIBLE_CMD) playbooks/test_dialogchain.yml --syntax-check
	$(ANSIBLE_CMD) playbooks/test_dialogchain.yml

# Run Molecule tests
test-molecule:
	@echo "Running Molecule tests..."
	cd playbooks && $(MOLECULE_CMD)

# Clean up
clean:
	@echo "Cleaning up..."
	rm -rf $(VENV)
	find . -name '*.retry' -delete
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -exec rm -rf {} +
