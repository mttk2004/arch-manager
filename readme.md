# Arch Package Manager 🚀

Trình quản lý gói tập trung cho Arch Linux và các distro dựa trên Arch, sử dụng zsh với giao diện menu tương tác hiện đại, đầy màu sắc.

> **Version 2.1.0** - Modular Architecture

## 📁 Cấu trúc dự án

```
arch-zsh-manager/
├── bin/              # Executable entry points
│   └── pkgman        # Main application
├── lib/              # Modular libraries
│   ├── core/         # Core modules (colors, UI, detection, utils)
│   ├── package/      # Package management
│   ├── system/       # System maintenance
│   ├── advanced/     # Advanced features
│   ├── font/         # Font management
│   └── devtools/     # Development tools
├── docs/             # Documentation
├── scripts/          # Utility scripts
├── config/           # Configuration (future)
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## ✨ Tính năng

### 🎯 Quản lý gói từ nhiều nguồn
- **pacman** - Gói chính thức từ kho Arch
- **AUR** - Hỗ trợ yay/paru
- **Flatpak** - Ứng dụng sandbox (nếu có cài)

### 🛠️ Chức năng chính

#### Hệ thống gói
- ✅ Cài đặt gói từ nhiều nguồn
- ✅ Xóa gói (với/không dependencies)
- ✅ Cập nhật hệ thống (toàn bộ hoặc từng nguồn)
- ✅ Tìm kiếm gói
- ✅ Xem thông tin chi tiết gói

#### Bảo trì hệ thống
- 🧹 Dọn dẹp cache (pacman, AUR, Flatpak)
- 🗑️ Xóa gói orphan (không còn cần thiết)
- 📋 Liệt kê gói đã cài
- 🔍 Kiểm tra gói bị hỏng

#### Nâng cao
- ⬇️ Downgrade gói về phiên bản cũ
- 📜 Xem log cài đặt/gỡ bỏ gói
- 🌐 Quản lý mirror (reflector)
- 🔧 Tự động cài đặt YAY nếu chưa có

#### 🔤 Quản lý Font Chữ - MỚI!
- **Nerd Fonts**: FiraCode, JetBrainsMono, Hack, Meslo (cho terminal/code editor)
- **System Fonts**: Noto, DejaVu, Liberation, Ubuntu, Roboto
- **Emoji Fonts**: Noto Emoji, JoyPixels, Twemoji
- **CJK Fonts**: Hỗ trợ tiếng Trung, Nhật, Hàn
- **MS Fonts**: Arial, Times New Roman, Verdana (từ AUR)
- Liệt kê, tìm kiếm, xóa font
- Cập nhật cache font tự động
- Test hiển thị font và icons

> 📖 Xem chi tiết: [FONT_MANAGER_GUIDE.md](FONT_MANAGER_GUIDE.md)  
> 🚀 Quick Start: [FONT_QUICKSTART.md](FONT_QUICKSTART.md)

#### 🛠️ Môi trường phát triển (Development Tools)
- **Web Development**: PHP Stack, Laravel, Node.js (npm, yarn, pnpm)
- **Databases**: PostgreSQL, MySQL/MariaDB, MongoDB, Redis
- **Programming Languages**: Java (JDK), Python (pip, poetry), Go, Rust
- **DevOps Tools**: Docker & Docker Compose, Git & GitHub CLI
- Cài đặt nhanh, tự động cấu hình, kiểm tra version

> 📖 Xem chi tiết: [DEV_TOOLS_GUIDE.md](DEV_TOOLS_GUIDE.md)

## 📦 Yêu cầu

### Bắt buộc
- **Arch Linux** hoặc distro dựa trên Arch (Manjaro, EndeavourOS, v.v.)
- **zsh** - Z shell

### Tùy chọn (khuyến nghị)
- **yay** hoặc **paru** - AUR helper (script có thể tự cài yay)
- **flatpak** - Nếu muốn quản lý ứng dụng Flatpak
- **reflector** - Cho tính năng cập nhật mirror
- **downgrade** - Cho tính năng hạ cấp gói
- **pacman-contrib** - Cho lệnh paccache

## 🚀 Cài đặt và Sử dụng

Dự án hiện tại được viết bằng Python kết hợp với backend Zsh, mang lại giao diện TUI hiện đại và mượt mà hơn.

### Phương pháp 1: File thực thi độc lập (Khuyên dùng)
Cách này giúp bạn chạy tool mà không cần bận tâm đến phiên bản Python trên máy, cực kỳ tiện lợi kể cả khi bạn cài lại Arch Linux.

```bash
# 1. Clone repository
git clone https://github.com/mttk2004/arch-zsh-manager.git
cd arch-zsh-manager

# 2. Build file nhị phân (chỉ cần làm 1 lần)
chmod +x build.sh
./build.sh

# 3. Sử dụng
./dist/pkgman

# (Tùy chọn) Copy vào hệ thống để dùng lệnh 'pkgman' ở bất cứ đâu:
sudo cp dist/pkgman /usr/local/bin/
```

### Phương pháp 2: Chạy trực tiếp qua Python Virtual Environment
Nếu bạn muốn đóng góp code hoặc chạy trực tiếp từ mã nguồn:

```bash
# 1. Clone repository
git clone https://github.com/mttk2004/arch-zsh-manager.git
cd arch-zsh-manager

# 2. Tạo và kích hoạt môi trường ảo
python -m venv venv
source venv/bin/activate

# 3. Cài đặt dependencies
pip install -e .

# 4. Chạy tool
python pkgman.py
```

## 📖 Hướng dẫn sử dụng

### Khởi chạy

```bash
# Nếu bạn đã copy file build vào /usr/local/bin
pkgman

# Hoặc nếu chạy từ mã nguồn (nhớ kích hoạt venv trước)
python pkgman.py
```

Khi chạy tool, bạn sẽ thấy một giao diện Terminal UI (TUI) tương tác trực quan. Sử dụng **phím mũi tên** để di chuyển, phím **Enter** để chọn, hoặc gõ phím tắt tương ứng.

Các tính năng nổi bật mới cập nhật:
- **Service Manager**: Quản lý các systemd service với tính năng tìm kiếm fuzzy search.
- **Alias Manager**: Thêm/sửa/xoá các zsh aliases an toàn và nhanh chóng.
- **Giao diện đa cột**: Liệt kê các package với bố cục thông minh tận dụng tối đa chiều rộng màn hình.

### Ví dụ sử dụng

#### Cài đặt gói
1. Chọn `1` - Cài đặt gói
2. Chọn nguồn: pacman (1), AUR (2), hoặc Flatpak (3)
3. Nhập tên gói
4. Xác nhận cài đặt

#### Quản lý Font
1. Chọn `13` - Quản lý font chữ
2. Chọn loại font cần cài:
   - Nerd Fonts (FiraCode, JetBrainsMono, Hack...)
   - System Fonts (Noto, DejaVu, Liberation...)
   - Emoji Fonts
   - CJK Fonts (Chinese, Japanese, Korean)
   - MS Fonts (cần AUR helper)
3. Liệt kê, tìm kiếm hoặc xóa font đã cài
4. Test hiển thị để kiểm tra font

#### Dọn dẹp hệ thống
1. Chọn `6` - Dọn dẹp cache
2. Chọn mức độ dọn dẹp:
   - Giữ 3 phiên bản gần nhất
   - Xóa toàn bộ cache
   - Xóa cache AUR

#### Cập nhật hệ thống
1. Chọn `3` - Cập nhật hệ thống
2. Chọn nguồn cập nhật:
   - Chỉ pacman
   - Pacman + AUR
   - Flatpak
   - Tất cả

## 🏗️ Kiến trúc module

### Core Modules

- **colors.zsh** - Định nghĩa màu sắc, icons, text styles
- **ui.zsh** - UI components (boxes, badges, menus, prompts)
- **detect.zsh** - Phát hiện hệ thống, packages, services
- **utils.zsh** - Hàm tiện ích (validation, string, file, logging)

### Feature Modules

Các module chức năng được tổ chức theo category:
- `lib/package/` - Quản lý gói
- `lib/system/` - Bảo trì hệ thống
- `lib/advanced/` - Tính năng nâng cao
- `lib/font/` - Quản lý font
- `lib/devtools/` - Công cụ phát triển

Xem chi tiết: `docs/PROJECT_STRUCTURE.md`

## 🎨 Tính năng nổi bật

### 🔄 Tự động phát hiện AUR Helper
Script tự động phát hiện và sử dụng `yay` hoặc `paru` nếu có cài đặt.

### 🔤 Quản lý Font tích hợp
- Cài đặt font từ kho chính thức và AUR
- Hỗ trợ đầy đủ Nerd Fonts cho developer
- Tự động cập nhật cache sau khi cài/xóa
- Test hiển thị trực quan với icons, emoji, ligatures

### 🎯 Giao diện menu trực quan
- Sử dụng màu sắc để dễ phân biệt
- Menu phân cấp rõ ràng
- Xác nhận trước khi thực hiện thao tác nguy hiểm

### 🛡️ An toàn
- Xác nhận trước khi xóa cache toàn bộ
- Hiển thị danh sách gói orphan trước khi xóa
- Sao lưu mirrorlist trước khi cập nhật

### 📱 Đa nguồn
Quản lý gói từ pacman, AUR, và Flatpak trong một giao diện thống nhất.

## 🔧 Cấu hình nâng cao

### Thay đổi số phiên bản cache giữ lại

Mở file `pkgman.zsh` và tìm dòng:

```bash
sudo paccache -r
```

Thay đổi thành (ví dụ giữ 5 phiên bản):

```bash
sudo paccache -rk5
```

### Tùy chỉnh cấu hình reflector

Trong hàm `mirror_management()`, tìm dòng:

```bash
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

Tùy chỉnh theo nhu cầu:
- `--latest 20`: Số mirror mới nhất
- `--protocol https`: Giao thức (https, http, rsync)
- `--sort rate`: Sắp xếp theo (rate, age, delay)
- `--country 'Vietnam,Singapore'`: Lọc theo quốc gia

## 🐛 Xử lý sự cố

### Script không chạy được

```bash
# Kiểm tra zsh đã cài chưa
which zsh

# Cài đặt zsh nếu chưa có
sudo pacman -S zsh

# Kiểm tra quyền thực thi
ls -l bin/pkgman

# Cấp quyền nếu cần
chmod +x bin/pkgman
```

### Không tìm thấy AUR helper

Script có tùy chọn cài đặt YAY tự động (chọn 13 trong menu chính).

Hoặc cài thủ công:

```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Lệnh paccache không hoạt động

```bash
sudo pacman -S pacman-contrib
```

## 📝 Lưu ý

- **Cần quyền sudo**: Hầu hết các thao tác cần quyền root
- **AUR**: Luôn kiểm tra PKGBUILD trước khi cài gói từ AUR
- **Cache**: Nên dọn dẹp cache định kỳ để tiết kiệm dung lượng
- **Mirror**: Cập nhật mirror định kỳ để tăng tốc độ tải xuống

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Hãy tạo issue hoặc pull request.

### Cách đóng góp
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Tạo module mới trong `lib/` (xem `lib/README.md`)
4. Test kỹ lưỡng
5. Commit thay đổi (`git commit -m 'feat: add some amazing feature'`)
6. Push lên branch (`git push origin feature/AmazingFeature`)
7. Tạo Pull Request

### Tạo module mới

Xem hướng dẫn chi tiết trong:
- `lib/README.md` - Module structure
- `docs/REFACTORING_PLAN.md` - Development plan
- `docs/PROJECT_STRUCTURE.md` - Project organization

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết

## 👨‍💻 Tác giả

Được phát triển với ❤️ cho cộng đồng Arch Linux

## 🙏 Lời cảm ơn

- Arch Linux team
- Cộng đồng AUR
- Các nhà phát triển yay, paru, reflector

## 📞 Liên hệ & Hỗ trợ

- **Issues**: Báo lỗi hoặc đề xuất tính năng tại [GitHub Issues]
- **Wiki**: Tài liệu chi tiết tại [Arch Wiki](https://wiki.archlinux.org/)

---

## ⚡ Demo nhanh

Sau khi cài đặt, chỉ cần gõ:
```bash
pkgman
```

Bạn sẽ thấy menu đầy màu sắc:
- 🟢 **Số xanh** - Các lựa chọn chính
- 🟡 **Tiêu đề vàng** - Phân loại chức năng  
- 🔴 **Số đỏ** - Thoát chương trình
- 🔵 **Text xanh dương** - Nhập liệu

**Tất cả thao tác chỉ cần nhập số, không cần gõ lệnh dài!**

---

## 🔄 Migration Notes

Dự án đã được refactor sang kiến trúc modular. Xem chi tiết:
- `docs/REFACTORING_SUMMARY.md` - Tổng kết refactoring
- `docs/REFACTORING_PLAN.md` - Kế hoạch chi tiết
- `MIGRATION_NOTES.md` - Hướng dẫn migration

**Old**: `./pkgman.zsh` (deprecated)  
**New**: `./bin/pkgman` ✅

---

## ⚠️ Lưu ý quan trọng

- ✅ Script này là công cụ hỗ trợ, giúp bạn quản lý gói dễ dàng hơn
- ✅ Luôn đọc output trước khi xác nhận các thao tác quan trọng
- ✅ Với gói AUR, nên kiểm tra PKGBUILD trước khi cài
- ✅ Khuyến khích tìm hiểu pacman/yay để hiểu rõ hơn về hệ thống

**Enjoy your Arch experience! 🚀 BTW, I use Arch!**
