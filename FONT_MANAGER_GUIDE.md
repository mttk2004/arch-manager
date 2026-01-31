# 🔤 Font Manager - Hướng dẫn Quản lý Font Chữ

Hướng dẫn chi tiết về module quản lý font chữ trong Arch Package Manager.

## 📋 Mục lục

- [Giới thiệu](#giới-thiệu)
- [Các loại font](#các-loại-font)
- [Cài đặt Font](#cài-đặt-font)
- [Quản lý Font](#quản-lý-font)
- [Cấu hình Terminal](#cấu-hình-terminal)
- [FAQ](#faq)

## 🎯 Giới thiệu

Font Manager là module tích hợp trong Arch Package Manager giúp bạn dễ dàng:

- ✅ Cài đặt font từ kho chính thức và AUR
- ✅ Quản lý font đã cài (liệt kê, tìm kiếm, xóa)
- ✅ Cập nhật cache font tự động
- ✅ Test hiển thị font với icons, emoji, ligatures
- ✅ Hỗ trợ đầy đủ các loại font: Nerd Fonts, System, Emoji, CJK

## 📚 Các loại font

### 1. 🚀 Nerd Fonts (cho Developer)

**Nerd Fonts** là các font monospace được patch với hơn 3,600 glyphs (icons) từ các bộ icon phổ biến như:
- Font Awesome
- Devicons
- Octicons
- Material Design Icons
- Weather Icons
- v.v.

**Ưu điểm:**
- Hiển thị đẹp icons trong terminal, vim, neovim
- Hỗ trợ powerline symbols
- Programming ligatures (optional)
- Rất phù hợp cho developer

**Font Nerd phổ biến:**

| Font | Đặc điểm | Phù hợp cho |
|------|----------|-------------|
| **FiraCode Nerd** | Ligatures đẹp, dễ đọc | Code editor, Terminal |
| **JetBrainsMono Nerd** | Thiết kế cho coding, ligatures | IntelliJ, VSCode, Terminal |
| **Hack Nerd** | Rõ ràng, sắc nét | Terminal, Code |
| **Meslo Nerd** | Fork của Menlo (macOS) | Terminal, Code |
| **SourceCodePro Nerd** | Adobe, professional | Code editor |
| **UbuntuMono Nerd** | Đơn giản, hiện đại | Ubuntu users |

**Cách cài:**
```
Chọn: 13 (Quản lý font) → 1 (Nerd Fonts) → Chọn font
```

### 2. 🖥️ System Fonts

Font hệ thống dùng cho giao diện desktop, ứng dụng, văn bản.

**Các bộ font:**

| Package | Mô tả |
|---------|-------|
| `noto-fonts` | Google Noto - hỗ trợ đa ngôn ngữ (khuyến nghị) |
| `ttf-dejavu` | DejaVu - mặc định nhiều distro Linux |
| `ttf-liberation` | Thay thế MS Office fonts (Arial, Times, Courier) |
| `gnu-free-fonts` | GNU FreeFont - tương thích với MS fonts |
| `ttf-ubuntu-font-family` | Ubuntu fonts - hiện đại, đẹp |
| `ttf-roboto` | Google Roboto - Material Design |

**Cách cài:**
```
Chọn: 13 → 2 (System Fonts) → Chọn bộ font
```

### 3. 😀 Emoji Fonts

Font hiển thị emoji và biểu tượng cảm xúc.

**Packages:**
- `noto-fonts-emoji` - Google Noto Color Emoji (khuyến nghị)
- `ttf-joypixels` - JoyPixels (trước đây là EmojiOne)
- `ttf-twemoji` - Twitter Emoji

**Tính năng:**
- Hiển thị emoji đầy màu sắc: 😀 🚀 ❤️ 🎉
- Hỗ trợ Unicode Emoji mới nhất
- Tích hợp tốt với các ứng dụng

**Cách cài:**
```
Chọn: 13 → 3 (Emoji Fonts)
```

### 4. 🇯🇵 CJK Fonts (Chinese, Japanese, Korean)

Font hỗ trợ tiếng Trung, Nhật, Hàn.

**Packages:**
- `noto-fonts-cjk` - Google Noto CJK (khuyến nghị)
- `adobe-source-han-sans-otc-fonts` - Adobe Source Han Sans
- `adobe-source-han-serif-otc-fonts` - Adobe Source Han Serif
- `wqy-zenhei`, `wqy-microhei` - WenQuanYi Chinese fonts

**Cách cài:**
```
Chọn: 13 → 4 (CJK Fonts) → Chọn bộ font
```

### 5. 🪟 Microsoft Fonts

Font Microsoft (Arial, Times New Roman, Comic Sans, v.v.)

**Lưu ý:**
- ⚠️ Cần AUR helper (yay/paru)
- ⚠️ Có thể vi phạm bản quyền nếu không có license
- ⚠️ Chỉ cài nếu thực sự cần thiết

**Package:** `ttf-ms-fonts` (AUR)

**Cách cài:**
```
Chọn: 13 → 5 (MS Fonts)
```

## 🛠️ Cài đặt Font

### Menu Cài đặt Font

Từ menu chính, chọn option **13 (Quản lý font chữ)**, bạn sẽ thấy:

```
═══ Cài đặt Font ═══
1. Cài đặt Nerd Fonts (lập trình)
2. Cài đặt font hệ thống (Noto, DejaVu)
3. Cài đặt font emoji
4. Cài đặt font CJK (Tiếng Trung/Nhật/Hàn)
5. Cài đặt font Windows (MS Fonts)
```

### Ví dụ: Cài FiraCode Nerd Font

1. Chọn `1` - Nerd Fonts
2. Chọn `1` - FiraCode Nerd Font
3. Chờ cài đặt hoàn tất
4. Font cache sẽ tự động được cập nhật
5. Đóng và mở lại terminal

### Cài tất cả Nerd Fonts phổ biến

1. Chọn `1` - Nerd Fonts
2. Chọn `8` - Cài tất cả
3. Xác nhận và chờ cài đặt

## 📋 Quản lý Font

### 6. Liệt kê font đã cài

Hiển thị tất cả packages font đã cài trên hệ thống:

```
Chọn: 13 → 6 (Liệt kê font đã cài)
```

Kết quả hiển thị:
- Tên package
- Mô tả ngắn
- Tổng số packages

### 7. Tìm kiếm font

Tìm kiếm font trong kho pacman và AUR:

```
Chọn: 13 → 7 (Tìm kiếm font)
Nhập: fira
```

Kết quả hiển thị:
- Font từ kho chính thức
- Font từ AUR (nếu có yay/paru)

### 8. Xóa font

Xóa font package đã cài:

```
Chọn: 13 → 8 (Xóa font)
Chọn số thứ tự font cần xóa
Xác nhận
```

### 9. Cập nhật cache font

Quét và rebuild cache font:

```
Chọn: 13 → 9 (Cập nhật cache)
```

**Khi nào cần update cache:**
- Sau khi cài/xóa font
- Font không hiển thị đúng
- Thêm font thủ công vào `~/.local/share/fonts`

## 👁️ Kiểm tra & Xem

### 10. Xem font families

Liệt kê các font families khả dụng theo loại:

```
Chọn: 13 → 10 (Xem font families)
```

Hiển thị:
- Monospace fonts (Code/Terminal)
- Sans-Serif fonts
- Serif fonts

### 11. Xem chi tiết font

Xem thông tin chi tiết về một font cụ thể:

```
Chọn: 13 → 11 (Xem chi tiết)
Nhập tên font: FiraCode
```

### 12. Test hiển thị font

Test hiển thị với các ký tự đặc biệt:

```
Chọn: 13 → 12 (Test hiển thị)
```

Test bao gồm:
- ✅ Box drawing & Powerline symbols
- ✅ Icons & Symbols
- ✅ Emoji
- ✅ Programming ligatures
- ✅ Numbers & Math symbols
- ✅ CJK characters
- ✅ Colors
- ✅ Alphabet

## 🖥️ Cấu hình Terminal

Sau khi cài font, bạn cần cấu hình terminal để sử dụng font mới.

### Alacritty

File: `~/.config/alacritty/alacritty.yml` hoặc `alacritty.toml`

```yaml
font:
  normal:
    family: "FiraCode Nerd Font"
    style: Regular
  bold:
    family: "FiraCode Nerd Font"
    style: Bold
  italic:
    family: "FiraCode Nerd Font"
    style: Italic
  size: 12.0
```

### Kitty

File: `~/.config/kitty/kitty.conf`

```conf
font_family      FiraCode Nerd Font Mono
bold_font        FiraCode Nerd Font Mono Bold
italic_font      FiraCode Nerd Font Mono Italic
font_size        12.0
```

### Wezterm

File: `~/.config/wezterm/wezterm.lua`

```lua
local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 12.0

return config
```

### Gnome Terminal

1. Mở Preferences (Ctrl+,)
2. Chọn Profile → Text
3. Tắt "Use system font"
4. Chọn "FiraCode Nerd Font Mono"
5. Đặt size phù hợp

### Konsole (KDE)

1. Settings → Edit Current Profile
2. Appearance → Font
3. Chọn "FiraCode Nerd Font Mono"
4. Đặt size và Apply

### Terminator

File: `~/.config/terminator/config`

```ini
[profiles]
  [[default]]
    font = FiraCode Nerd Font Mono 12
    use_system_font = False
```

### Tilix

1. Preferences → Profiles → Default
2. Text → Custom Font
3. Chọn "FiraCode Nerd Font Mono"

## 🎨 Cấu hình Code Editor

### VSCode / VSCodium

File: `settings.json`

```json
{
  "editor.fontFamily": "'FiraCode Nerd Font', 'JetBrainsMono Nerd Font', monospace",
  "editor.fontSize": 14,
  "editor.fontLigatures": true
}
```

### Neovim / Vim

Font được điều khiển bởi terminal, không cần config trong vim.

Nhưng có thể set cho GUI:

```vim
" For GUI vim/neovim
set guifont=FiraCode\ Nerd\ Font\ Mono:h12
```

### Sublime Text

Preferences → Settings:

```json
{
  "font_face": "FiraCode Nerd Font",
  "font_size": 12
}
```

### Emacs

File: `init.el` hoặc `.emacs`

```elisp
(set-face-attribute 'default nil
                    :family "FiraCode Nerd Font"
                    :height 120)
```

## ❓ FAQ

### Font không hiển thị sau khi cài?

1. Cập nhật cache: Chọn option 9
2. Đóng và mở lại terminal/ứng dụng
3. Kiểm tra font có trong danh sách:
   ```bash
   fc-list | grep FiraCode
   ```

### Icons hiển thị dạng ô vuông (□)?

Nguyên nhân:
- Chưa cài Nerd Fonts
- Font hiện tại không có icons
- Terminal chưa dùng font mới

Giải pháp:
1. Cài Nerd Fonts (option 1)
2. Đặt font trong terminal settings
3. Đóng và mở lại terminal

### Emoji không có màu?

Một số terminal không hỗ trợ color emoji. Giải pháp:

1. Cài emoji font: `noto-fonts-emoji`
2. Dùng terminal hỗ trợ: Kitty, Alacritty, Wezterm
3. Không dùng: xterm, urxvt (không hỗ trợ color emoji)

### Ligatures không hoạt động?

1. Kiểm tra font có ligatures: FiraCode, JetBrainsMono
2. Enable ligatures trong editor:
   - VSCode: `"editor.fontLigatures": true`
   - Terminal: Tùy terminal (Kitty, Alacritty hỗ trợ)

### Làm sao biết terminal đang dùng font gì?

Phụ thuộc terminal:

```bash
# Kitty
kitty +list-fonts --psnames

# Alacritty: check config file
cat ~/.config/alacritty/alacritty.yml | grep font

# General: check process
ps aux | grep -i terminal
```

### Font bị lag khi scroll?

Nguyên nhân: Font quá nặng hoặc terminal chậm.

Giải pháp:
1. Dùng font nhẹ hơn: Hack, Ubuntu Mono
2. Giảm font size
3. Dùng terminal hiệu suất cao: Alacritty, Kitty

### Cài font thủ công vào đâu?

Có 2 nơi:

1. **User-specific** (khuyến nghị):
   ```bash
   ~/.local/share/fonts/
   ```

2. **System-wide**:
   ```bash
   /usr/share/fonts/
   ```

Sau khi copy font vào, chạy:
```bash
fc-cache -fv
```

### Xóa font thủ công?

1. Xóa file font:
   ```bash
   rm ~/.local/share/fonts/FontName.ttf
   ```

2. Cập nhật cache:
   ```bash
   fc-cache -fv
   ```

### Nerd Fonts vs Powerline Fonts?

**Powerline Fonts:**
- Chỉ có powerline symbols (arrows, branches)
- Không có icons

**Nerd Fonts:**
- Bao gồm tất cả powerline symbols
- Thêm 3,600+ icons
- Thay thế hoàn toàn Powerline Fonts

→ **Khuyến nghị dùng Nerd Fonts**

### Font nào tốt nhất cho coding?

Top 5 khuyến nghị:

1. **FiraCode Nerd Font** - Ligatures đẹp, đầy đủ icons
2. **JetBrainsMono Nerd Font** - Thiết kế cho code
3. **Hack Nerd Font** - Sắc nét, dễ đọc
4. **Cascadia Code Nerd** - Microsoft, ligatures
5. **Iosevka Nerd Font** - Mỏng, compact

**Tùy thích cá nhân!** Hãy thử nhiều font để tìm font phù hợp nhất.

### Làm sao test font trước khi cài terminal?

Có thể dùng online:

1. **Programming Fonts**: https://www.programmingfonts.org/
2. **Nerd Fonts**: https://www.nerdfonts.com/font-downloads
3. **Google Fonts**: https://fonts.google.com/

Hoặc cài vào browser để test trước.

## 🔧 Tips & Tricks

### 1. Cài nhiều font cùng lúc

```bash
# Thủ công qua pacman
sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-hack-nerd noto-fonts-emoji

# Hoặc dùng Font Manager option 8
```

### 2. Fallback fonts

Đặt fallback trong config terminal:

```yaml
# Alacritty
font:
  normal:
    family: "FiraCode Nerd Font"
  fallback:
    - "Noto Color Emoji"
    - "Noto Sans CJK"
```

### 3. Optimize font rendering

File: `~/.config/fontconfig/fonts.conf`

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="autohint" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hintstyle" mode="assign">
      <const>hintslight</const>
    </edit>
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="lcdfilter" mode="assign">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
```

### 4. Script auto-config terminal font

Tạo script để tự động đổi font:

```bash
#!/bin/bash
# set-terminal-font.sh

FONT="FiraCode Nerd Font Mono"

# Alacritty
if [ -f ~/.config/alacritty/alacritty.yml ]; then
    sed -i "s/family: .*/family: \"$FONT\"/" ~/.config/alacritty/alacritty.yml
fi

# Kitty
if [ -f ~/.config/kitty/kitty.conf ]; then
    sed -i "s/font_family .*/font_family $FONT/" ~/.config/kitty/kitty.conf
fi

# Update cache
fc-cache -fv

echo "Font đã được đổi thành: $FONT"
```

## 📚 Tài liệu tham khảo

- [Nerd Fonts Official](https://www.nerdfonts.com/)
- [Arch Wiki - Fonts](https://wiki.archlinux.org/title/Fonts)
- [Google Noto Fonts](https://fonts.google.com/noto)
- [Programming Fonts Test](https://www.programmingfonts.org/)
- [Fontconfig Documentation](https://www.freedesktop.org/wiki/Software/fontconfig/)

## 🤝 Đóng góp

Nếu bạn có đề xuất font hoặc cải tiến Font Manager, vui lòng:

1. Tạo issue trên GitHub
2. Submit pull request
3. Chia sẻ config font của bạn

---

**Happy font hunting! 🔤✨**