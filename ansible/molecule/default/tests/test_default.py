"""Test cases for the dialogchain role."""
import os
import pytest
import testinfra.utils.ansible_runner

# Get the testinfra host
runner = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE'])
testinfra_hosts = runner.get_hosts('all')

# Test parameters
DIALOGCHAIN_VERSION = os.getenv('DIALOGCHAIN_VERSION', 'latest')


def test_dialogchain_installed(host):
    """Test that dialogchain is installed."""
    cmd = host.run('dialogchain --version')
    assert cmd.rc == 0, f"dialogchain command failed: {cmd.stderr}"
    if DIALOGCHAIN_VERSION != 'latest':
        assert DIALOGCHAIN_VERSION in cmd.stdout, \
            f"Expected version {DIALOGCHAIN_VERSION} not found in {cmd.stdout}"


def test_dialogchain_config_dir(host):
    """Test that dialogchain config directory exists."""
    config_dir = host.file('/etc/dialogchain')
    assert config_dir.exists, "/etc/dialogchain directory does not exist"
    assert config_dir.is_directory, "/etc/dialogchain is not a directory"
    assert config_dir.user == 'root'
    assert config_dir.group == 'root'
    assert config_dir.mode == 0o755


def test_dialogchain_service(host):
    """Test that dialogchain service is enabled and running."""
    service = host.service('dialogchain')
    assert service.is_running, "dialogchain service is not running"
    assert service.is_enabled, "dialogchain service is not enabled"


def test_dialogchain_socket(host):
    """Test that dialogchain socket is listening."""
    socket = host.socket('tcp://0.0.0.0:8000')
    assert socket.is_listening, "dialogchain is not listening on port 8000"


def test_dialogchain_config_files(host):
    """Test that required config files exist."""
    required_files = [
        '/etc/dialogchain/config.yaml',
        '/etc/dialogchain/logging.conf',
    ]
    
    for file_path in required_files:
        f = host.file(file_path)
        assert f.exists, f"{file_path} does not exist"
        assert f.user == 'dialogchain'
        assert f.group == 'dialogchain'
        assert f.mode == 0o644


def test_dialogchain_user(host):
    """Test that dialogchain user exists."""
    user = host.user('dialogchain')
    assert user.exists, "dialogchain user does not exist"
    assert user.shell == '/usr/sbin/nologin', "Incorrect shell for dialogchain user"
    assert user.home == '/var/lib/dialogchain', "Incorrect home directory"
