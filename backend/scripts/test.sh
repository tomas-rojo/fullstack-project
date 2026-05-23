#!/usr/bin/env bash

set -e

# Find the workspace venv
VENV_DIR="${VENV_DIR:-$(cd "$(dirname "$0")/../.." && pwd)/.venv}"
if [ -d "$VENV_DIR" ]; then
    export PATH="$VENV_DIR/bin:$PATH"
fi

echo "Running backend unit tests..."
coverage run -m pytest tests/
coverage report --show-missing --skip-covered
