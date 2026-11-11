# arduino-devkit: pinned from-source arduino-cli + ArduinoCore-avr 1.8.6 (Uno only)
# See VERSIONS.md for pins.

FROM golang:1.26-bookworm AS cli-build
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
# Pin: arduino-cli v1.5.1 (01f3d4f2ba7c2eaafb5dc710c8a1903af7762fea)
ARG ARDUINO_CLI_REF=v1.5.1
RUN git clone --depth 1 --branch "${ARDUINO_CLI_REF}" https://github.com/arduino/arduino-cli.git .
RUN go build -ldflags "-X github.com/arduino/arduino-cli/internal/version.versionString=${ARDUINO_CLI_REF} -X github.com/arduino/arduino-cli/internal/version.commit=$(git rev-parse HEAD)" -o /out/arduino-cli .

FROM debian:bookworm-slim AS final
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      git ca-certificates \
      gcc-avr avr-libc binutils-avr avrdude \
    && rm -rf /var/lib/apt/lists/*

COPY --from=cli-build /out/arduino-cli /usr/local/bin/arduino-cli
RUN arduino-cli version

# AVR core from official GitHub source only (no package-index core install)
# Pin: ArduinoCore-avr 1.8.6 (42fa4a1ea1b1b11d1cc0a60298e529d37f9d14bd)
ARG AVR_CORE_REF=1.8.6
WORKDIR /opt/hardware/arduino
RUN git clone --depth 1 --branch "${AVR_CORE_REF}" https://github.com/arduino/ArduinoCore-avr.git avr
WORKDIR /opt/hardware/arduino/avr
RUN test -f boards.txt && test -f platform.txt && test -f cores/arduino/Arduino.h
# Point toolchain at distro avr-gcc / avrdude instead of runtime.tools downloads
RUN printf '%s\n' \
  'compiler.path=/usr/bin/' \
  'tools.avrdude.path=' \
  'tools.avrdude.cmd.path=/usr/bin/avrdude' \
  'tools.avrdude.config.path=/etc/avrdude.conf' \
  > platform.local.txt \
 && cat platform.local.txt

ENV ARDUINO_DIRECTORIES_USER=/opt
ENV ARDUINO_DIRECTORIES_DATA=/opt/arduino-data
ENV HOME=/opt/arduino-home
ENV XDG_CACHE_HOME=/opt/arduino-home/.cache

# Config + warm builtin discovery / compile cache for Uno
RUN mkdir -p /opt/arduino-data /opt/arduino-home/.cache /opt/warmup/Blink \
 && printf '%s\n' 'void setup(){}' 'void loop(){}' > /opt/warmup/Blink/Blink.ino \
 && arduino-cli config init --dest-dir /opt/arduino-data \
 && arduino-cli config set directories.user /opt \
 && arduino-cli config set directories.data /opt/arduino-data \
 && arduino-cli board listall arduino:avr:uno \
 && arduino-cli compile --fqbn arduino:avr:uno /opt/warmup/Blink \
 && rm -rf /opt/warmup

WORKDIR /work
RUN useradd -m -u 10001 -s /bin/bash arduino \
 && chown -R arduino:arduino /opt /work
USER arduino
ENTRYPOINT ["arduino-cli"]
CMD ["version"]
