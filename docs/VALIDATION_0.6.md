# Dọc miền Việt 3D 0.6.0 — bản mượt hơn

Ngày xác minh: 12/11/2026. Phạm vi thay đổi: cảm giác chơi và hiệu năng trên điện thoại. Nội dung, tuyến đèo, 47 địa danh và định dạng lưu **không đổi** so với 0.5.

## Đã thay đổi

**(A) Chuyển động mượt giữa các tick**

- Bật `physics/common/physics_interpolation` cho cảnh 3D. Trước đây, khi máy render không đúng 60 FPS, xe và camera giật theo từng tick physics; nay vị trí hiển thị được nội suy giữa hai tick.
- Teleport (`reset_to_distance`, xuống/lên xe, về điểm dừng, hồi sinh khi rơi) gọi `reset_physics_interpolation()` để không bị kéo mượt qua mặt đường.
- Trên thiết bị di động game giới hạn `Engine.max_fps = 60` và bật giữ màn hình sáng, tránh GPU chạy hết công suất rồi tự throttle vì nhiệt.

**(B) Giảm chi phí đồ họa**

- Shadow map hướng sáng 2048 → 1024; tắt MSAA; lọc anisotropic về 0.
- Chế độ Tiết kiệm tắt đổ bóng của toàn bộ cây/bụi/đá trang trí. Chế độ Chi tiết chỉ cho ba nhóm gần nhất đổ bóng.
- **Hai nấc tự giảm chi tiết:** đo FPS trung bình theo cửa sổ 2 giây; dưới 48 FPS thì giảm số instance cây/bụi (×0,72 rồi ×0,5), thu khoảng nhìn và hạ `camera.far`. Có 2,5 giây ân hạn khi vào cảnh và 4 giây giữa hai nấc để không dao động. Chỉ số trang trí và khoảng nhìn thay đổi; collider, traffic, POI, checkpoint, vị trí xe và save giữ nguyên.

**(C) Điều khiển cảm ứng**

- Vùng chết joystick 14%: rung ngón tay không còn làm xe lạng; biên độ vẫn đạt đúng 1.0 khi gạt hết.
- Bán kính joystick và GA/PHANH co giãn theo cạnh ngắn của màn hình (54–78 px và 44–56 px), vùng bấm cộng thêm 12 px; khoảng cách hai bàn đạp cũng theo tỉ lệ màn hình.
- Lái ở tốc độ thấp nhạy hơn (hệ số 0,55 thay vì ~0) để vào vịnh dừng và quay đầu dễ hơn; tốc độ cao vẫn lái nhẹ như cũ.
- Đa chạm vẫn giữ nguyên: ga, phanh, joystick và camera thuộc bốn ngón độc lập.

**(D) HUD**

- Chữ chỉ được gán lại khi giá trị đổi (tốc độ, mét, mục tiêu, nút xe). Trước đây mỗi khung hình đều tạo chuỗi mới và khiến Label dựng lại layout.

## Bằng chứng kiểm tra

- **1033 assertion đạt, 0 lỗi qua 19 suite** (`scripts/run-3d-tests.sh`), gồm suite mới `tests/test_smoothness.gd` 18 kiểm tra: cửa sổ FPS 60/30, bỏ qua khung hình pause, deadzone và biên độ joystick, cờ nội suy physics, hai nấc giảm chi tiết, idempotent và clamp, phục hồi ngân sách trang trí.
- 18 suite cũ vẫn đạt nguyên trạng: kinh tế 1398 / chi tiết 2724 instance trang trí, đúng như 0.5.
- APK: `artifacts/doc-mien-viet-3d-0.6.0.apk`, **51.702.031 byte**, SHA256 `9292b2258ffcf828b0357fa81c42264a52fc62439d068fe5ab92c5c24d6bdc03`.
  - `apksigner verify` đạt (v2 + v3), `zipalign -c -P 16 4` đạt, release không debuggable, không quyền INTERNET.
  - Application ID `com.travelvietnamese.docmienviet3d`, versionName 0.6.0 / versionCode 6, minSdk 24, target 36, arm64-v8a + armeabi-v7a.
  - `scripts/verify-3d-apk.py` đạt: tài nguyên offline, 34 tỉnh/thành + 13 vùng đảo, giấy phép MIT.

## Phần chưa kiểm chứng

- **Chưa chạy trên điện thoại thật.** Không có số đo FPS, frame time, RAM, nhiệt hay pin; các ngưỡng 48/57 FPS là lựa chọn thiết kế, không phải kết quả benchmark.
- Chưa thử cảm ứng thật nhiều ngón; suite kiểm tra bằng sự kiện mô phỏng.
- APK 0.6 được ký bằng khóa thử nghiệm **mới** sinh trong môi trường build này (khóa 0.5 nằm ngoài repository và không có ở đây). Cài đè lên 0.5 sẽ báo sai chữ ký: cần gỡ bản 0.5 trước, và làm vậy sẽ mất tiến trình lưu trên máy. Nếu cần nâng cấp giữ dữ liệu, phải ký bằng đúng khóa cũ.
- Cùng mã Godot nên có thể export iOS, nhưng chưa có IPA ký.
