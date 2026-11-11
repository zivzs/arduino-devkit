# arduino-devkit

Pinned **Arduino Uno / `arduino:avr:uno`** toolchain and thin Cursor agent skills. The source of truth is a **from-source `arduino-cli`** plus **ArduinoCore-avr 1.8.6** in Docker; skills wrap argv-safe `bin/` scripts.

v1 scope: **Uno only**. No MCP server. No ESP32.

## Pins

See [VERSIONS.md](VERSIONS.md):

- `arduino-cli` **v1.5.1** built with **Go ≥ 1.26**
- `ArduinoCore-avr` **1.8.6**
- FQBN **`arduino:avr:uno`**
- Image tag **`arduino-devkit:uno`**

## Quick start (Docker-first)

```bash
git clone https://github.com/zivzs/arduino-devkit.git
cd arduino-devkit

# Build the hermetic image (once)
docker build -t arduino-devkit:uno -f toolchain/Dockerfile .

# Compile the Blink example (also the CI-style gate)
./tests/test_compile_blink.sh

# Or via wrapper (uses the image when present)
./bin/arduino-compile examples/Blink
./bin/arduino-doctor
```

Hermetic compile runs with `--network=none`, `--cap-drop=ALL`, and `--security-opt=no-new-privileges`.

### Flash / serial (host USB)

Upload and monitor need a real serial device. Wrappers **require** `--port` and do not guess:

```bash
./bin/arduino-doctor                          # list ports
./bin/arduino-flash --port /dev/cu.usbmodemXXXX examples/Blink
./bin/arduino-monitor --port /dev/cu.usbmodemXXXX --baud 9600
```

## Host install (optional)

Docker remains recommended for compile. For a local CLI + wrappers on `PATH`:

```bash
# Requires Go 1.26+
./toolchain/install-local.sh
export PATH="$PWD/.local/bin:$PATH"
```

`toolchain/build-cli.sh` alone builds only `arduino-cli` into `.local/bin`.

## Wrapper CLI

| Script | Role |
|--------|------|
| `bin/arduino-doctor` | CLI version, Uno FQBN, `board list` |
| `bin/arduino-scaffold` | New sketch + `sketch.yaml` (`default_fqbn: arduino:avr:uno`) |
| `bin/arduino-compile` | Compile Uno sketch |
| `bin/arduino-flash` | Compile + upload (**`--port` required**) |
| `bin/arduino-monitor` | Serial monitor (**`--port` required**, `--baud` optional) |

All scripts support `--help`, exit nonzero on failure, and print a final `SUMMARY key=value ...` line for agents. Invocations use argv arrays (no shell string execution).

Environment:

| Variable | Meaning |
|----------|---------|
| `ARDUINO_DEVKIT_MODE` | `auto` (default), `docker`, or `host` |
| `ARDUINO_DEVKIT_IMAGE` | Image tag (default `arduino-devkit:uno`) |
| `ARDUINO_CLI` | Host binary override |
| `FORCE_REBUILD=1` | Rebuild image in `tests/test_compile_blink.sh` |

## Cursor skills install

Skills live in this repo under `skills/*/SKILL.md`. They are **not** part of any other monorepo.

Symlink or copy into your Cursor agent skills path, for example:

```bash
# User-level skills (adjust if your Cursor skills root differs)
SKILLS_ROOT="${HOME}/.cursor/skills"
# or project: <your-project>/.agents/skills

mkdir -p "${SKILLS_ROOT}"
for s in arduino-doctor arduino-scaffold arduino-compile arduino-flash arduino-serial-debug; do
  ln -sfn "$(pwd)/skills/${s}" "${SKILLS_ROOT}/${s}"
done
```

Ensure `bin/` is on `PATH` or invoke scripts with an absolute path from the skill instructions.

| Skill | Script |
|-------|--------|
| `arduino-doctor` | `bin/arduino-doctor` |
| `arduino-scaffold` | `bin/arduino-scaffold` |
| `arduino-compile` | `bin/arduino-compile` |
| `arduino-flash` | `bin/arduino-flash` |
| `arduino-serial-debug` | `bin/arduino-monitor` (+ doctor/compile for diagnosis) |

## Security notes

- Wrappers call `arduino-cli` with argv only (no `eval` / no shell interpolation of sketch paths into a shell string).
- Docker compile path drops capabilities and disables network.
- Cores come from the pinned image (GitHub clone of ArduinoCore-avr), not broad package-index auto-install in agent flows.
- Agents must not invent serial ports or FQBNs.

## Optional: VS-Arduino companion

Editor users may install the [zivzs/VS-Arduino](https://github.com/zivzs/VS-Arduino) fork branch **`security-fixes`** as an optional VS Code / Cursor extension companion. **Agent skills do not depend on the VSIX**; compile/flash/monitor go through this repo’s CLI wrappers.

## Layout

```
arduino-devkit/
  README.md
  VERSIONS.md
  toolchain/Dockerfile
  toolchain/build-cli.sh
  toolchain/install-local.sh
  bin/arduino-{doctor,scaffold,compile,flash,monitor}
  skills/*/SKILL.md
  examples/Blink/
  tests/test_compile_blink.sh
```

## Out of scope (v1)

- Non-AVR / ESP32 boards
- MCP server
- Shipping or requiring the VS-Arduino VSIX inside skills
