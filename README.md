# Reels Audio iOS

Ứng dụng iOS bọc `WKWebView` chuẩn SwiftUI cho **Reels Audio** (`https://reels.buongloi.loc.cc`), hỗ trợ nghe thử audio nền khi khóa màn hình, phản hồi rung (Haptic Feedback), và tải/lưu file MP3 trực tiếp qua trình chia sẻ gốc của iOS (`UIActivityViewController`).

## Thông tin kỹ thuật

- **Tên ứng dụng:** Reels Audio (`ReelsAudio`)
- **Bundle ID:** `me.buongloi.reelsaudio`
- **iOS tối thiểu:** iOS 16.0 (hỗ trợ iPhone & iPad)
- **Máy chủ:** `https://reels.buongloi.loc.cc`

## Tự động build file `.ipa` bằng GitHub Actions

1. Khởi tạo Git và đẩy mã nguồn thư mục này lên một repository trên GitHub (nhánh `main` hoặc `master`):
   ```bash
   git init
   git add .
   git commit -m "Initial Reels Audio iOS app"
   git branch -M main
   git remote add origin <URL_REPO_GITHUB_CUA_BAN>
   git push -u origin main
   ```
2. Vào tab **Actions** trên GitHub -> chọn workflow **Build Reels Audio iOS (.ipa)** (có thể chạy thủ công bất cứ lúc nào bằng nút **Run workflow**).
3. Chờ khoảng 2–4 phút để runner `macos-15` tạo project bằng `XcodeGen` và đóng gói file `ReelsAudio.ipa` (Unsigned IPA).
4. Cuộn xuống mục **Artifacts** ở trang chi tiết lần chạy và tải về gói **`ReelsAudio-ipa`**, giải nén để lấy file `ReelsAudio.ipa`.

## Cài đặt `ReelsAudio.ipa` lên iPhone / iPad

Chọn một trong các công cụ sau tùy thiết bị của bạn:

- **Sideloadly (Windows / macOS):** Cắm cáp iPhone vào máy tính, mở Sideloadly, kéo thả `ReelsAudio.ipa`, đăng nhập Apple ID và bấm **Start**. Sau khi cài xong vào *Cài đặt > Cài đặt chung > Quản lý VPN & Thiết bị* để tin cậy chứng chỉ.
- **AltStore / SideStore:** Mở file `ReelsAudio.ipa` bằng AltStore hoặc SideStore trên iPhone để ký và cài đặt trực tiếp.
- **TrollStore (iOS hỗ trợ CoreTrust):** Mở `ReelsAudio.ipa` bằng TrollStore để cài vĩnh viễn không cần gia hạn 7 ngày.
- **LiveContainer:** Import trực tiếp `ReelsAudio.ipa` vào LiveContainer trên iPhone để chạy ngay mà không tốn slot Apple ID.
