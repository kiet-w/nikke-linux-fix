#!/bin/bash
# ============================================================
# NIKKE Linux Fix — Bypass "Steam is Offline" Error
# https://github.com/kiet-w/nikke-linux-fix
#
# Fixes GODDESS OF VICTORY: NIKKE on Linux (Lutris Flatpak)
# by installing DW Proton and bypassing UMU's Steam env vars.
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║     🎮 NIKKE Linux Fix — Steam Bypass           ║"
echo "║     Fix 'Steam is offline' error on Lutris       ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ---- Configuration ----
LUTRIS_DATA="$HOME/.var/app/net.lutris.Lutris/data/lutris"
WINE_RUNNERS="$LUTRIS_DATA/runners/wine"
UMU_PATH="$LUTRIS_DATA/runtime/umu/umu-run"
DWPROTON_VERSION="dwproton-11.0-5"
DWPROTON_DIR="$WINE_RUNNERS/${DWPROTON_VERSION}-x86_64"
DWPROTON_URL="https://dawn.wine/dawn-winery/dwproton/releases/download/${DWPROTON_VERSION}/${DWPROTON_VERSION}-x86_64.tar.xz"
NIKKE_PREFIX="$HOME/Games/nikke"

# ---- Pre-checks ----
echo -e "${BLUE}[1/5]${NC} Checking prerequisites..."

if ! flatpak list 2>/dev/null | grep -q "net.lutris.Lutris"; then
    echo -e "${RED}✗ Lutris (Flatpak) not found. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Lutris (Flatpak) detected${NC}"

if [ ! -d "$LUTRIS_DATA" ]; then
    echo -e "${RED}✗ Lutris data directory not found at: $LUTRIS_DATA${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Lutris data directory found${NC}"

if [ ! -d "$NIKKE_PREFIX" ]; then
    echo -e "${YELLOW}  ⚠ NIKKE prefix not found at $NIKKE_PREFIX${NC}"
    read -rp "  Enter your NIKKE install path (wine prefix): " NIKKE_PREFIX
    if [ ! -d "$NIKKE_PREFIX" ]; then
        echo -e "${RED}✗ Directory does not exist: $NIKKE_PREFIX${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}  ✓ NIKKE prefix found at: $NIKKE_PREFIX${NC}"

# ---- Download DW Proton ----
echo ""
echo -e "${BLUE}[2/5]${NC} Installing DW Proton..."

if [ -d "$DWPROTON_DIR" ]; then
    echo -e "${GREEN}  ✓ DW Proton already installed at: $DWPROTON_DIR${NC}"
else
    echo -e "  Downloading ${DWPROTON_VERSION}..."
    TMP_FILE="/tmp/${DWPROTON_VERSION}.tar.xz"

    if [ -f "$TMP_FILE" ]; then
        echo -e "${YELLOW}  ⚠ Found cached download, reusing...${NC}"
    else
        curl -L -# -o "$TMP_FILE" "$DWPROTON_URL"
    fi

    echo -e "  Extracting to Lutris wine runners..."
    mkdir -p "$WINE_RUNNERS"
    tar -xf "$TMP_FILE" -C "$WINE_RUNNERS/"

    if [ -d "$DWPROTON_DIR" ]; then
        echo -e "${GREEN}  ✓ DW Proton installed successfully${NC}"
    else
        echo -e "${RED}✗ DW Proton extraction failed${NC}"
        exit 1
    fi
fi

# Verify wine binary
WINE_BIN="$DWPROTON_DIR/files/bin/wine"
if [ ! -f "$WINE_BIN" ]; then
    echo -e "${RED}✗ Wine binary not found at: $WINE_BIN${NC}"
    exit 1
fi
WINE_VER=$("$WINE_BIN" --version 2>/dev/null || echo "unknown")
echo -e "${GREEN}  ✓ Wine version: $WINE_VER${NC}"

# ---- Backup umu-run ----
echo ""
echo -e "${BLUE}[3/5]${NC} Backing up original umu-run..."

if [ -f "${UMU_PATH}.bak" ]; then
    echo -e "${GREEN}  ✓ Backup already exists at: ${UMU_PATH}.bak${NC}"
else
    if [ -f "$UMU_PATH" ]; then
        cp "$UMU_PATH" "${UMU_PATH}.bak"
        echo -e "${GREEN}  ✓ Backup created: ${UMU_PATH}.bak${NC}"
    else
        echo -e "${RED}✗ umu-run not found at: $UMU_PATH${NC}"
        exit 1
    fi
fi

# ---- Create wrapper script ----
echo ""
echo -e "${BLUE}[4/5]${NC} Creating umu-run wrapper script..."

cat > "$UMU_PATH" << 'WRAPPER_EOF'
#!/bin/bash
# ============================================================
# NIKKE Linux Fix — umu-run wrapper
# https://github.com/kiet-w/nikke-linux-fix
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
WRAPPER_EOF

chmod +x "$UMU_PATH"
echo -e "${GREEN}  ✓ Wrapper script created and made executable${NC}"

# ---- Fix broken symlinks ----
echo ""
echo -e "${BLUE}[5/5]${NC} Fixing wine prefix symlinks..."

USERS_DIR="$NIKKE_PREFIX/drive_c/users"
CURRENT_USER=$(whoami)

if [ -d "$USERS_DIR" ]; then
    # Fix steamuser directory
    if [ -L "$USERS_DIR/steamuser" ] && [ ! -e "$USERS_DIR/steamuser" ]; then
        echo -e "  Fixing broken steamuser symlink..."
        rm -f "$USERS_DIR/steamuser" "$USERS_DIR/$CURRENT_USER" 2>/dev/null
        mkdir -p "$USERS_DIR/steamuser"
        ln -sf steamuser "$USERS_DIR/$CURRENT_USER"
        echo -e "${GREEN}  ✓ Symlinks fixed${NC}"
    elif [ -L "$USERS_DIR/$CURRENT_USER" ] && [ ! -e "$USERS_DIR/$CURRENT_USER" ]; then
        echo -e "  Fixing broken user symlink..."
        rm -f "$USERS_DIR/$CURRENT_USER" 2>/dev/null
        if [ -d "$USERS_DIR/steamuser" ]; then
            ln -sf steamuser "$USERS_DIR/$CURRENT_USER"
        else
            mkdir -p "$USERS_DIR/steamuser"
            ln -sf steamuser "$USERS_DIR/$CURRENT_USER"
        fi
        echo -e "${GREEN}  ✓ Symlinks fixed${NC}"
    else
        echo -e "${GREEN}  ✓ Symlinks are OK${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ Users directory not found, skipping symlink fix${NC}"
fi

# ---- Done ----
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗"
echo -e "║  ${GREEN}✅ Fix applied successfully!${CYAN}                      ║"
echo -e "╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Launch NIKKE with:"
echo -e "  ${GREEN}flatpak run net.lutris.Lutris lutris:nikke${NC}"
echo ""
echo -e "  To revert:"
echo -e "  ${YELLOW}cp ${UMU_PATH}.bak $UMU_PATH${NC}"
echo ""
