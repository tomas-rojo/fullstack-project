#!/usr/bin/env bash

set -e

echo "Running backend unit tests..."
uv run coverage run -m pytest tests/
uv run coverage report --show-missing --skip-covered
