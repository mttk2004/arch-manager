# Arch Package Manager 🚀

Trình quản lý gói tập trung cho Arch Linux và các distro dựa trên Arch, sử dụng zsh với giao diện menu tương tác đầy màu sắc.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Shell](https://img.shields.io/badge/shell-zsh-green.svg)
![Platform](https://img.shields.io/badge/platform-Arch%20Linux-1793d1.svg)

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

## 📦 Yêu cầu

### Bắt buộc
- **Arch Linux** hoặc distro dựa trên Arch (Manjaro, EndeavourOS, v.v.)
- **zsh** - Z shell
- **sudo** - Quyền root

### Tùy chọn (khuyến nghị)
- **yay** hoặc **paru** - AUR helper (script có thể tự cài yay)
- **flatpak** - Nếu muốn quản lý ứng dụng Flatpak
- **reflector** - Cho tính năng cập nhật mirror
- **downgrade** - Cho tính năng hạ cấp gói
- **pacman-contrib** - Cho lệnh paccache

## 🚀 Cài đặt

### Phương pháp 1: Tự động (Khuyến nghị)

```bash
# Clone repository
git clone https://github.com/mttk2004/arch-zsh-manager.git
cd arch-zsh-manager

# Chạy script cài đặt (sẽ tự động cài dependencies và setup)
chmod +x install.sh
./install.sh
```

Script cài đặt sẽ:
- ✅ Kiểm tra hệ thống Arch
- ✅ Cài đặt zsh nếu chưa có
- ✅ Cài đặt các gói cần thiết (pacman-contrib, git, base-devel, reflector)
- ✅ Hỏi cài đặt YAY (AUR helper) nếu muốn
- ✅ Cho phép chọn cài system-wide hoặc alias

### Phương pháp 2: Thủ công

```bash
# Clone repository
git clone https://github.com/mttk2004/arch-zsh-manager.git
cd arch-zsh-manager

# Cấp quyền thực thi
chmod +x pkgman.zsh

# Chạy trực tiếp
./pkgman.zsh

# HOẶC cài vào hệ thống
sudo cp pkgman.zsh /usr/local/bin/pkgman

# HOẶC thêm alias vào ~/.zshrc
echo "alias pkgman='$PWD/pkgman.zsh'" >> ~/.zshrc
source ~/.zshrc
```

### Cài đặt dependencies (thủ công)

```bash
sudo pacman -S pacman-contrib reflector base-devel git
```

## 📖 Hướng dẫn sử dụng

### Chạy script

```bash
# Nếu đã cài vào hệ thống hoặc tạo alias
pkgman

# Hoặc chạy trực tiếp
./pkgman.zsh
```

> **Lưu ý**: Không cần chạy với `sudo`. Script sẽ tự yêu cầu quyền root khi cần thiết.

### Menu chính

```
╔═══════════════════════════════════════════════════════════════╗
║          ARCH PACKAGE MANAGER - Quản lý gói tập trung         ║
╚═══════════════════════════════════════════════════════════════╝

═══ HỆ THỐNG GÓI ═══
1.  Cài đặt gói
2.  Xóa gói
3.  Cập nhật hệ thống
4.  Tìm kiếm gói
5.  Xem thông tin gói

═══ BẢO TRÌ HỆ THỐNG ═══
6.  Dọn dẹp cache
7.  Xóa gói orphan (không cần thiết)
8.  Xem danh sách gói đã cài
9.  Kiểm tra gói bị hỏng

═══ NÂNG CAO ═══
10. Downgrade gói
11. Xem log gói
12. Mirror management

0.  Thoát
```

### Ví dụ sử dụng

#### Cài đặt gói
1. Chọn `1` - Cài đặt gói
2. Chọn nguồn: pacman (1), AUR (2), hoặc Flatpak (3)
3. Nhập tên gói
4. Xác nhận cài đặt

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

## 🎨 Tính năng nổi bật

### 🔄 Tự động phát hiện AUR Helper
Script tự động phát hiện và sử dụng `yay` hoặc `paru` nếu có cài đặt.

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
ls -l pkgman.zsh

# Cấp quyền nếu cần
chmod +x pkgman.zsh
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
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

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

## ⚠️ Lưu ý quan trọng

- ✅ Script này là công cụ hỗ trợ, giúp bạn quản lý gói dễ dàng hơn
- ✅ Luôn đọc output trước khi xác nhận các thao tác quan trọng
- ✅ Với gói AUR, nên kiểm tra PKGBUILD trước khi cài
- ✅ Khuyến khích tìm hiểu pacman/yay để hiểu rõ hơn về hệ thống

**Enjoy your Arch experience! 🚀 BTW, I use Arch!**
