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
    # Install Salt Master
    apt-get update && \
    apt-get install -y salt-master && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar configuración del master
COPY master.conf /etc/salt/master

EXPOSE 4505 4506

# -----------------------------------------------
# HEALTHCHECK: Verifica que el proceso salt-master
# está escuchando en el puerto 4505 (publisher).
# Cada 5 segundos Docker ejecuta "nc -z localhost 4505".
# Si el puerto no responde en 3s durante 10 intentos,
# el contenedor se marca como "unhealthy".
HEALTHCHECK --interval=5s --timeout=3s --retries=10 CMD nc -z localhost 4505 || exit 1

CMD ["salt-master", "-l", "info"]
