# 🛠️ Hướng Dẫn Cài Đặt GODDESS OF VICTORY: NIKKE Trên Linux

Hướng dẫn chi tiết quy trình cài đặt và cấu hình **GODDESS OF VICTORY: NIKKE** trên Linux (Lutris Flatpak) giúp khắc phục triệt để lỗi "Steam is Offline" và tối ưu hóa hiệu năng game.

---

## 📋 Yêu Cầu Tiền Đề

1. **Lutris (Flatpak)**:
   ```bash
   flatpak install flathub net.lutris.Lutris
   ```
2. **File Cài Đặt NIKKE**:
   - Tải file `nikkeminiloader_*.exe` từ trang chủ NIKKE (hoặc file installer PC client).

---

## 🚀 Các Bước Cài Đặt

### Bước 1: Khởi Chạy Script Fix Tự Động

Tải repository và chạy script cài đặt tự động:

```bash
git clone https://github.com/kiet-w/nikke-linux-fix.git
cd nikke-linux-fix
chmod +x fix-nikke-steam.sh install/fix-nikke-steam.sh
./fix-nikke-steam.sh
```

**Script sẽ tự động:**
- Tải & giải nén **DW Proton 11.0-5** vào thư mục runners của Lutris.
- Backup `umu-run` gốc và cài đặt wrapper script bypass kiểm tra Steam.
- Tạo thư mục Wine Prefix `~/Games/nikke` và sửa lỗi symlinks user.

---

### Bước 2: Chạy Installer NIKKE Với DW Proton

Chạy file installer `.exe` trong môi trường Wine của NIKKE:

```bash
WINEPREFIX=$HOME/Games/nikke \
$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/dwproton-11.0-5-x86_64/files/bin/wine \
~/Downloads/nikkeminiloader_oG7STxbESBb.wg.intl.exe
```

Hoàn tất các bước cài đặt trên giao diện NIKKE Miniloader (mặc định game sẽ cài vào `C:\NIKKE`).

---

### Bước 3: Cấu Hình Lutris Launcher

1. Mở **Lutris**.
2. Thêm game mới (nhấn dấu `+` -> *Add a locally installed game*):
   - **Name**: `GODDESS OF VICTORY: NIKKE`
   - **Runner**: `Wine (Runs Windows games)`
3. Trong tab **Game options**:
   - **Executable**: `$HOME/Games/nikke/drive_c/NIKKE/launcher/nikke_launcher.exe`
   - **Wine prefix**: `$HOME/Games/nikke`
4. Trong tab **Runner options**:
   - **Wine version**: `dwproton-11.0-5-x86_64`
   - **Enable DXVK**: ON
   - **Enable Esync / Fsync**: ON

---

### Bước 4: Tối Ưu Hệ Thống (Tăng FPS)

Chạy script tối ưu hệ thống trước khi chơi game (cần quyền root):

```bash
sudo ./boost-system.sh
```

Script sẽ tự động:
- Đặt CPU Governor sang `performance`.
- Mở khóa xung nhịp CPU tối đa & bật Turbo Boost.
- Điều chỉnh `vm.swappiness=10` và tăng `vm.max_map_count=2147483642`.
- Tối ưu I/O scheduler cho ổ cứng SSD/NVMe.

---

## 🎮 Khởi Chạy Game

Mở game trực tiếp qua ứng dụng **Lutris** hoặc chạy lệnh:

```bash
flatpak run net.lutris.Lutris lutris:nikke
```

---

## 🛠️ Xử Lý Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Cách khắc phục |
|---|---|---|
| `Steam is offline` | Lỗi UMU SteamAppId env | Chạy lại `./fix-nikke-steam.sh` |
| Launcher bị văng ngay | Thiếu `INTLSteam.dll` | Không xóa các file DLL của game |
| Giật lag / Low FPS | Thiếu Shader cache | Chạy `sudo ./boost-system.sh` và bật DXVK Async |

---

## 📜 Giấy Phép
Dự án được phân phối dưới giấy phép [MIT License](../LICENSE).
