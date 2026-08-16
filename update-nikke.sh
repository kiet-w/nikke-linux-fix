#!/bin/bash
# ==============================================================================
# SCRIPT CẬP NHẬT GAME GODDESS OF VICTORY: NIKKE (UPDATE & REPAIR)
# Chạy NIKKE Miniloader để cập nhật Launcher & Tải bản update mới nhất
# ==============================================================================

echo "🧹 [1/3] Dọn dẹp tiến trình NIKKE đang chạy ngầm..."
pkill -9 -f "nikke_launcher.exe" 2>/dev/null || true
pkill -9 -f "nikke.exe" 2>/dev/null || true
pkill -9 -f "nikkeminiloader" 2>/dev/null || true
pkill -9 -f "INTLWebViewHelper.exe" 2>/dev/null || true
pkill -9 -f "tbs_browser.exe" 2>/dev/null || true
wineserver -k 2>/dev/null || true

export DISPLAY="${DISPLAY:-:1}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Cấu hình Steam & Wine Prefix
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/2333075887"
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"

# Environment variables cho Proton
export PROTON_NO_XALIA=1
export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
export WINE_LARGE_ADDRESS_AWARE=1
export WINEESYNC=1
export WINEFSYNC=1
export WINEDEBUG="-all"

# Các đường dẫn Proton
DW_PROTON="$HOME/.steam/root/compatibilitytools.d/DW-Proton-11.0-5/proton"
GE_PROTON="$HOME/.steam/root/compatibilitytools.d/GE-Proton11-3/proton"
UMU_PROTON="$HOME/.steam/root/compatibilitytools.d/UMU-Proton-10.0-4/proton"
PROTON_EXP="$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/proton"

MINILOADER="$HOME/Downloads/nikkeminiloader_oG7STxbESBb.wg.intl.exe"
LAUNCHER="$WINEPREFIX/drive_c/NIKKE/Launcher/nikke_launcher.exe"

TARGET_EXE=""
if [ -f "$MINILOADER" ]; then
    echo "📦 Tìm thấy Miniloader Installer: $MINILOADER"
    TARGET_EXE="$MINILOADER"
else
    echo "🚀 Dùng Launcher mặc định: $LAUNCHER"
    TARGET_EXE="$LAUNCHER"
fi

echo "🔄 [2/3] Đang khởi chạy Trình Cập Nhật NIKKE..."
if [ -f "$DW_PROTON" ]; then
    echo "▶ Dùng runner: DW-Proton-11.0-5"
    exec "$DW_PROTON" run "$TARGET_EXE" "$@"
elif [ -f "$GE_PROTON" ]; then
    echo "▶ Dùng runner: GE-Proton11-3"
    exec "$GE_PROTON" run "$TARGET_EXE" "$@"
elif [ -f "$UMU_PROTON" ]; then
    echo "▶ Dùng runner: UMU-Proton-10.0-4"
    exec "$UMU_PROTON" run "$TARGET_EXE" "$@"
elif [ -f "$PROTON_EXP" ]; then
    echo "▶ Dùng runner: Proton - Experimental"
    exec "$PROTON_EXP" run "$TARGET_EXE" "$@"
else
    exec wine "$TARGET_EXE" "$@"
fi
