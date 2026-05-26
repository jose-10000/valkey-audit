# --- Stage 1: Build (Builder) ---
FROM debian:trixie-slim AS builder

# Install required tools for building and downloading
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Download the specific header into the current working directory
RUN wget https://raw.githubusercontent.com/valkey-io/valkey/9.1.0/src/valkeymodule.h

# 2. Copy the repository source code into the container
COPY . .

# 3. Execute CMake commands to build the module
RUN mkdir build && \
    cmake -S . -B build && \
    cmake --build build --target all

# --- Stage 2: Clean Final Image ---
FROM debian:trixie-slim

WORKDIR /opt/modules

# Copy ONLY the compiled .so file from the builder stage
# This leaves out gcc, cmake, wget, and the source code, keeping the image pristine
COPY --from=builder /app/build/libvalkeyaudit.so.1.0.0 ./libvalkeyaudit.so

# Default command (useful for the Helm initContainer to copy the file)
CMD ["cp", "/opt/modules/libvalkeyaudit.so", "/target/"]
