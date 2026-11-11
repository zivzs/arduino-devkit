---
name: arduino-flash
description: Compile and upload a sketch to Arduino Uno. Refuses without an explicit --port; never guesses serial ports.
---

# arduino-flash

## When to use

- User wants to upload firmware to a connected Uno
- After a successful compile, when a port is known

## Do not

- Guess or pick a port from `board list` without user confirmation
- Proceed without `--port`
- Use non-Uno FQBNs

## Required args

| Arg | Meaning |
|-----|---------|
| `--port <path>` | Serial device, e.g. `/dev/cu.usbmodem14101` |
| sketch-dir | Directory containing `<Name>/<Name>.ino` |

## Invocation

```bash
./bin/arduino-flash --port /dev/cu.usbmodemXXXX path/to/SketchName
```

If port unknown, run `./bin/arduino-doctor` and ask the user which port to use.

## Failure behavior

- Exit nonzero with `SUMMARY ... error=port_required` if `--port` missing
- `port_not_found` if device path missing
- On upload failure, suggest doctor + cable/bootloader checks; do not retry other ports automatically
