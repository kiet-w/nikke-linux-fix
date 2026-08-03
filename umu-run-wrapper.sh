#!/bin/bash
# ============================================================
# NIKKE Linux Fix + FPS Boost — umu-run wrapper
# https://github.com/kiet-w/nikke-linux-fix
# ============================================================

args_lower="${*,,}"

if [[ "$args_lower" == *"nikke"* ]]; then
  # ---- NIKKE: Bypass Steam entirely ----
  unset SteamAppId SteamClientLaunch PROTON_VERB PROTONPATH UMU_LOG

  export WINEPREFIX="${GAME_DIRECTORY:-$HOME/Games/nikke}"
  export WINEARCH=win64
  export WINEFSYNC=1
  export WINEESYNC=1
  export WINE_LARGE_ADDRESS_AWARE=1
  export WINEDEBUG=-all
  export WINEDLLOVERRIDES="dxgi,d3d11,d3d10core,d3d9=n,b"

  DW="$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/dwproton-11.0-5-x86_64"
  if [ ! -d "$DW" ]; then
    DW="$HOME/.local/share/lutris/runners/wine/dwproton-11.0-5-x86_64"
  fi

  DXVK_DIR="$HOME/.local/share/lutris/runtime/dxvk/v2.4.1"
  if [ -d "$DXVK_DIR" ]; then
    cp -rn "$DXVK_DIR/x64/"*.dll "$WINEPREFIX/drive_c/windows/system32/" 2>/dev/null
    cp -rn "$DXVK_DIR/x32/"*.dll "$WINEPREFIX/drive_c/windows/syswow64/" 2>/dev/null
  fi

  if [ -d "$DW/files/share/default_pfx/drive_c/windows/system32" ]; then
    cp -rn "$DW/files/share/default_pfx/drive_c/windows/system32/"* "$WINEPREFIX/drive_c/windows/system32/" 2>/dev/null
    cp -rn "$DW/files/share/default_pfx/drive_c/windows/syswow64/"* "$WINEPREFIX/drive_c/windows/syswow64/" 2>/dev/null
  fi

  export LD_LIBRARY_PATH="$DW/files/lib/x86_64-linux-gnu:$DW/files/lib/i386-linux-gnu:$DW/files/lib/wine/x86_64-unix:$DW/files/lib/wine/i386-unix:${LD_LIBRARY_PATH:-}"

  if [ -f /usr/share/vulkan/icd.d/intel_icd.json ]; then
    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.json
  fi

  # DXVK & GPU Performance Tweaks
  export DXVK_LOG_LEVEL=none
  export DXVK_STATE_CACHE=1
  export DXVK_STATE_CACHE_PATH="$WINEPREFIX"
  export DXVK_ASYNC=1
  export DXVK_GPLASYNCCACHE=1

  export MESA_GL_VERSION_OVERRIDE=4.6COMPAT
  export MESA_GLSL_VERSION_OVERRIDE=460
  export mesa_glthread=true
  export INTEL_DEBUG=noccs
  export ANV_ENABLE_PIPELINE_CACHE=1

  export __GL_SHADER_DISK_CACHE=1
  export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
  export MESA_SHADER_CACHE_DIR="$WINEPREFIX/mesa_cache"
  export MESA_SHADER_CACHE_MAX_SIZE=2G

  mkdir -p "$WINEPREFIX/mesa_cache"

  exec "$DW/files/bin/wine" explorer /desktop=NIKKE,1280x720 "$@"
else
  # ---- All other games: use original umu-run ----
  if [ -f "$HOME/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run.bak" ]; then
    exec "$HOME/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run.bak" "$@"
  fi
fi
