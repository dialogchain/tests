#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="all"
VERBOSE=false

# Function to display help
show_help() {
    echo "Run DialogChain tests"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE   Test type: all, unit, integration, mqtt, http (default: all)"
    echo "  -v, --verbose     Show more verbose output"
    echo "  -h, --help        Show this help message and exit"
    echo ""
    echo "Examples:"
    echo "  $0 -t mqtt       # Run only MQTT tests"
    echo "  $0 -t http -v   # Run HTTP tests with verbose output"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            TEST_TYPE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to log messages
log() {
    echo -e "${GREEN}[TEST]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to log info messages
info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Get the absolute path to the tests directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
PYTHON_DIR="$PROJECT_ROOT/python"

# Set PYTHONPATH to include the project root and python directory
export PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}$PROJECT_ROOT:$PYTHON_DIR"

# Change to python directory where the package is located
cd "$PYTHON_DIR" || { echo "Failed to change to python directory"; exit 1; }

# Build the test command
TEST_CMD="python -m pytest -v"

if [ "$VERBOSE" = true ]; then
    TEST_CMD="$TEST_CMD -s"
fi

# Run the appropriate tests
case $TEST_TYPE in
    unit)
        log "Running unit tests..."
        $TEST_CMD tests/unit/
        ;;
    integration)
        log "Running integration tests..."
        $TEST_CMD tests/integration/
        ;;
    mqtt)
        log "Running MQTT tests..."
        $TEST_CMD tests/integration/mqtt/ --log-cli-level=INFO
        ;;
    http)
        log "Running HTTP tests..."
        $TEST_CMD tests/integration/test_http_connector.py -v
        ;;
    all)
        log "Running all tests..."
        $TEST_CMD
        ;;
    *)
        echo "Unknown test type: $TEST_TYPE"
        show_help
        exit 1
        ;;
esac

log "Tests completed successfully"
exit 0
