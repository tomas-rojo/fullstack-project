ARG PYTHON_IMAGE=docker.io/python:3.13-slim

# ============================================================================
# Target: builder
# ============================================================================
FROM ${PYTHON_IMAGE} AS builder

ENV PYTHONUNBUFFERED=1
# Don't let Python cache files end up in the image
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPYCACHEPREFIX=/tmp/.python_cache

# Install uv
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#installing-uv
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

# Compile bytecode and configure cache behaviour
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#compiling-bytecode
ENV UV_COMPILE_BYTECODE=1
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#caching
ENV UV_LINK_MODE=copy

WORKDIR /app/

# Install dependencies only (no workspace packages yet) for better layer caching
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#intermediate-layers
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-workspace --package app

# Copy application source so the workspace package can be installed
COPY ./backend/pyproject.toml ./backend/alembic.ini /app/backend/
COPY ./backend/app /app/backend/app

# Sync workspace package into the venv
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --package app

# ============================================================================
# Target: app-base
# ============================================================================
FROM ${PYTHON_IMAGE} AS app-base

# Set up a non-root user/group, matching the pattern from the second Dockerfile.
# addgroup/adduser flags for debian-slim (different from alpine's busybox versions).
RUN addgroup --system app-group \
    && adduser --system --home /app --shell /bin/sh --ingroup app-group --no-create-home app-user

# Copy the fully-built virtual environment from the builder stage
COPY --from=builder /app/.venv /app/.venv

ENV PYTHONUNBUFFERED=1
# Place venv executables at the front of the path
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#using-the-environment
ENV PATH="/app/.venv/bin:$PATH"

# Marker file so the app can detect it is running inside Docker
RUN touch /.dockerenv

# ============================================================================
# Target: app
# ============================================================================
FROM app-base AS app

WORKDIR /app/backend/

# Copy application source and scripts, owned by the non-root user
COPY --chown=app-user:app-group ./backend/scripts /app/backend/scripts
COPY --chown=app-user:app-group ./backend/pyproject.toml ./backend/alembic.ini /app/backend/
COPY --chown=app-user:app-group ./backend/app /app/backend/app

USER app-user:app-group

CMD ["fastapi", "run", "--workers", "4", "app/main.py"]
