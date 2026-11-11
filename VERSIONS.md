# Pinned versions (v1)

Source of truth for reproducible builds. Do not float to `latest`.

| Component | Pin | Resolved commit / notes |
|-----------|-----|-------------------------|
| **arduino-cli** | tag `v1.5.1` | `01f3d4f2ba7c2eaafb5dc710c8a1903af7762fea` — built from source with **Go ≥ 1.26** |
| **ArduinoCore-avr** | tag `1.8.6` | `42fa4a1ea1b1b11d1cc0a60298e529d37f9d14bd` — GitHub clone into image; no package-index core install |
| **FQBN** | `arduino:avr:uno` | Uno only in v1 |
| **Host AVR tools (Docker)** | Debian Bookworm packages | `gcc-avr`, `avr-libc`, `binutils-avr`, `avrdude` via `apt` |
| **Go (build)** | `golang:1.26-bookworm` | Required so `arduino-cli` builds (fixes `tool` directive failure on older Go) |
| **Docker image tag** | `arduino-devkit:uno` | Local image name used by wrappers and hermetic tests |

## Optional companion (not a pin dependency)

| Component | Reference |
|-----------|-----------|
| VS-Arduino fork | https://github.com/zivzs/VS-Arduino branch `security-fixes` — editor companion only; agent skills must not depend on the VSIX |

## Update policy

1. Bump the tag in this file and in `toolchain/Dockerfile` / `toolchain/build-cli.sh` together.
2. Re-run `tests/test_compile_blink.sh`.
3. Record the new peeled commit SHA in the table above.
