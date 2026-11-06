# Dọc miền Việt 3D 0.5.0 — hình ảnh và mục tiêu tuyến

Ngày xác minh: 07/11/2026, UTC+7. Hai điện thoại người dùng nêu là **Oppo Find X7 Ultra** và **iPhone 13**; chưa có truy cập thiết bị, phiên bản OS hoặc phép đo trên hai máy này.

## Phần đã hiện thực hóa

- **PO-11:** vật liệu mặt đường/đá/đất/lan can, ba kiểu cây với tán/cành khác nhau, tầng bụi, mỏm đá 3D và nền núi nhiều lớp. Profile Tiết kiệm (`economy`) mặc định và Chi tiết (`detail`) áp dụng ngay, giữ qua khởi động/chuyển cảnh. Chỉ thay trang trí, khoảng nhìn và fog; giữ riêng lựa chọn bóng đổ/camera, không reset xe, traffic, POI hoặc checkpoint.
- **PO-12:** nút vào demo trực tiếp; HUD hướng theo thứ tự điểm 1 → đỗ/xuống xe → khám phá → điểm 2 → cuối tuyến. Mục tiêu suy từ vị trí/mode và dấu thực, không tự ghi dấu. Đi lại từ đầu giữ dấu, cài đặt và tiến trình địa lý cũ. Vùng kết thúc là station 738–750 và chỉ hoàn thành khi có cả hai dấu.
- Save version 1 tiếp tục nhận dữ liệu 0.2/0.3/0.4; thiếu/sai trường quality dùng mặc định Tiết kiệm mà không xóa core progress.

## Bằng chứng kiểm tra

**466 assertion đạt, 0 lỗi qua 13 suite:** 96 kiểm tra mới (quality preferences 24, world invariance 14, objectives 20, main quality/goals 38) cùng 370 hồi quy liên quan. Chi tiết ở [TEST_PLAN_3D.md](TEST_PLAN_3D.md); không cộng các kết quả lịch sử chưa chạy lại thành kết quả mới.

QA đóng băng physics và so snapshot khi đổi quality: collider ID/shape/layer/transform, POI, traffic, xe, mode, input, checkpoint không đổi. Kiểm 2×2 profile/shadow, sensitivity độc lập, migration, restart và replay giữ hai dấu.

Chín ảnh đối chiếu 0.4/0.5 tại ba camera khớp origin/basis/FOV/resolution, UI ẩn và shadows ON; [phương pháp và ảnh](ART_COMPARE_0.5.md). Chỉ xác nhận thay đổi nhìn thấy ở các góc đã chụp, không xác nhận đạt photoreal.

Root chạy `qa/drive_stop_live_05.gd` trên GUI Xorg/Mesa: entry qua nút UI; ga/lái/phanh qua handler touch đưa xe từ station 5 tới 232,278 trong vịnh đầu; xuống xe, đi bộ tới POI, F khám phá, đóng hộp thoại, đi bộ về xe và lên lại; HUD chuyển mục tiêu sang điểm 2. Không dùng reset/teleport để chứng minh vòng này. `LIVE_LOOP05_PASS`, exit 0. Đây là scripted input trên desktop, không phải playtest của người dùng hoặc đa chạm điện thoại.

Harness ban đầu cần sửa tọa độ logical controls (headless Window báo 64×64) và chờ frame UI sau đóng modal; các lỗi harness được chẩn đoán và chạy lại, không được báo thành lỗi/khắc phục sản phẩm hoặc một lượt pass trước khi kiểm xong.

## APK 0.5

- File `artifacts/doc-mien-viet-3d-0.5.0.apk`, **51.697.778 byte**, khoảng 51,7 MB.
- SHA256: `282b805f5715e7320815f83535cfb5e58e406b489bf40da05c6140a4331d3772`.
- Application ID `com.travelvietnamese.docmienviet3d`, version name 0.5.0/code 5, Android API 24+, target API 36; ARM64/ARM 32-bit, OpenGL ES 3.
- ZIP integrity, chữ ký v2/v3, alignment 16 KiB, release không debuggable, không quyền INTERNET, bytecode mục tiêu/profile/vegetation và 47 bản ghi/giấy phép đều đạt.
- So với APK 0.4: cùng application ID/chứng thư, versionCode 4 → 5. Chưa cài đè và xác minh dữ liệu thực trên điện thoại.

```sh
./scripts/build-3d-android-apk.sh
python scripts/verify-3d-apk.py artifacts/doc-mien-viet-3d-0.5.0.apk \
  --previous-apk artifacts/doc-mien-viet-3d-0.4.0.apk
sha256sum -c artifacts/doc-mien-viet-3d-0.5.0.apk.sha256
```

## Cách thử và phần còn mở

Mở **Dọc miền Việt 3D → Chơi đèo mẫu**. Theo mục tiêu HUD, dùng GA/PHANH/joystick hoặc W/S/A/D; xuống xe ở vịnh, đi bộ tới cột mốc và bấm Khám phá/F. Trong **Đổi địa điểm → Cài đặt**, thử Tiết kiệm/Chi tiết và bật/tắt bóng riêng. **Đi lại từ đầu** chỉ bắt đầu lại vị trí tuyến, không xóa dấu đã thăm.

Chưa có benchmark, FPS/frame time/RAM/nhiệt/pin, safe area, cảm ứng thực, mở lạnh offline trên Oppo hoặc iPhone. Chưa có IPA ký; iOS cần quy trình macOS/Xcode/Apple signing. Không quảng cáo 30 FPS hoặc tối ưu riêng cho hai điện thoại khi chưa đo.

Phạm vi vẫn 34 tỉnh/thành và 13 vùng đảo; tuyến sinh thủ tục không phải địa hình Khánh Lê thực hoặc toàn bộ Việt Nam. Chưa đủ mọi đảo có tên. Mốc catalog đảo với nguồn/giấy phép/ID/coverage vẫn còn mở và phải được xử lý trước các tiện ích phụ đèo tiếp theo. Photo album chưa triển khai.
