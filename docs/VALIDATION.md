# Kết quả xác minh prototype 0.1

## Đã thực hiện trong môi trường cloud

- Node 24.22.1, npm 11.9.0; `npm ci --no-audit --no-fund` cài lại thành công từ lockfile.
- `npm run typecheck`: đạt.
- `npm test`: 15 test đạt, 0 lỗi, 0 bỏ qua. Bao gồm luật di chuyển, chi phí, mở khóa, chống thưởng lặp, đủ tiền hoàn thành tuyến và kiểm tra dữ liệu lưu.
- Expo kiểm tra bộ phiên bản phụ thuộc: tương thích SDK 54.
- Lệnh khởi động Metro hoạt động: `/status` trả `packager-status:running`, yêu cầu bundle Android trả HTTP 200 với khoảng 4,85 MB dữ liệu phát triển.
- `npm run export:web -- --max-workers 2`: đóng gói thành công.
- `npx expo export --platform android --platform ios --output-dir /tmp/travel-native-export --max-workers 2`: đóng gói thành công bundle Hermes cho cả hai nền tảng. Đây không phải APK/IPA hoặc kiểm thử runtime native.
- Chromium headless, viewport 390×844: chặng khóa không cho chơi, câu sai cho thử lại; hoàn thành đủ 8 điểm với trình duyệt offline sau khi trang đã tải; nhận đủ 8 dấu, 7 chuyến máy bay và còn 770 xu.
- Tải lại trang giữ tiến trình; hủy reset giữ nguyên tiến trình; xác nhận reset và tải lại giữ trạng thái mới.
- Không có lỗi JavaScript hoặc yêu cầu mạng ngoài server nội bộ trong phiên kiểm tra giao diện.
- Viewport 320×640 không phát hiện phần tử tràn ngang. Chưa mô phỏng cỡ chữ hệ thống lớn hoặc trình đọc màn hình native.

Ảnh từ bản web: [Hành trình](screenshots/hanh-trinh.png), [Hộ chiếu](screenshots/ho-chieu.png).

## Chưa thực hiện

Đã tạo và kiểm tra APK thử nghiệm như ghi nhận bên dưới. Chưa tạo AAB/IPA, chạy Android emulator/iOS Simulator hoặc thử trên điện thoại thật. Xcode chưa có; Android SDK/adb đã được cài. Cần hoàn tất ma trận native trong TEST_PLAN trước khi phát hành, đặc biệt tắt hẳn app và mở lại ở chế độ máy bay. Kiểm tra offline trên trang đã tải không chứng minh web có thể khởi động offline; bản web chưa có service worker.

Nội dung hiện là 8 câu hỏi mẫu, cốt truyện ngắn và quản lý ngân sách đơn giản. Phương tiện chưa mô phỏng thời gian hoặc tuyến vận tải thực tế. Chưa có bản đồ địa lý tương tác, nhân vật di chuyển tự do, âm thanh hoặc tài nguyên minh họa riêng.

## Lần build APK ngày 05/11/2026

Đã tạo project Android và cài Android SDK 36, build-tools, platform-tools/adb, NDK 27.1, CMake 3.22.1, Gradle 8.14.3 và Temurin JDK 17. Archive công cụ được kiểm tra checksum từ nguồn chính thức. Đã giải quyết hai lỗi toolchain (thiếu JDK 17 và Java 21 thiếu compiler) bằng JDK 17 đầy đủ, giữ trust store của môi trường và xác minh TLS.

Lần chạy trước bị chặn khi hai AAR `react-android:0.81.5` và `hermes-android:0.81.5` chuyển tới `repo.reactnative.dev`. Sau khi người dùng xuất bản môi trường, kiểm tra runtime xác nhận domain đã được cho phép và chính sách mạng đang enforced. Build tiếp tục từ cache, không áp dụng lại cấu hình hay xuất bản thêm.

`./scripts/build-android-apk.sh`: **BUILD SUCCESSFUL**, 4 phút 27 giây, 286 task (235 thực thi, 51 dùng lại). Đầu ra: `artifacts/doc-mien-viet-0.1.0.apk`, 57.678.452 byte (khoảng 57,7 MB), version 0.1.0/code 1, application ID `com.travelvietnamese.docmienviet`.

`python scripts/verify-apk.py artifacts/doc-mien-viet-0.1.0.apk`: **đạt**. ZIP nguyên vẹn, chữ ký APK v2 hợp lệ, manifest release không debuggable, có `assets/index.android.bundle` nhúng, đủ arm64-v8a/armeabi-v7a/x86/x86_64, minSdk 24 và targetSdk 36. Kiểm tra checksum bằng `sha256sum -c` đạt. Quyền trong APK gồm INTERNET và quyền nội bộ receiver của ứng dụng; không còn READ/WRITE_EXTERNAL_STORAGE, SYSTEM_ALERT_WINDOW hoặc VIBRATE.

SHA256: `875c367b1898c3947b556a25c6359f9767dacaea1bb8fea7ce454c1bd1601c91`.

APK ký debug dành cài thử nội bộ. Chưa cài hoặc khởi chạy APK trên thiết bị, nên chưa xác nhận runtime native hoặc offline trên điện thoại. Xem [ANDROID_BUILD.md](ANDROID_BUILD.md) để tái tạo build và [APK_INSTALL.md](APK_INSTALL.md) để cài thử.
