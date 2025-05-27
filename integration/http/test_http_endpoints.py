"""Integration tests for HTTP endpoints."""
import pytest
import requests
from http import HTTPStatus

# Base URL for the HTTP endpoints
BASE_URL = "http://localhost:8080"

# Test data for the echo endpoint
ECHO_TEST_DATA = {
    "test": "data",
    "number": 123,
    "nested": {"key": "value"}
}


def test_hello_endpoint():
    """Test the root endpoint that returns service status."""
    response = requests.get(f"{BASE_URL}/")
    assert response.status_code == HTTPStatus.OK
    data = response.json()
    assert data["service"] == "http-mock"
    assert data["status"] == "running"
    assert "version" in data


def test_get_data_endpoint():
    """Test the /api/data endpoint that returns sample data."""
    response = requests.get(f"{BASE_URL}/api/data")
    assert response.status_code == HTTPStatus.OK
    data = response.json()
    assert data["id"] == 1
    assert data["name"] == "Test Data"
    assert data["value"] == 42
    assert data["active"] is True


def test_echo_endpoint():
    """Test the /api/echo endpoint that echoes back the request data."""
    response = requests.post(f"{BASE_URL}/api/echo", json=ECHO_TEST_DATA)
    assert response.status_code == HTTPStatus.OK
    data = response.json()
    assert data["status"] == "success"
    assert data["received"] == ECHO_TEST_DATA


@pytest.mark.parametrize("status_code, expected_status", [
    (200, HTTPStatus.OK),
    (201, HTTPStatus.CREATED),
    (400, HTTPStatus.BAD_REQUEST),
    (404, HTTPStatus.NOT_FOUND),
    (500, HTTPStatus.INTERNAL_SERVER_ERROR),
])
def test_status_code_endpoint(status_code, expected_status):
    """Test the /api/status/<status_code> endpoint with various status codes."""
    response = requests.get(f"{BASE_URL}/api/status/{status_code}")
    assert response.status_code == expected_status
    
    # For successful responses, verify the returned data
    if 200 <= status_code < 300:
        data = response.json()
        assert data["status"] == "success"
        assert data["code"] == status_code


def test_invalid_status_code():
    """Test the /api/status/<status_code> endpoint with an invalid status code."""
    response = requests.get(f"{BASE_URL}/api/status/not_a_number")
    assert response.status_code == HTTPStatus.BAD_REQUEST
    data = response.json()
    assert data["status"] == "error"
    assert "Invalid status code" in data["message"]


class TestHTTPEndpointsWithSession:
    """Test HTTP endpoints using a session for connection pooling."""
    
    @pytest.fixture(scope="class")
    def session(self):
        """Create a requests session for connection pooling."""
        with requests.Session() as session:
            yield session
    
    def test_hello_endpoint_with_session(self, session):
        """Test the root endpoint using a session."""
        response = session.get(f"{BASE_URL}/")
        assert response.status_code == HTTPStatus.OK
        data = response.json()
        assert data["service"] == "http-mock"
    
    def test_echo_endpoint_with_session(self, session):
        """Test the echo endpoint using a session."""
        response = session.post(f"{BASE_URL}/api/echo", json=ECHO_TEST_DATA)
        assert response.status_code == HTTPStatus.OK
        data = response.json()
        assert data["status"] == "success"
        assert data["received"] == ECHO_TEST_DATA
