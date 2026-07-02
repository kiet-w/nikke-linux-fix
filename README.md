# 🎮 NIKKE Linux Fix — Bypass "Steam is Offline" Error

> Fix for **GODDESS OF VICTORY: NIKKE** on Linux when using **Lutris** (Flatpak).
> Bypasses the "Steam is offline, please log in from Steam" error that blocks the launcher.

![Platform](https://img.shields.io/badge/Platform-Linux-yellow)
![Launcher](https://img.shields.io/badge/Launcher-Lutris%20(Flatpak)-blue)
![Proton](https://img.shields.io/badge/Proton-DW%20Proton%2011.0--5-green)
![Status](https://img.shields.io/badge/Status-Working-brightgreen)

---

## 📋 Problem

When launching NIKKE on Linux via **Lutris**, the launcher shows:

```
Notice
Steam is offline, please log in from Steam.
[CONFIRM]
```

- Clicking **X** → game exits immediately
- Clicking **CONFIRM** → game exits immediately
- The game is **completely unplayable** because of this modal

### Root Cause

Lutris uses **UMU** (a Steam Runtime compatibility layer) to run games with Proton. UMU automatically sets the environment variable `SteamAppId=0`, which tells the NIKKE launcher's `INTLSteam.dll` that the game was launched from a Steam context. The DLL then tries to connect to a Steam client that doesn't exist → "Steam is offline" → forced exit.

---

## ✅ Solution

The fix has **2 parts**:
1. Install **DW Proton** (Dawn Winery Proton) — a custom Proton fork optimized for anime/gacha games
2. Create a **wrapper script** that bypasses UMU and removes all Steam environment variables for NIKKE

---

## 🚀 Quick Install (Automated)

```bash
git clone https://github.com/kiet-w/nikke-linux-fix.git
cd nikke-linux-fix
chmod +x fix-nikke-steam.sh
./fix-nikke-steam.sh
```

The script will:
- Download and install DW Proton 11.0-5 into Lutris
- Backup the original `umu-run`
- Create a wrapper script that bypasses Steam for NIKKE
- Fix broken user symlinks in the wine prefix

---

## 🔧 Manual Install

### Step 1: Download DW Proton

```bash
# Download DW Proton 11.0-5
curl -L -o /tmp/dwproton.tar.xz \
  https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-11.0-5/dwproton-11.0-5-x86_64.tar.xz

# Extract to Lutris wine runners directory
tar -xf /tmp/dwproton.tar.xz \
  -C ~/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
```

### Step 2: Backup original umu-run

```bash
UMU_PATH=~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run

# Only backup if not already backed up
if [ ! -f "${UMU_PATH}.bak" ]; then
  cp "$UMU_PATH" "${UMU_PATH}.bak"
fi
```

### Step 3: Create the wrapper script

Replace `~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run` with:

```bash
#!/bin/bash
# NIKKE Linux Fix - Bypass Steam offline error
# https://github.com/kiet-w/nikke-linux-fix

# Convert args to lowercase for case-insensitive matching
args_lower="${*,,}"

if [[ "$args_lower" == *"nikke"* ]]; then
  # Bypass UMU/Steam entirely - use DW Proton wine directly
  unset SteamAppId SteamClientLaunch PROTON_VERB PROTONPATH UMU_LOG
  export WINEPREFIX="$GAME_DIRECTORY"
  export WINEARCH=win64
  export WINEFSYNC=1
  export WINEESYNC=1
  exec ~/.var/app/net.lutris.Lutris/data/lutris/runners/wine/dwproton-11.0-5-x86_64/files/bin/wine "$@"
else
  # All other games use original umu-run
  exec ~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run.bak "$@"
fi
```

Make it executable:
```bash
chmod +x ~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run
```

### Step 4: Fix broken symlinks (if needed)

```bash
NIKKE_PREFIX=~/Games/nikke  # Change this to your NIKKE install path

# Fix broken user directory symlinks
if [ -L "$NIKKE_PREFIX/drive_c/users/steamuser" ] && [ ! -e "$NIKKE_PREFIX/drive_c/users/steamuser" ]; then
  rm "$NIKKE_PREFIX/drive_c/users/steamuser" "$NIKKE_PREFIX/drive_c/users/$(whoami)" 2>/dev/null
  mkdir -p "$NIKKE_PREFIX/drive_c/users/steamuser"
  ln -s steamuser "$NIKKE_PREFIX/drive_c/users/$(whoami)"
fi
```

### Step 5: Launch the game

```bash
flatpak run net.lutris.Lutris lutris:nikke
```

---

## ⚠️ Important Notes

### What NOT to do
- ❌ **Don't delete `INTLSteam.dll`** — the launcher needs it for authentication
- ❌ **Don't delete `steam_api64.dll`** — causes integrity check failures
- ❌ **Don't use `WINEDLLOVERRIDES` to disable Steam DLLs** — causes crash (return code 63232)
- ❌ **Don't just delete Steam files from `drive_c`** — the env var `SteamAppId` is the real trigger, not the files

### What actually works
- ✅ **Unset `SteamAppId` environment variable** — this is the key fix
- ✅ **Use DW Proton instead of GE-Proton via UMU** — DW Proton runs wine directly without Steam context
- ✅ **Case-insensitive path matching** — the game path uses `NIKKE` (uppercase), your script must handle this

### Reverting the fix

To restore original behavior:
```bash
UMU_PATH=~/.var/app/net.lutris.Lutris/data/lutris/runtime/umu/umu-run
cp "${UMU_PATH}.bak" "$UMU_PATH"
```

---

## 🖥️ Tested Environment

| Component | Version |
|-----------|---------|
| **OS** | Ubuntu (HP Pavilion Laptop 14-ce3xxx) |
| **Launcher** | Lutris (Flatpak) |
| **Proton** | DW Proton 11.0-5 (Dawn Winery) |
| **Wine** | wine-11.0 (CachyOS) |
| **Game** | GODDESS OF VICTORY: NIKKE (PC Client) |

---

## 🤝 Credits

- [Dawn Winery / DW Proton](https://dawn.wine/dawn-winery/dwproton) — Custom Proton fork for anime/gacha games
- [Lutris](https://lutris.net/) — Open source game launcher for Linux
- [UMU-Launcher](https://github.com/Open-Wine-Components/umu-launcher) — Steam Runtime compatibility layer

---

## 📜 License

MIT License — see [LICENSE](LICENSE)
