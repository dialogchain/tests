"""Pytest configuration for MQTT tests."""
import pytest
import time
from paho.mqtt import client as mqtt

@pytest.fixture(scope="module")
def mosquitto():
    """Fixture that provides a connected MQTT client for testing."""
    # Connect to the Mosquitto container on host network
    host = "host.docker.internal"  # Special DNS name for host from container
    port = 1883
    
    # Create a client for the fixture
    client = mqtt.Client()
    client.connect(host, port)
    client.loop_start()
    
    # Wait for connection
    time.sleep(0.1)
    
    yield type('obj', (object,), {'host': host, 'port': port, 'client': client})
    
    # Cleanup
    client.disconnect()
    client.loop_stop()
