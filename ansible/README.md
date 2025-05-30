# Ansible Tests for DialogChain

This directory contains Ansible tests for the DialogChain role. The tests are designed to verify the installation, configuration, and basic functionality of DialogChain.

## Prerequisites

- Ansible 2.9 or later
- Python 3.8 or later
- Molecule 3.x (for running molecule tests)
- Docker (for container-based testing)

## Test Structure

- `molecule/` - Contains Molecule test scenarios
  - `default/` - Default test scenario
    - `molecule.yml` - Molecule configuration
    - `tests/` - Test files
      - `test_default.py` - Test cases for the role

- `playbooks/` - Contains Ansible playbooks for testing
  - `test_dialogchain.yml` - Basic test playbook
  - `integration_test.yml` - Comprehensive integration test playbook
  - `converge.yml` - Playbook for converging test environment
  - `verify.yml` - Playbook for verification tests

## Running Tests

### Using Molecule

1. Install Molecule and dependencies:
   ```bash
   pip install molecule molecule-plugins[docker] testinfra
   ```

2. Run the tests:
   ```bash
   cd tests/ansible
   molecule test
   ```

### Using Ansible Directly

1. Run the test playbook:
   ```bash
   cd tests/ansible
   ansible-playbook -i inventory playbooks/test_dialogchain.yml
   ```

2. For comprehensive integration tests:
   ```bash
   cd tests/ansible
   ansible-playbook -i inventory playbooks/integration_test.yml
   ```

## Test Cases

The following test cases are included:

1. **Basic Installation**
   - Verifies DialogChain is installed
   - Checks version information
   - Verifies command-line interface works

2. **Service Management**
   - Verifies service is running
   - Checks service is enabled on boot
   - Verifies service can be restarted

3. **Configuration**
   - Verifies configuration directory structure
   - Checks file permissions
   - Validates configuration files

4. **Integration**
   - Verifies network connectivity
   - Checks listening ports
   - Tests basic functionality

## Customizing Tests

You can customize the tests by modifying the following variables in the playbooks:

- `python_version`: Python version to test with
- `dialogchain_version`: DialogChain version to install
- `dialogchain_service_user`: Service user account
- `dialogchain_config_dir`: Configuration directory
- `dialogchain_log_dir`: Log directory
- `dialogchain_data_dir`: Data directory

## Debugging

To debug test failures, you can run Molecule with increased verbosity:

```bash
molecule --debug test
```

Or run specific test scenarios:

```bash
molecule converge
molecule verify
molecule test -s default
```

## Contributing

When adding new tests, please follow these guidelines:

1. Add test cases to the appropriate test file
2. Update the README with any new functionality
3. Ensure tests are idempotent
4. Include appropriate assertions
5. Add comments explaining complex test logic
