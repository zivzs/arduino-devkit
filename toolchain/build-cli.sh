#!/usr/bin/env bash
# Build pinned arduino-cli from source (Go ≥ 1.26).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ARDUINO_CLI_REF="${ARDUINO_CLI_REF:-v1.5.1}"
OUT_DIR="${OUT_DIR:-${ROOT}/.local/bin}"
SRC_DIR="${SRC_DIR:-${ROOT}/.local/src/arduino-cli}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "SUMMARY error=missing_command command=$1" >&2
    exit 1
  }
}

need_cmd git
need_cmd go

GO_MAJOR="$(go env GOVERSION | sed -E 's/^go([0-9]+)\.([0-9]+).*/\1/')"
GO_MINOR="$(go env GOVERSION | sed -E 's/^go([0-9]+)\.([0-9]+).*/\2/')"
if [[ "${GO_MAJOR}" -lt 1 ]] || { [[ "${GO_MAJOR}" -eq 1 ]] && [[ "${GO_MINOR}" -lt 26 ]]; }; then
  echo "SUMMARY error=go_too_old required=1.26 got=$(go env GOVERSION)" >&2
  echo "Use Docker (recommended) or install Go 1.26+." >&2
  exit 1
fi

mkdir -p "${OUT_DIR}" "$(dirname "${SRC_DIR}")"
if [[ -d "${SRC_DIR}/.git" ]]; then
  git -C "${SRC_DIR}" fetch --depth 1 origin "refs/tags/${ARDUINO_CLI_REF}:refs/tags/${ARDUINO_CLI_REF}" 2>/dev/null || true
  git -C "${SRC_DIR}" checkout -f "tags/${ARDUINO_CLI_REF}"
else
  rm -rf "${SRC_DIR}"
  git clone --depth 1 --branch "${ARDUINO_CLI_REF}" https://github.com/arduino/arduino-cli.git "${SRC_DIR}"
fi

(
  cd "${SRC_DIR}"
  go build -o "${OUT_DIR}/arduino-cli" .
)

"${OUT_DIR}/arduino-cli" version
echo "SUMMARY ok=build_cli ref=${ARDUINO_CLI_REF} path=${OUT_DIR}/arduino-cli"
