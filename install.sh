#!/bin/bash
# ==============================================================================
# SCRIPT CÀI ĐẶT & THIẾT LẬP TỰ ĐỘNG CHO GODDESS OF VICTORY: NIKKE LINUX
# Tự động cấu hình lệnh `game1`, script tối ưu FPS & DXVK config
# Repository: https://github.com/kiet-w/nikke-linux-fix
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║    🚀 NIKKE Linux Fix & Optimizer - Automatic Setup Script           ║"
echo "║    Tự động thiết lập câu lệnh 'game1' và tối ưu hóa FPS Extreme     ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Sao chép play-nikke.sh và update-nikke.sh vào $HOME
echo -e "${BLUE}[1/4]${NC} Đang cài đặt các script khởi chạy vào $HOME..."
cp -f "$SCRIPT_DIR/play-nikke.sh" "$HOME/play-nikke.sh"
cp -f "$SCRIPT_DIR/update-nikke.sh" "$HOME/update-nikke.sh"
chmod +x "$HOME/play-nikke.sh" "$HOME/update-nikke.sh"
echo -e "${GREEN}  ✓ Đã lưu ~/play-nikke.sh và ~/update-nikke.sh${NC}"

# 2. Tạo đường dẫn ~/.local/bin và lệnh game1
echo -e "${BLUE}[2/4]${NC} Đang thiết lập lệnh 'game1'..."
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/game1" << 'EOF'
#!/bin/bash
exec "$HOME/play-nikke.sh" "$@"
EOF
chmod +x "$HOME/.local/bin/game1"
echo -e "${GREEN}  ✓ Đã tạo file thực thi: ~/.local/bin/game1${NC}"

# 3. Thêm alias game1 vào ~/.bashrc và ~/.zshrc
echo -e "${BLUE}[3/4]${NC} Đang cấu hình alias 'game1' trong Shell..."

add_alias_if_missing() {
    local rc_file="$1"
    if [ -f "$rc_file" ]; then
        if ! grep -q "alias game1=" "$rc_file"; then
            echo "" >> "$rc_file"
            echo "# NIKKE Linux Game Launcher Alias" >> "$rc_file"
            echo "alias game1='$HOME/play-nikke.sh'" >> "$rc_file"
            echo -e "${GREEN}  ✓ Đã thêm alias 'game1' vào $rc_file${NC}"
        else
            echo -e "${YELLOW}  ⚠ Alias 'game1' đã có sẵn trong $rc_file${NC}"
        fi
    fi
}

add_alias_if_missing "$HOME/.bashrc"
add_alias_if_missing "$HOME/.zshrc"

# 4. Sao chép dxvk.conf vào Wine Prefix của NIKKE
echo -e "${BLUE}[4/4]${NC} Đang áp dụng cấu hình tối ưu DXVK cho Intel iGPU / Unity Engine..."
NIKKE_GAME_DIR="$HOME/.local/share/Steam/steamapps/compatdata/2333075887/pfx/drive_c/NIKKE/NIKKE/game"

if [ -d "$NIKKE_GAME_DIR" ]; then
    cp -f "$SCRIPT_DIR/dxvk.conf" "$NIKKE_GAME_DIR/dxvk.conf"
    echo -e "${GREEN}  ✓ Đã cài đặt dxvk.conf vào: $NIKKE_GAME_DIR/dxvk.conf${NC}"
else
    echo -e "${YELLOW}  ⚠ Thư mục game NIKKE chưa tồn tại ($NIKKE_GAME_DIR).${NC}"
    echo -e "${YELLOW}    dxvk.conf sẽ được tự động áp dụng qua env DXVK_CONFIG_FILE khi chạy script ~/play-nikke.sh.${NC}"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗"
echo -e "║  ${GREEN}🎉 HOÀN TẤT THIẾT LẬP NIKKE LINUX!${CYAN}                                 ║"
echo -e "╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "🎮  Cách sử dụng:"
echo -e "    • Chạy game:  gõ ${GREEN}game1${NC} từ terminal bất kỳ (hoặc ${GREEN}~/play-nikke.sh${NC})"
echo -e "    • Cập nhật game:  chạy ${GREEN}~/update-nikke.sh${NC}"
echo ""
