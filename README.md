# tests
e2e tests of dialogchain package in infra


# Docker-based Testing Environment for Makefile Projects

This directory contains a generic Docker-based testing environment for projects that use Makefiles. It's designed to be reusable across different Python projects.

## Features

- Runs in an isolated Docker container
- Supports custom Python and system dependencies
- Clones any Git repository
- Executes Makefile targets with proper error handling
- Provides colored output for better readability
- Configurable through environment variables

## Prerequisites

- Docker installed on your system
- Git (for local testing)

## Quick Start

1. Build the test image:
   ```bash
   docker build -f Dockerfile.test -t make-test-env .
   ```

2. Run the tests:
   ```bash
   docker run --rm -it make-test-env \
     -e REPO_URL=https://github.com/dialogchain/python.git \
     -e BRANCH=main \
     -e 'MAKE_TARGETS="deps test"' \
     -e 'PYTHON_DEPS="pytest coverage"' \
     -e 'SYSTEM_DEPS="libjpeg-dev zlib1g-dev"'
   ```

## Configuration

You can customize the test environment using the following environment variables:

- `REPO_URL`: Git repository URL (default: empty)
- `BRANCH`: Branch to checkout (default: main)
- `MAKE_TARGETS`: Space-separated list of make targets to run (default: "help deps test")
- `PYTHON_DEPS`: Space-separated list of Python dependencies to install
- `SYSTEM_DEPS`: Space-separated list of system packages to install

## Local Development

For local development, you can use the `run_tests_locally.sh` script:

```bash
./run_tests_locally.sh
```

## Example: Testing This Project

To test the current project:

```bash
docker build -f Dockerfile.test -t make-test-env .
docker run --rm -it \
  -v $(pwd):/home/testuser/app \
  -e MAKE_TARGETS="deps test" \
  make-test-env
```

## Troubleshooting

- If you get permission errors, try running with `--privileged` flag
- For network issues in the container, use `--network host`
- To debug container issues, use `docker run --rm -it make-test-env /bin/bash`

## License

This testing environment is provided as-is under the MIT License.
