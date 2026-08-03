#!/bin/bash
# ============================================================
# NIKKE Linux Fix + FPS Boost — umu-run wrapper
# https://github.com/kiet-w/nikke-linux-fix
#
# Bypasses UMU/Steam for NIKKE + applies all performance tweaks
# for Intel iGPU (Iris Plus / UHD) and dedicated GPUs.
# ============================================================

# Convert args to lowercase for case-insensitive matching
args_lower="${*,,}"

if [[ "$args_lower" == *"nikke"* ]]; then
  # ---- NIKKE: Bypass Steam entirely ----
  unset SteamAppId SteamClientLaunch PROTON_VERB PROTONPATH UMU_LOG

  # ---- Wine environment ----
  export WINEPREFIX="${GAME_DIRECTORY:-$HOME/Games/nikke}"
  export WINEARCH=win64
  export WINEFSYNC=1
  export WINEESYNC=1
  export WINE_LARGE_ADDRESS_AWARE=1
  export WINEDEBUG=-all

  # ---- DXVK Performance ----
  export DXVK_LOG_LEVEL=none
  export DXVK_STATE_CACHE=1
  export DXVK_STATE_CACHE_PATH="$WINEPREFIX"
  export DXVK_CONFIG_FILE=""
  export DXVK_ASYNC=1
  export DXVK_GPLASYNCCACHE=1

  # ---- Mesa / Intel GPU Performance ----
  export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
  export MESA_GLSL_VERSION_OVERRIDE=460
  export mesa_glthread=true
  export INTEL_DEBUG=noccs
  export ANV_ENABLE_PIPELINE_CACHE=1
  if [ -f /usr/share/vulkan/icd.d/intel_icd.x86_64.json ]; then
    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
  fi

  # ---- Shader Cache ----
  export __GL_SHADER_DISK_CACHE=1
  export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
  export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
  export MESA_SHADER_CACHE_DIR="$WINEPREFIX/mesa_cache"
  export MESA_SHADER_CACHE_MAX_SIZE=2G

  # ---- Reduce CPU overhead ----
  export __GL_YIELD="NOTHING"
  export __GL_THREADED_OPTIMIZATIONS=1
  export STAGING_WRITECOPY=1
  export STAGING_SHARED_MEMORY=1

  # ---- Disable telemetry / unnecessary services ----
  export PROTON_NO_FSYNC=0
  export PROTON_FORCE_LARGE_ADDRESS_AWARE=1

  # Create shader cache dir
  mkdir -p "$WINEPREFIX/mesa_cache"

  exec "$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/dwproton-11.0-5-x86_64/files/bin/wine" "$@"
else
  # ---- All other games: use original umu-run ----
  exec "$HOME/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run.bak" "$@"
fi
