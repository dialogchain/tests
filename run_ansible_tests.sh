#!/bin/bash
set -e

# Install Ansible and test dependencies
pip install -r requirements.txt
pip install -r tests/requirements-test.txt

# Wait for services to be ready
max_retries=10
retry_interval=5

# Wait for MQTT
for i in $(seq 1 $max_retries); do
  if nc -z mqtt 1883; then
    echo "MQTT broker is ready"
    break
  fi
  echo "Waiting for MQTT broker... (attempt $i/$max_retries)"
  sleep $retry_interval
done

# Wait for HTTP mock
for i in $(seq 1 $max_retries); do
  if curl -s http://http-mock:1080/status >/dev/null; then
    echo "HTTP mock server is ready"
    break
  fi
  echo "Waiting for HTTP mock server... (attempt $i/$max_retries)"
  sleep $retry_interval
done

# Set up test environment
export ANSIBLE_FORCE_COLOR=1
export PYTHONUNBUFFERED=1

# Run Ansible tests
cd /app/ansible

# Run molecule tests
molecule test -s default

# Run integration tests
ansible-playbook playbooks/integration_test.yml --syntax-check
ansible-playbook playbooks/integration_test.yml --diff

echo "All tests completed successfully"
