---
name: arduino-doctor
description: Diagnose the pinned Arduino Uno toolchain — CLI version, FQBN support, and serial ports — before compile/flash/monitor work.
---

# arduino-doctor

## When to use

- Before first compile/flash in a session
- When upload or serial fails and you need ports / CLI health
- To confirm Docker image `arduino-devkit:uno` vs host CLI mode

## Do not

- Guess FQBNs (v1 is **Arduino Uno / `arduino:avr:uno` only**)
- Auto-install cores from the package index in agent paths
- Depend on the VS-Arduino extension

## Required args

None.

## Invocation

From the `arduino-devkit` repo root (or with wrappers on `PATH`):

```bash
./bin/arduino-doctor
```

## Failure behavior

- Nonzero exit on CLI failure
- Last line is machine-readable: `SUMMARY ok=true|false ...`
- If ports are empty, tell the user to plug in USB and re-run; **do not invent a port**

## Next steps

- New sketch → `arduino-scaffold`
- Build only → `arduino-compile`
- Upload → `arduino-flash` (requires explicit `--port`)
