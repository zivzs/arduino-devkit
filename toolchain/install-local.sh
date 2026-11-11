#!/usr/bin/env bash
# Host install: wrappers on PATH + optional local arduino-cli build.
# Docker-first remains the recommended hermetic path (see README).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-${ROOT}/.local}"
BIN_DIR="${PREFIX}/bin"

mkdir -p "${BIN_DIR}"

# Symlink wrappers
for name in arduino-doctor arduino-scaffold arduino-compile arduino-flash arduino-monitor; do
  ln -sfn "${ROOT}/bin/${name}" "${BIN_DIR}/${name}"
done

BUILD_CLI="${BUILD_CLI:-1}"
if [[ "${BUILD_CLI}" == "1" ]]; then
  OUT_DIR="${BIN_DIR}" "${ROOT}/toolchain/build-cli.sh"
fi

# Minimal Arduino data dirs for host mode (core still expected via Docker unless user installs)
DATA_DIR="${PREFIX}/arduino-data"
USER_DIR="${PREFIX}/hardware-user"
mkdir -p "${DATA_DIR}" "${USER_DIR}"
if [[ -x "${BIN_DIR}/arduino-cli" ]]; then
  if [[ ! -f "${DATA_DIR}/arduino-cli.yaml" ]]; then
    "${BIN_DIR}/arduino-cli" config init --dest-dir "${DATA_DIR}"
  fi
  "${BIN_DIR}/arduino-cli" config set directories.data "${DATA_DIR}" --config-file "${DATA_DIR}/arduino-cli.yaml" || true
  "${BIN_DIR}/arduino-cli" config set directories.user "${USER_DIR}" --config-file "${DATA_DIR}/arduino-cli.yaml" || true
fi

cat <<EOF
Installed wrappers to: ${BIN_DIR}

Add to your shell PATH:
  export PATH="${BIN_DIR}:\$PATH"

Docker-first (recommended for compile):
  docker build -t arduino-devkit:uno -f toolchain/Dockerfile .
  ./bin/arduino-compile examples/Blink

SUMMARY ok=install_local prefix=${PREFIX}
EOF
