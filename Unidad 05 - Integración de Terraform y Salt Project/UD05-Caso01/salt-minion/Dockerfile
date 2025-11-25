FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl gnupg2 lsb-release ca-certificates netcat-openbsd && \
    \
    # Ensure keyrings dir exists
    mkdir -p /etc/apt/keyrings && \
    \
    # Download public key (Broadcom SaltProject)
    curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
      -o /etc/apt/keyrings/salt-archive-keyring.pgp && \
    \
    # Create APT repository configuration
    mkdir -p /etc/apt/sources.list.d && \
    curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \
      -o /etc/apt/sources.list.d/salt.sources && \
    \
    # Install Salt Minion + nginx + ufw
    apt-get update && \
    apt-get install -y salt-minion nginx ufw && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configuración base
COPY minion.conf /etc/salt/minion

EXPOSE 8088

CMD ["bash", "-c", "sleep 8 && printf \"master: %s\\nid: %s\\n\" \"$SALT_MASTER\" \"$HOSTNAME\" > /etc/salt/minion && salt-minion -l info"]
