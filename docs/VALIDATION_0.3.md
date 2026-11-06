# Dọc miền Việt 3D 0.3.0 — vòng cải tiến Product Owner

Ngày xác minh: 06/11/2026. PO đã lập [nghiên cứu định tính có nguồn](market/RESEARCH.md), [backlog có ưu tiên và AC](PRODUCT_BACKLOG.md) và [vai trò/quy trình team](TEAM.md). Đây là benchmark sản phẩm lân cận, chưa xác nhận nhu cầu thị trường bằng khảo sát hoặc dữ liệu người chơi.

## Đã hiện thực hóa

- **PO-01:** hướng dẫn ba bước bằng hành động thật: đi bộ 2 m trong cảnh, xoay camera ít nhất 0,25 rad, rồi tương tác POI khi đủ gần. Bỏ qua khác hoàn thành; có xem lại. Lưu ngay khi đổi bước/trạng thái. Không tính teleport hoặc rơi thành học điều khiển.
- **PO-02:** chỉ tới POI chưa ghé gần nhất theo khoảng cách XZ, kèm hướng tương đối camera và khoảng cách trong cảnh minh họa. Sau khám phá chuyển mục tiêu; hết POI thì hiện hoàn thành cục bộ N/N. Không tự dịch chuyển hoặc tự đóng dấu.
- **PO-03:** bật/tắt bóng đổ và ba mức nhạy camera 0,6×/1×/1,4×. Áp dụng ngay, giữ qua đổi khu và khởi động lại. Save version 1 cũ được bổ sung mặc định, giữ nguyên vị trí và dấu.

## Kết quả kiểm chứng

Sáu suite mới/chạy lại: **257 assertion đạt, 0 lỗi**, gồm rules 36, player/tutorial 9, integration 38, controls 21, save/transitions 135, licenses 18. Tổng gồm 83 điều kiện mới và 174 hồi quy; 502 điều kiện world của lần 0.2 không được cộng vào kết quả chạy mới. Chi tiết/lệnh/log được ghi trong [TEST_PLAN_3D.md](TEST_PLAN_3D.md).

Visual smoke bằng Xorg dummy và Mesa llvmpipe, 1280×720: đi bộ, nhìn và tương tác thật hoàn thành tutorial; HUD đổi mục tiêu; settings áp dụng và giữ bóng qua cảnh đảo; menu hoạt động. Root phát hiện settings bị kéo cao quá màn hình do nhãn tự xuống dòng ở lượt đầu, đã sửa và kiểm tra lại: toàn hộp thoại cùng nút Trở lại nằm trong viewport. Ảnh từ lần render sau sửa ở `screenshots03/`.

PO đã nghiệm thu 17 AC trong phạm vi prototype logic/desktop. Chưa nghiệm thu cảm ứng trên Android/iOS hoặc hiệu quả với người chơi thật.

## APK và khả năng cập nhật

- `artifacts/doc-mien-viet-3d-0.3.0.apk`: **51.642.944 byte**, khoảng 51,6 MB.
- SHA256: `99649f3cb829098d8a7cbde8f06604a2320bed98ca3c0ed9df4197a0241eca99`.
- App ID giữ `com.travelvietnamese.docmienviet3d`; versionCode tăng 2 → 3, versionName 0.3.0.
- APK verify đạt: ZIP nguyên vẹn, chữ ký v2/v3, alignment 16 KiB, release không debuggable, tài nguyên offline/giấy phép/dataset nhúng, không quyền INTERNET; ARM64 và ARM 32-bit, Android API 24 trở lên.
- Đã so chứng thư ký thực của APK 0.2 và 0.3: trùng khớp, cùng app ID và versionCode mới cao hơn. Đây là bằng chứng tương thích metadata cập nhật; chưa thử cài đè và giữ dữ liệu thực trên điện thoại.

```sh
./scripts/build-3d-android-apk.sh
python scripts/verify-3d-apk.py artifacts/doc-mien-viet-3d-0.3.0.apk \
  --previous-apk artifacts/doc-mien-viet-3d-0.2.0.apk
sha256sum -c artifacts/doc-mien-viet-3d-0.3.0.apk.sha256
```

## Giới hạn và ưu tiên tiếp theo

Không thêm địa danh hay đảo mới trong vòng này. Phạm vi vẫn 34 tỉnh/thành và 13 vùng đảo; nhiều cảnh sinh thủ tục minh họa, chưa số hóa thực địa và chưa đủ mọi đảo có tên của Việt Nam. [PO-04 và PO-05](PRODUCT_BACKLOG.md) là ưu tiên kế tiếp: danh mục đảo có nguồn/geometry/coverage và các cảnh/landmark riêng cho đất liền, đảo.

Chưa cài/chạy APK này trên điện thoại, chưa đo FPS/RAM/nhiệt, chưa xác minh mở lạnh ở chế độ máy bay hoặc iOS. Việc tắt bóng không phải bằng chứng tăng FPS. Mục tiêu playtest của PO chưa được đo; không có số liệu retention hoặc kết luận product–market fit.
