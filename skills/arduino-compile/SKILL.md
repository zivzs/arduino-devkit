---
name: arduino-compile
description: Compile an Arduino sketch for Uno only (FQBN arduino:avr:uno) via pinned Docker toolchain or host CLI.
---

# arduino-compile

## When to use

- Build/check a sketch without uploading
- CI-style or hermetic verification (prefer Docker image)

## Do not

- Pass other FQBNs
- Flash or open serial from this skill
- Guess missing sketch paths — ask the user

## Required args

| Arg | Meaning |
|-----|---------|
| sketch-dir | Directory containing `<Name>/<Name>.ino` |

## Invocation

```bash
./bin/arduino-compile path/to/SketchName
```

Prefers `arduino-devkit:uno` when the image exists (`ARDUINO_DEVKIT_MODE=auto`).

Hermetic gate for this repo:

```bash
./tests/test_compile_blink.sh
```

## Failure behavior

- Nonzero on compile errors; surface compiler output to the user
- `SUMMARY ok=false error=compile_failed ...`
- If CLI missing: point to README Docker-first build / `toolchain/install-local.sh`
