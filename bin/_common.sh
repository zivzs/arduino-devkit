#!/usr/bin/env bash
# Shared helpers for arduino-devkit wrappers. Sourced only — never exec shell strings.
# All arduino-cli invocations use argv arrays (no eval / no shell=True equivalent).

set -euo pipefail

ARDUINO_DEVKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARDUINO_FQBN="${ARDUINO_FQBN:-arduino:avr:uno}"
ARDUINO_DEVKIT_IMAGE="${ARDUINO_DEVKIT_IMAGE:-arduino-devkit:uno}"
ARDUINO_DEVKIT_MODE="${ARDUINO_DEVKIT_MODE:-auto}" # auto | docker | host

summary() {
  # Machine-readable one-liner for agents: SUMMARY key=value ...
  echo "SUMMARY $*"
}

die() {
  summary "ok=false error=$*"
  exit 1
}

usage_exit() {
  echo "$1" >&2
  exit 2
}

have_docker_image() {
  command -v docker >/dev/null 2>&1 || return 1
  docker image inspect "${ARDUINO_DEVKIT_IMAGE}" >/dev/null 2>&1
}

resolve_cli() {
  if [[ -n "${ARDUINO_CLI:-}" ]]; then
    printf '%s' "${ARDUINO_CLI}"
    return
  fi
  if [[ -x "${ARDUINO_DEVKIT_ROOT}/.local/bin/arduino-cli" ]]; then
    printf '%s' "${ARDUINO_DEVKIT_ROOT}/.local/bin/arduino-cli"
    return
  fi
  if command -v arduino-cli >/dev/null 2>&1; then
    command -v arduino-cli
    return
  fi
  return 1
}

# Decide docker vs host. Prefer docker when image exists (hermetic).
use_docker() {
  case "${ARDUINO_DEVKIT_MODE}" in
    docker) return 0 ;;
    host) return 1 ;;
    auto)
      have_docker_image
      ;;
    *)
      die "invalid_mode mode=${ARDUINO_DEVKIT_MODE}"
      ;;
  esac
}

# Run arduino-cli with argv array. Extra args after --.
# Usage: run_cli <args...>
run_cli() {
  if use_docker; then
    # Mount sketch parent only when ARDUINO_SKETCH_MOUNT is set by caller wrappers.
    local -a docker_args=(
      docker run --rm
      --network=none
      --cap-drop=ALL
      --security-opt=no-new-privileges
    )
    if [[ -n "${ARDUINO_SKETCH_MOUNT:-}" ]]; then
      docker_args+=(-v "${ARDUINO_SKETCH_MOUNT}:/work:ro")
      docker_args+=(-w /work)
    fi
    # Flash/monitor need host network devices — those wrappers set ARDUINO_DOCKER_EXTRA
    if [[ -n "${ARDUINO_DOCKER_EXTRA:-}" ]]; then
      # shellcheck disable=SC2206
      local -a extras=(${ARDUINO_DOCKER_EXTRA})
      docker_args+=("${extras[@]}")
    fi
    docker_args+=("${ARDUINO_DEVKIT_IMAGE}")
    docker_args+=("$@")
    "${docker_args[@]}"
  else
    local cli
    cli="$(resolve_cli)" || die "arduino_cli_not_found hint=run_toolchain/install-local_or_docker_build"
    local -a cmd=("${cli}" "$@")
    "${cmd[@]}"
  fi
}

abs_path() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$p"
  else
    python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$p"
  fi
}

require_sketch_dir() {
  local sketch="$1"
  [[ -d "${sketch}" ]] || die "sketch_not_dir path=${sketch}"
  local base
  base="$(basename "${sketch}")"
  local ino="${sketch}/${base}.ino"
  [[ -f "${ino}" ]] || die "missing_ino expected=${ino}"
}
