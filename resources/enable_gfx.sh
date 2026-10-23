#!/usr/bin/env bash
#
# Enable GPU-accelerated OpenGL under WSL.
#
#   enable_gfx.sh <command> [args...]   run a command with the GPU enabled
#   enable_gfx.sh                       start an interactive shell with it enabled
#   enable_gfx.sh --check               report which renderer the settings select
#   source enable_gfx.sh                export into the current shell
#
# Both variables are required, and the failure modes are silent:
#   neither                 -> llvmpipe (software rasterisation on the CPU)
#   GALLIUM_DRIVER only     -> D3D12 on the *Intel integrated* GPU
#   adapter name only       -> llvmpipe (no effect without the driver selection)
# MESA_LOADER_DRIVER_OVERRIDE does not select a Gallium driver and will not work here.

export GALLIUM_DRIVER=d3d12
export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA
export GALLIUM_THREAD=0

# Sourced: the exports above are the whole job.
(return 0 2>/dev/null) && return 0

if [[ "${1-}" == "--check" ]]; then
    if ! command -v glxinfo >/dev/null; then
        echo "glxinfo not found (apt install mesa-utils)" >&2
        exit 1
    fi
    info=$(glxinfo -B 2>/dev/null)
    renderer=$(sed -n 's/^OpenGL renderer string: //p' <<<"$info" | head -1)
    accel=$(sed -n 's/^ *Accelerated: //p' <<<"$info" | head -1)
    echo "renderer:    ${renderer:-unknown}"
    echo "accelerated: ${accel:-unknown}"
    case "$renderer" in
        *llvmpipe*) echo "WARNING: software rasteriser" >&2; exit 1 ;;
        *Intel*)    echo "WARNING: integrated GPU, not the discrete one" >&2; exit 1 ;;
    esac
    exit 0
fi

if [[ $# -gt 0 ]]; then
    exec "$@"
else
    exec "${SHELL:-/bin/bash}"
fi
