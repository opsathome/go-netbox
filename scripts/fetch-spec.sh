#!/usr/bin/env bash

set -euo pipefail

NETBOX_VERSION="$1"
NETBOX_DOCKER_VERSION="$2"

REPO_DIR='/tmp/netbox-docker'

rm -rf "${REPO_DIR}"

git clone https://github.com/netbox-community/netbox-docker.git \
  --config advice.detachedHead=false \
  --branch ${NETBOX_DOCKER_VERSION} \
  --depth=1 \
  --quiet \
  "${REPO_DIR}"

mv "${REPO_DIR}/docker-compose.override.yml.example" "${REPO_DIR}/docker-compose.override.yml"

WORKDIR=$(pwd)

export VERSION="v${NETBOX_VERSION}"
#docker compose --project-directory="${REPO_DIR}" up --detach --quiet-pull
cd ${REPO_DIR}
podman compose up -d

cd ${WORKDIR}

while ! curl --silent http://localhost:8000/api/schema/ > api/openapi.yaml 2> /dev/null; do
  sleep 1
done

cd ${REPO_DIR}
podman compose down
cd ${WORKDIR}
#docker compose --project-directory="${REPO_DIR}" down --volumes

rm -rf "${REPO_DIR}"
