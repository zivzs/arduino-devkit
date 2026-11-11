---
name: arduino-scaffold
description: Create a new Arduino Uno sketch directory with minimal .ino and sketch.yaml (default_fqbn arduino:avr:uno).
---

# arduino-scaffold

## When to use

- User asks for a new Arduino sketch / project for Uno
- Starting a clean sketch before compile

## Do not

- Scaffold for ESP32 or non-Uno boards (out of scope for v1)
- Overwrite an existing `.ino` (script refuses)
- Change FQBN away from `arduino:avr:uno`

## Required args

| Arg | Meaning |
|-----|---------|
| sketch name or path | C identifier name, or path ending in that name |

## Invocation

```bash
./bin/arduino-scaffold MySketch
# or
./bin/arduino-scaffold path/to/MySketch
```

## Failure behavior

- Nonzero if name invalid, path traversal (`..`), or sketch already exists
- `SUMMARY ok=false error=...` on failure

## After success

Offer compile with `./bin/arduino-compile <path>`.
