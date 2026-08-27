FROM ghcr.io/actions/actions-runner:latest

USER root
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
 && rm -rf /var/lib/apt/lists/*

# docker-CLI (NUR Client — der Daemon bleibt der Host, Socket wird gemountet).
# Offizielles Docker-Repo statt docker/setup-docker-action im Job:
# die Action baut fuer Docker 29.x kaputte Download-URLs (HTTP 404).
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" \
      > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER runner
ENTRYPOINT ["/entrypoint.sh"]
