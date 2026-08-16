# 🎮 NIKKE Linux Fix & Extreme Performance Launcher

> **GODDESS OF VICTORY: NIKKE** on Linux (Steam / Proton / Lutris) — Ultimate Setup, Automatic `game1` Shortcut & Extreme FPS Optimization for Intel iGPU & Mid/Low-end CPUs.

![Platform](https://img.shields.io/badge/Platform-Linux-yellow)
![Runner](https://img.shields.io/badge/Proton-DW--Proton%20%7C%20GE--Proton-green)
![Shortcut](https://img.shields.io/badge/Shortcut-game1-blue)
![Status](https://img.shields.io/badge/Status-Tested%20%26%20Working-brightgreen)

---

## 🇻🇳 Hướng Dẫn Nhanh (Vietnamese)

### 🚀 Cài Đặt Tự Động 1-Click
Mở Terminal và chạy lệnh sau để tự động cấu hình lệnh `game1`, script khởi chạy và tối ưu DXVK:

```bash
git clone https://github.com/kiet-w/nikke-linux-fix.git
cd nikke-linux-fix
chmod +x install.sh
./install.sh
```

### ⚡ Cách Sử Dụng Lệnh `game1`
Sau khi chạy `./install.sh`, bạn chỉ cần gõ:
- **Khởi chạy game**: Gõ `game1` từ bất kỳ màn hình Terminal nào (hoặc chạy `~/play-nikke.sh`).
- **Cập nhật / Sửa lỗi game**: Chạy lệnh `~/update-nikke.sh`.

---

## 🇬🇧 Quick Start (English)

### 🚀 1-Click Automated Setup
Clone the repository and run `install.sh` to automatically install launcher scripts, configure the terminal shortcut `game1`, and apply DXVK graphics tweaks:

```bash
git clone https://github.com/kiet-w/nikke-linux-fix.git
cd nikke-linux-fix
chmod +x install.sh
./install.sh
```

### 🎮 Usage
- **Launch Game**: Simply type `game1` in any terminal window (or run `~/play-nikke.sh`).
- **Update Game**: Run `~/update-nikke.sh`.

---

## 📁 Repository Overview

| File / Folder | Mô tả (Description) |
|---|---|
| 📄 `install.sh` | Script cài đặt tự động toàn bộ môi trường, thiết lập shortcut `game1` & DXVK config. |
| 📄 `play-nikke.sh` | Script khởi chạy game với siêu tối ưu hóa (Mesa No-Error, CPU Core Pinning, uncap FPS, dọn cache). |
| 📄 `update-nikke.sh` | Script cập nhật NIKKE Miniloader & Launcher. |
| 📄 `dxvk.conf` | File cấu hình DXVK D3D11 tối ưu dành riêng cho Intel iGPU & Unity Engine. |
| 📄 `fix-nikke-steam.sh` | Fix lỗi "Steam is offline" cho Lutris (Flatpak) thông qua UMU wrapper & DW-Proton. |

---

## ⚡ High-Performance Tweaks Included

1. **CPU & Thread Topology**:
   - Auto locks CPU cores for NIKKE (`taskset -pc 0-7`).
   - Sets high Realtime I/O & CPU priority (`renice`, `ionice`).
   - Lowers background Webview process overhead (`INTLWebViewHelper.exe`, `tbs_browser.exe`).

2. **Mesa Graphics Driver Tuning**:
   - Enables `MESA_NO_ERROR=1` for zero driver overhead (3-5% extra FPS boost).
   - Enables Mesa Shader Cache (`10GB` limit) & GPL Async compilation.

3. **DXVK Ultra Tweaks (`dxvk.conf`)**:
   - Uncaps FPS (`DXVK_FRAME_RATE=0`, `vblank_mode=0`).
   - Disables Nvidia NVAPI hack on Intel/AMD GPUs.
   - Lowers tessellation overhead on Intel iGPU (`d3d11.maxTessellationFactor = 0`).

---

## 🛠 Fix Lutris "Steam is Offline" Error

If launching via Lutris flatpak gives `Steam is offline, please log in from Steam`, run the dedicated Lutris fix script:

```bash
./fix-nikke-steam.sh
```

---

## 📜 License

MIT License — see [LICENSE](LICENSE)
