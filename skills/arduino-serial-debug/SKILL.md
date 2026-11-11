---
name: arduino-serial-debug
description: Open the Uno serial monitor and interpret common upload/serial failures using doctor and compile output. Requires explicit --port.
---

# arduino-serial-debug

## When to use

- User wants to read Serial output from a Uno
- Debugging upload or monitor problems (combine with doctor/compile)

## Do not

- Guess baud or port
- Depend on VS-Arduino or MCP
- Change FQBN

## Required args

| Arg | Meaning |
|-----|---------|
| `--port <path>` | Serial device (required) |
| `--baud <rate>` | Optional; default 9600 |

## Invocation

```bash
./bin/arduino-monitor --port /dev/cu.usbmodemXXXX
./bin/arduino-monitor --port /dev/cu.usbmodemXXXX --baud 115200
```

## Interpreting failures (agent checklist)

1. Run `./bin/arduino-doctor` — is the port listed? Is Uno FQBN present?
2. Confirm sketch compiles: `./bin/arduino-compile <sketch>`
3. Common issues:
   - **Port busy** — close other monitors/IDEs; retry once after user confirms
   - **Permission denied** — macOS/Linux serial permissions; do not sudo blindly
   - **Upload not in sync / avrdude** — press reset, correct Uno cable/port; re-ask for `--port`
   - **Garbage serial** — wrong baud; ask user for sketch `Serial.begin` rate
4. Never invent a port or FQBN

## Failure behavior

- Wrapper exits nonzero without `--port`
- `SUMMARY ok=false error=...` for scripting
