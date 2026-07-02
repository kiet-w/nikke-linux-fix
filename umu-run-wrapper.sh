#!/bin/bash
# ============================================================
# NIKKE Linux Fix — umu-run wrapper (standalone)
# https://github.com/kiet-w/nikke-linux-fix
#
# Place this file at:
#   ~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run
#
# Bypasses UMU/Steam for NIKKE, uses DW Proton wine directly.
# All other games use original umu-run (umu-run.bak).
# ============================================================

# Convert args to lowercase for case-insensitive matching
# IMPORTANT: Game path is "NIKKE" (uppercase), must match both cases
args_lower="${*,,}"

if [[ "$args_lower" == *"nikke"* ]]; then
  # ---- NIKKE: Bypass Steam entirely ----
  # Unset all Steam-related env vars that trigger INTLSteam.dll
  unset SteamAppId SteamClientLaunch PROTON_VERB PROTONPATH UMU_LOG

  # Set wine environment
  export WINEPREFIX="${GAME_DIRECTORY:-$HOME/Games/nikke}"
  export WINEARCH=win64
  export WINEFSYNC=1
  export WINEESYNC=1

  # Run with DW Proton wine directly (no UMU, no Steam context)
  exec "$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/dwproton-11.0-5-x86_64/files/bin/wine" "$@"
else
  # ---- All other games: use original umu-run ----
  exec "$HOME/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run.bak" "$@"
fi
