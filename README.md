# Dọc miền Việt 3D — bản thử nghiệm

## Mới nhất: 0.6.0 — bản mượt hơn cho điện thoại

[⬇ Tải APK 0.6.0](./doc-mien-viet-3d-0.6.0.apk) · [Source ZIP 0.6](./doc-mien-viet-3d-source-0.6.0.zip)

[Source: codex-work](https://github.com/BachVu89/TravelVietnamese/tree/codex-work) · [Báo cáo BA](https://github.com/BachVu89/TravelVietnamese/blob/codex-work/docs/STATUS_REPORT.md)

**Cách vào:** mở game → Chơi đèo mẫu. Joystick lái, GA/PHANH; dừng tại vịnh để xuống xe, đi bộ khám phá và lên xe tiếp tục. HUD hướng dẫn lần lượt hai điểm dừng và đích. Đi lại từ đầu giữ dấu đã khám phá. Cài đặt có Tiết kiệm/Chi tiết và bóng đổ độc lập.

**0.6 tối ưu cảm giác chơi trên máy yếu** (không đổi nội dung, bản đồ hay tiến trình lưu):

- Nội suy physics 3D: chuyển động và camera mượt giữa các tick 60 Hz, kể cả khi máy render dưới 60 FPS.
- Giới hạn 60 FPS trên thiết bị di động, giữ màn hình sáng khi chơi, tắt khử răng cưa và lọc anisotropic.
- Bóng đổ giảm 2048 → 1024; chỉ ba nhóm cây gần nhất đổ bóng ở chế độ Chi tiết, chế độ Tiết kiệm tắt bóng trang trí.
- **Tự giảm chi tiết theo FPS đo được:** nếu trung bình dưới 48 FPS trong 2 giây, game bỏ bớt cây/bụi và giảm khoảng nhìn theo hai nấc. Chỉ ảnh hưởng đồ họa, không đổi va chạm, xe, điểm dừng hay save.
- Joystick có vùng chết 14% (hết trôi khi ngón tay rung), vùng chạm GA/PHANH và joystick tự co giãn theo kích thước màn hình; lái chậm nhạy hơn khi vào vịnh dừng.
- HUD chỉ cập nhật chữ khi giá trị thay đổi, giảm việc dựng lại layout mỗi khung hình.

Chơi offline; Android 7+, ARM64/ARM32/OpenGL ES3, APK khoảng 51,7 MB, versionCode 6. Chưa cài thử và chưa đo FPS/nhiệt trên điện thoại thật.

**Đồ họa vẫn là prototype cách điệu, chưa đạt ảnh tham chiếu.** Tuyến minh họa sinh thủ tục, không phải khảo sát Khánh Lê. 1033 kiểm tra/19 suite đạt trên desktop headless (gồm suite mới cho nhịp khung hình, deadzone và các nấc giảm chi tiết). APK đã kiểm chữ ký, alignment 16 KiB, tài nguyên offline và quyền.

[Kiểm chứng 0.6](docs/VALIDATION_0.6.md) · [Build Android](game3d/README.md) · [Phạm vi địa lý](docs/GEOGRAPHIC_SCOPE.md)

![Cảnh tham chiếu 0.5 (đồ họa 0.6 không đổi)](docs/screenshots05/live-start.png)

## Phạm vi Việt Nam

Danh mục có 34 tỉnh/thành + 13 vùng đảo. Cảnh chủ yếu minh họa, chưa đủ mọi đảo có tên hoặc địa hình thực. Catalog đảo có nguồn và khoảng thiếu là ưu tiên tiếp theo.

## Bản trước

[3D 0.5](./doc-mien-viet-3d-0.5.0.apk) · [Source 0.5](./doc-mien-viet-3d-source-0.5.0.zip) · [3D 0.4](./doc-mien-viet-3d-0.4.0.apk) · [Source 0.4](./doc-mien-viet-3d-source-0.4.0.zip) · [3D 0.3](./doc-mien-viet-3d-0.3.0.apk) · [Source 0.3](./doc-mien-viet-3d-source-0.3.0.zip) · [3D 0.2](./doc-mien-viet-3d-0.2.0.apk) · [Quiz 0.1](./doc-mien-viet-0.1.0.apk)

Nếu GitHub mở trang xem file, chọn **Download raw file** (↓). Checksum trong SHA256SUMS.
