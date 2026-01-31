# 🚀 Font Manager Quick Start

Hướng dẫn nhanh cài đặt và sử dụng Font Manager trong 5 phút!

## ⚡ Cài đặt Font cực nhanh

### 1️⃣ Mở Font Manager

```bash
./pkgman.zsh
```

Chọn **13** (Quản lý font chữ)

### 2️⃣ Cài Nerd Fonts (Khuyến nghị cho developer)

```
Chọn: 1 (Nerd Fonts)
Chọn: 1 (FiraCode) hoặc 8 (Cài tất cả)
```

### 3️⃣ Cài Emoji Fonts

```
Chọn: 3 (Emoji Fonts)
Xác nhận: y
```

### 4️⃣ Test hiển thị

```
Chọn: 12 (Test hiển thị)
```

## 🎯 Font nào nên cài?

### Cho Developer/Terminal
- ✅ **FiraCode Nerd Font** - Ligatures đẹp, icons đầy đủ
- ✅ **JetBrainsMono Nerd Font** - Thiết kế cho coding
- ✅ **Hack Nerd Font** - Sắc nét, rõ ràng

### Cho Desktop/Văn bản
- ✅ **Noto Fonts** - Đa ngôn ngữ, Google
- ✅ **Liberation Fonts** - Thay thế MS Office

### Cho Emoji
- ✅ **Noto Color Emoji** - Màu sắc đẹp

## ⚙️ Cấu hình Terminal (sau khi cài)

### Alacritty
```yaml
# ~/.config/alacritty/alacritty.yml
font:
  normal:
    family: "FiraCode Nerd Font"
  size: 12.0
```

### Kitty
```conf
# ~/.config/kitty/kitty.conf
font_family FiraCode Nerd Font Mono
font_size 12.0
```

### Wezterm
```lua
-- ~/.config/wezterm/wezterm.lua
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12.0
```

### Gnome Terminal / Konsole
- Preferences → Font → Chọn "FiraCode Nerd Font Mono"

## 🔧 Troubleshooting nhanh

### Icons hiển thị ô vuông (□)?
```
1. Cài Nerd Fonts (option 1)
2. Đặt font trong terminal settings
3. Đóng và mở lại terminal
```

### Font không hiển thị sau khi cài?
```
Chọn: 9 (Cập nhật cache)
Hoặc: fc-cache -fv
```

### Emoji không có màu?
```
1. Cài: option 3 (Emoji Fonts)
2. Dùng terminal: Kitty, Alacritty, Wezterm
```

## 📋 Menu Options nhanh

| Option | Chức năng |
|--------|-----------|
| **1** | Cài Nerd Fonts (dev) |
| **2** | Cài System Fonts |
| **3** | Cài Emoji Fonts |
| **4** | Cài CJK Fonts (中日韓) |
| **5** | Cài MS Fonts |
| **6** | Liệt kê font đã cài |
| **7** | Tìm kiếm font |
| **8** | Xóa font |
| **9** | Update cache |
| **12** | Test hiển thị |

## 🎨 Test nhanh

Chạy script test:
```bash
./font-preview.sh
```

Hoặc trong Font Manager chọn **12** (Test hiển thị)

## 💡 Tips

- 🔥 **Nerd Fonts** là bắt buộc cho terminal đẹp
- 😀 **Emoji Fonts** cần cho hiển thị emoji đầy màu
- 🌏 **CJK Fonts** chỉ cài nếu dùng tiếng Trung/Nhật/Hàn
- 🪟 **MS Fonts** chỉ cài nếu thực sự cần (license issues)

## 📖 Chi tiết hơn?

Đọc hướng dẫn đầy đủ: **[FONT_MANAGER_GUIDE.md](FONT_MANAGER_GUIDE.md)**

---

**Thời gian:** ~3 phút để cài font cơ bản  
**Khuyến nghị:** Cài FiraCode + Noto Emoji là đủ cho hầu hết nhu cầu! 🚀