#!/usr/bin/env bash
# Hermetic Blink compile gate: build image if needed, compile with network/caps locked down.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${ARDUINO_DEVKIT_IMAGE:-arduino-devkit:uno}"
SKETCH_PARENT="${ROOT}/examples"
SKETCH_NAME="Blink"

cd "${ROOT}"

if ! command -v docker >/dev/null 2>&1; then
  echo "SUMMARY ok=false error=docker_required"
  exit 1
fi

NEED_BUILD=1
if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  NEED_BUILD=0
fi
if [[ "${FORCE_REBUILD:-0}" == "1" ]]; then
  NEED_BUILD=1
fi

if [[ "${NEED_BUILD}" == "1" ]]; then
  echo "=== Building ${IMAGE} ==="
  docker build -t "${IMAGE}" -f toolchain/Dockerfile .
fi

echo "=== Hermetic compile examples/Blink (network=none, cap-drop=ALL) ==="
docker run --rm \
  --network=none \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  -v "${SKETCH_PARENT}:/work:ro" \
  -w /work \
  "${IMAGE}" \
  compile --fqbn arduino:avr:uno --build-path /tmp/arduino-build "/work/${SKETCH_NAME}"

echo "BLINK_COMPILE_OK"
echo "SUMMARY ok=true command=test_compile_blink image=${IMAGE}"
