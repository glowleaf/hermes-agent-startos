FROM python:3.11-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Install Node.js 20 (required by Hermes web build)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Hermes Agent from source (Node.js kept for runtime web UI asset build)
RUN git clone https://github.com/NousResearch/hermes-agent.git /opt/hermes-agent && \
    uv venv /opt/hermes-agent/.venv --python 3.11 && \
    cd /opt/hermes-agent && \
    uv pip install --python /opt/hermes-agent/.venv/bin/python -e '.[web,messaging,mcp,pty]' && \
    ln -sf /opt/hermes-agent/.venv/bin/hermes /usr/local/bin/hermes

# Create persistent data directory
RUN mkdir -p /data/.hermes
ENV HERMES_HOME=/data/.hermes

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY health-check.sh /usr/local/bin/health-check.sh
COPY backup.sh /usr/local/bin/backup.sh
COPY restore.sh /usr/local/bin/restore.sh
COPY migrate.sh /usr/local/bin/migrate.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
             /usr/local/bin/health-check.sh \
             /usr/local/bin/backup.sh \
             /usr/local/bin/restore.sh \
             /usr/local/bin/migrate.sh

# WebUI port
EXPOSE 8787

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
