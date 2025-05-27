#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${REPO_URL:-https://github.com/dialogchain/python.git}"
BRANCH="${BRANCH:-main}"
MAKE_TARGETS=("${MAKE_TARGETS:-help deps test}")
PYTHON_DEPS=("${PYTHON_DEPS:-}")
SYSTEM_DEPS=("${SYSTEM_DEPS:-}")

# Function to log messages
log() {
    echo -e "${GREEN}[TEST]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to log warnings
warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Function to log errors and exit
error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install system dependencies
install_system_deps() {
    if [ ${#SYSTEM_DEPS[@]} -gt 0 ]; then
        log "Installing system dependencies: ${SYSTEM_DEPS[*]}"
        
        # Check if we're root or can use sudo
        if [ "$(id -u)" -eq 0 ]; then
            apt-get update
            if ! apt-get install -y "${SYSTEM_DEPS[@]}"; then
                warn "Failed to install system dependencies as root"
            fi
        elif command -v sudo >/dev/null 2>&1; then
            sudo apt-get update
            if ! sudo apt-get install -y "${SYSTEM_DEPS[@]}"; then
                warn "Failed to install system dependencies with sudo"
            fi
        else
            warn "Cannot install system dependencies - need root or sudo"
            warn "Missing packages: ${SYSTEM_DEPS[*]}"
        fi
    fi
}

# Install Python dependencies
install_python_deps() {
    if [ -n "${PYTHON_DEPS}" ]; then
        log "Installing Python dependencies: ${PYTHON_DEPS}"
        # Convert space-separated string to array
        IFS=' ' read -r -a deps_array <<< "$PYTHON_DEPS"
        if ! pip install --no-cache-dir "${deps_array[@]}"; then
            error "Failed to install Python dependencies"
        fi
    fi
}

# Clone the repository
clone_repo() {
    local repo_dir="/tmp/repo"
    
    log "Cloning repository: $REPO_URL (branch: $BRANCH)"
    if [ -d "$repo_dir" ]; then
        warn "Repository directory already exists, removing it"
        rm -rf "$repo_dir"
    fi
    
    if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$repo_dir"; then
        error "Failed to clone repository"
    fi
    
    cd "$repo_dir" || error "Failed to enter repository directory"
    log "Repository cloned to $repo_dir"
}

# Run make targets
run_make_targets() {
    if [ ! -f "Makefile" ]; then
        error "No Makefile found in the repository"
    fi
    
    log "Available make targets:"
    make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u || true
    
    for target in $MAKE_TARGETS; do
        log "Running make target: $target"
        if ! make "$target"; then
            error "Make target '$target' failed"
        fi
    done
}

# Main function
main() {
    log "Starting test environment"
    
    # Install system dependencies if any
    install_system_deps
    
    # Install Python dependencies if any
    install_python_deps
    
    # Clone the repository
    clone_repo
    
    # Install project in development mode if setup.py exists
    if [ -f "setup.py" ]; then
        log "Installing project in development mode"
        if ! pip install -e .; then
            error "Failed to install project in development mode"
        fi
    fi
    
    # Run make targets
    run_make_targets
    
    log "All tests completed successfully!"
}

# Run the main function
main "$@"
