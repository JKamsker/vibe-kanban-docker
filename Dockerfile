FROM node:22-bookworm-slim

# Keep base image non-interactive and set production defaults
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

# Install system dependencies, GitHub CLI, Docker CLI, and build tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       ca-certificates curl git bash openssh-client gnupg python3 make g++ unzip \
  && mkdir -p -m 755 /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
  && curl -fsSL https://download.docker.com/linux/debian/gpg \
       | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
       > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       gh docker-ce-cli docker-compose-plugin \
  && rm -rf /var/lib/apt/lists/*

# Install OpenAI Codex CLI globally and cache the binary
RUN npm install -g @openai/codex@latest \
  && codex --version >/tmp/codex-version

# Dedicated workspace for mounted repositories
WORKDIR /work

EXPOSE 8080

# Default git identity (override via docker-compose env if needed)
ENV GIT_AUTHOR_NAME="Your Name" \
    GIT_AUTHOR_EMAIL="you@example.com" \
    GIT_COMMITTER_NAME="Your Name" \
    GIT_COMMITTER_EMAIL="you@example.com"

# Launch Vibe Kanban; relies on mounted repo and optional PORT env
CMD ["bash", "-lc", "npx -y vibe-kanban"]
