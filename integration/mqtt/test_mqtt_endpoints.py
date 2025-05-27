"""Integration tests for MQTT endpoints."""
import json
import time
import pytest
from paho.mqtt import client as mqtt

# MQTT broker configuration for testing
MQTT_BROKER_HOST = "localhost"
MQTT_BROKER_PORT = 1883
MQTT_TOPIC_PUBLISH = "test/publish"
MQTT_TOPIC_SUBSCRIBE = "test/subscribe"
MQTT_CLIENT_ID = "pytest-mqtt-client"

# Test message data
TEST_MESSAGE = {
    "test": "data",
    "value": 42,
    "active": True,
    "nested": {"key": "value"}
}


class MQTTTestClient:
    """Helper class for MQTT testing."""
    
    def __init__(self, client_id=MQTT_CLIENT_ID):
        """Initialize MQTT client with the given client ID."""
        self.client = mqtt.Client(client_id=client_id)
        self.received_messages = []
        self.connected = False
        
        # Set up callbacks
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        
    def _on_connect(self, client, userdata, flags, rc, properties=None):
        """Handle connection callback."""
        if rc == 0:
            self.connected = True
            print("Connected to MQTT broker")
        else:
            print(f"Failed to connect to MQTT broker with result code {rc}")
    
    def _on_message(self, client, userdata, msg):
        """Handle incoming message callback."""
        try:
            payload = json.loads(msg.payload.decode())
        except json.JSONDecodeError:
            payload = msg.payload.decode()
            
        self.received_messages.append({
            "topic": msg.topic,
            "payload": payload,
            "qos": msg.qos,
            "retain": msg.retain
        })
    
    def connect(self, host=MQTT_BROKER_HOST, port=MQTT_BROKER_PORT):
        """Connect to the MQTT broker."""
        self.client.connect(host, port, 60)
        self.client.loop_start()
        
        # Wait for connection
        timeout = 5  # seconds
        start_time = time.time()
        while not self.connected and (time.time() - start_time) < timeout:
            time.sleep(0.1)
            
        if not self.connected:
            raise TimeoutError("Failed to connect to MQTT broker within timeout")
    
    def disconnect(self):
        """Disconnect from the MQTT broker."""
        self.client.loop_stop()
        self.client.disconnect()
    
    def publish(self, topic, payload, qos=0, retain=False):
        """Publish a message to a topic."""
        if isinstance(payload, dict):
            payload = json.dumps(payload)
        result = self.client.publish(topic, payload, qos=qos, retain=retain)
        result.wait_for_publish()
        return result
    
    def subscribe(self, topic, qos=0):
        """Subscribe to a topic."""
        result, _ = self.client.subscribe(topic, qos)
        return result == mqtt.MQTT_ERR_SUCCESS
    
    def wait_for_messages(self, count=1, timeout=5):
        """Wait for the specified number of messages with a timeout."""
        start_time = time.time()
        while len(self.received_messages) < count and (time.time() - start_time) < timeout:
            time.sleep(0.1)
        return len(self.received_messages) >= count


@pytest.fixture(scope="module")
def mqtt_client():
    """Fixture that provides an MQTT test client."""
    client = MQTTTestClient()
    client.connect()
    yield client
    client.disconnect()


def test_mqtt_connection(mqtt_client):
    """Test that we can connect to the MQTT broker."""
    assert mqtt_client.connected is True


def test_mqtt_publish_subscribe(mqtt_client):
    """Test publishing and subscribing to MQTT topics."""
    # Subscribe to test topic
    assert mqtt_client.subscribe(MQTT_TOPIC_SUBSCRIBE) is True
    
    # Publish a test message
    test_msg = {"test": "message", "value": 42}
    mqtt_client.publish(MQTT_TOPIC_SUBSCRIBE, test_msg)
    
    # Wait for the message to be received
    assert mqtt_client.wait_for_messages(1) is True
    
    # Check the received message
    assert len(mqtt_client.received_messages) == 1
    msg = mqtt_client.received_messages[0]
    assert msg["topic"] == MQTT_TOPIC_SUBSCRIBE
    assert msg["payload"] == test_msg


def test_mqtt_qos_levels(mqtt_client):
    """Test different QoS levels for MQTT messages."""
    test_topics = [
        (f"{MQTT_TOPIC_SUBSCRIBE}/qos0", 0),
        (f"{MQTT_TOPIC_SUBSCRIBE}/qos1", 1),
        (f"{MQTT_TOPIC_SUBSCRIBE}/qos2", 2),
    ]
    
    for topic, qos in test_topics:
        # Clear previous messages
        mqtt_client.received_messages = []
        
        # Subscribe with the specified QoS
        assert mqtt_client.subscribe(topic, qos=qos) is True
        
        # Publish with the same QoS
        test_msg = {"qos_test": qos, "message": f"Testing QoS {qos}"}
        mqtt_client.publish(topic, test_msg, qos=qos)
        
        # Wait for the message
        assert mqtt_client.wait_for_messages(1) is True
        
        # Verify the message
        assert len(mqtt_client.received_messages) == 1
        msg = mqtt_client.received_messages[0]
        assert msg["topic"] == topic
        assert msg["payload"] == test_msg
        assert msg["qos"] == qos


def test_mqtt_retained_messages(mqtt_client):
    """Test MQTT retained messages."""
    topic = f"{MQTT_TOPIC_SUBSCRIBE}/retained"
    
    # Publish a retained message
    retained_msg = {"type": "retained", "value": "This is a retained message"}
    mqtt_client.publish(topic, retained_msg, retain=True)
    
    # Clear previous messages and subscribe
    mqtt_client.received_messages = []
    assert mqtt_client.subscribe(topic) is True
    
    # We should receive the retained message immediately
    assert mqtt_client.wait_for_messages(1) is True
    assert len(mqtt_client.received_messages) == 1
    assert mqtt_client.received_messages[0]["payload"] == retained_msg
    assert mqtt_client.received_messages[0]["retain"] is True
    
    # Clean up by publishing a None retained message
    mqtt_client.publish(topic, "", retain=True)


class TestMQTTIntegration:
    """Test class for MQTT integration tests."""
    
    @pytest.fixture(autouse=True)
    def setup(self, mqtt_client):
        """Setup test environment."""
        self.client = mqtt_client
        self.test_topic = f"{MQTT_TOPIC_SUBSCRIBE}/test_class"
        self.client.subscribe(self.test_topic)
        self.client.received_messages = []
        yield
        # Cleanup after each test
        self.client.received_messages = []
    
    def test_class_based_testing(self):
        """Test using the class-based testing approach."""
        test_msg = {"test": "class_based", "value": 123}
        self.client.publish(self.test_topic, test_msg)
        
        assert self.client.wait_for_messages(1) is True
        assert len(self.client.received_messages) == 1
        assert self.client.received_messages[0]["topic"] == self.test_topic
        assert self.client.received_messages[0]["payload"] == test_msg
