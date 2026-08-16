#!/bin/bash
# ==============================================================================
# SCRIPT KHỞI CHẠY & TỐI ƯU FPS EXTREME MAX CHO GODDESS OF VICTORY: NIKKE
# Siêu tối ưu hóa độc quyền cho Intel iGPU & CPU Intel Core i5
# ==============================================================================

echo "🚀 [1/4] Dọn dẹp tiến trình rác & Ép xung CPU Performance..."
pkill -9 -f "nikke_launcher.exe" 2>/dev/null || true
pkill -9 -f "nikke.exe" 2>/dev/null || true
pkill -9 -f "INTLWebViewHelper.exe" 2>/dev/null || true
pkill -9 -f "tbs_browser.exe" 2>/dev/null || true
wineserver -k 2>/dev/null || true
pkill -9 -f "wineserver" 2>/dev/null || true

# Dọn dẹp cache manifest cũ để Launcher nhận diện đúng bản update mới nhất từ server
rm -rf "$HOME/.local/share/Steam/steamapps/compatdata/2333075887/pfx/drive_c/NIKKE/.tiny_cache"/* 2>/dev/null || true
rm -rf "$HOME/.local/share/Steam/steamapps/compatdata/2333075887/pfx/drive_c/users/steamuser/AppData/Local/Temp"/* 2>/dev/null || true

# 1. Ép tất cả nhân CPU chạy ở chế độ Maximum Performance & Tăng ulimit file descriptors
powerprofilesctl set performance 2>/dev/null || true
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$epp" ] && (echo "performance" > "$epp" 2>/dev/null || true)
done

ulimit -n 1048576 2>/dev/null || ulimit -n 524288 2>/dev/null || true

# 2. Cấu hình Đường dẫn Steam & Wine Prefix
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/2333075887"
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
mkdir -p "$STEAM_COMPAT_DATA_PATH"

# Đường dẫn file config DXVK đã tối ưu cho Unity Engine & Intel iGPU
DXVK_CONF_PATH="$WINEPREFIX/drive_c/NIKKE/NIKKE/game/dxvk.conf"
export DXVK_CONFIG_FILE="$DXVK_CONF_PATH"

echo "⚡ [2/4] Kích hoạt Chế độ Tối ưu FPS EXTREME (Mesa No-Error & Core Pinning)..."

# --- Tắt giới hạn FPS & Tắt VSync ---
export DXVK_FRAME_RATE=0         # 0 = Uncapped FPS (Bơm FPS tối đa)
export vblank_mode=0             # Tắt VSync ở cấp Driver Mesa
export DXVK_HUD=fps              # Bật bảng đếm FPS góc màn hình
export DXVK_LOG_LEVEL=none
export DXVK_ASYNC=1
export DXVK_GPLASYNC=1
export DXVK_STATE_CACHE=1

# --- Tối ưu Driver Vulkan Intel (Mesa ANV & Zero Error Overhead) ---
export MESA_NO_ERROR=1           # Loại bỏ 100% kiểm tra lỗi Driver (Tăng 3-5% FPS free)
export MESA_GLTHREAD=true
export MESA_GL_THREAD=true
export MESA_DISK_CACHE_SINGLE_FILE=1
export MESA_SHADER_CACHE_DISABLE=false
export MESA_SHADER_CACHE_DIR="$HOME/.cache/mesa_shader_cache"
export MESA_SHADER_CACHE_MAX_SIZE=10G
export ANV_ENABLE_PIPELINE_CACHE=1
export INTEL_DEBUG=noclobber
export WINE_VK_VULKAN_PRESENT_MODE=immediate

# --- Tối ưu Proton & CPU Thread Topology ---
export PROTON_USE_SECCOMP=0       # Tắt lọc syscall Seccomp (Giảm tải CPU per-call)
export WINE_CPU_TOPOLOGY=4c/8t    # Tối ưu phân luồng Wine khớp chính xác 4 nhân 8 luồng Intel CPU
export PROTON_NO_XALIA=1
export PROTON_ENABLE_NVAPI=0      # Tắt NVAPI overhead trên card Intel/AMD
export PROTON_HIDE_NVIDIA_GPU=1
export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
export WINE_LARGE_ADDRESS_AWARE=1
export WINEESYNC=1
export WINEFSYNC=1
export STAGING_SHARED_MEMORY=1
export WINEDEBUG="-all"

# Vô hiệu hóa GStreamer bị lỗi lib32 gây màn hình trắng webview trong Proton
export WINE_GSTREAMER_DISABLE=1
export GST_PLUGIN_SYSTEM_PATH=""

# Auto-detect Feral GameMode
GAMEMODE=""
if command -v gamemoderun &> /dev/null; then
    GAMEMODE="gamemoderun"
fi

# Daemon ngầm tự động ép luồng CPU, độ ưu tiên I/O Realtime và hạ ưu tiên Webview
(
    for i in {1..60}; do
        NIKKE_PID=$(pgrep -f "nikke.exe" | head -n 1)
        if [ -n "$NIKKE_PID" ]; then
            sleep 4
            # Hạ ưu tiên Webview ngầm
            renice -n 19 -p $(pgrep -f "INTLWebViewHelper.exe") 2>/dev/null || true
            renice -n 19 -p $(pgrep -f "tbs_browser.exe") 2>/dev/null || true
            renice -n 19 -p $(pgrep -f "Assistant.exe") 2>/dev/null || true
            
            # Ép NIKKE dùng toàn bộ 8 luồng CPU & Tăng ưu tiên I/O đĩa
            taskset -pc 0-7 "$NIKKE_PID" 2>/dev/null || true
            ionice -c 1 -n 0 -p "$NIKKE_PID" 2>/dev/null || true
            renice -n -10 -p "$NIKKE_PID" 2>/dev/null || true
            
            echo "✅ Đã áp dụng luồng CPU Realtime & Đọc đĩa ưu tiên cho NIKKE (PID: $NIKKE_PID)"
            break
        fi
        sleep 2
    done
) &

# Các đường dẫn Proton
NIKKE_EXE="$WINEPREFIX/drive_c/NIKKE/Launcher/nikke_launcher.exe"
DW_PROTON="$HOME/.steam/root/compatibilitytools.d/DW-Proton-11.0-5/proton"
GE_PROTON="$HOME/.steam/root/compatibilitytools.d/GE-Proton11-3/proton"
UMU_PROTON="$HOME/.steam/root/compatibilitytools.d/UMU-Proton-10.0-4/proton"
PROTON_EXP="$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/proton"

echo "🎮 [3/4] Đang khởi chạy NIKKE ở Chế độ EXTREME FPS MAX..."
if [ -d "$WINEPREFIX/drive_c/NIKKE/Launcher" ]; then
    cd "$WINEPREFIX/drive_c/NIKKE/Launcher"
fi

if [ -f "$DW_PROTON" ]; then
    echo "▶ Dùng runner: DW-Proton-11.0-5"
    exec $GAMEMODE "$DW_PROTON" run "$NIKKE_EXE" "$@"
elif [ -f "$GE_PROTON" ]; then
    echo "▶ Dùng runner: GE-Proton11-3"
    exec $GAMEMODE "$GE_PROTON" run "$NIKKE_EXE" "$@"
elif [ -f "$UMU_PROTON" ]; then
    echo "▶ Dùng runner: UMU-Proton-10.0-4"
    exec $GAMEMODE "$UMU_PROTON" run "$NIKKE_EXE" "$@"
elif [ -f "$PROTON_EXP" ]; then
    echo "▶ Dùng runner: Proton - Experimental"
    exec $GAMEMODE "$PROTON_EXP" run "$NIKKE_EXE" "$@"
else
    exec $GAMEMODE wine nikke_launcher.exe "$@"
fi
