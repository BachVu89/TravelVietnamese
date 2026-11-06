# Dọc miền Việt 3D 0.7.0 — HUD nhập vai theo khung hình tham chiếu

Ngày xác minh: 07/11/2026, UTC+7. Batch thực hiện bởi Muse trên nhánh **`muse-work`** (tiếp nối 0.6 tại `e0f45585`) theo yêu cầu trực tiếp của người dùng: tiếp tục đưa **giao diện** về gần khung hình design ban đầu. Hai điện thoại đích vẫn là **Oppo Find X7 Ultra** và **iPhone 13**; chưa có kiểm chứng trên thiết bị thật.

## Phần đã hiện thực hóa (PO-14)

- **PO-14.A:** thanh đầu trang từ 98 xuống ~56 chiều cao, nền xuyên sáng alpha 0,55; tiêu đề 19 pt, phụ đề 11 pt (bản 0.7); bốn nút cùng hàng cao tối thiểu 44, chữ 14 pt; theme nút chung chuyển nền alpha 0,72 (hover 0,88) áp dụng thống nhất toàn app.
- **PO-14.B:** panel dẫn đường bỏ chiều rộng cố định, thành pill nổi alpha 0,55 ở góc trái dưới thanh; cỡ chữ giảm (dẫn đường 16, mục tiêu 13, ghi chú 11, gợi ý lái 12). Logic và nội dung cập nhật không đổi.
- **PO-14.C:** đồng hồ tốc độ analog tự vẽ (Control `_draw`): thang 0–70 km/h, vạch chia mỗi 10, nhãn 0/20/40/60, kim cam, số km/h ở giữa lấy cùng `road_hud.speed_kmh` và cùng cách làm tròn với nhãn dẫn đường; chỉ hiện khi đang lái, đặt trên cụm GA/PHANH để không tranh vùng với nút Khám phá (chỉ hiện khi đi bộ).
- **PO-14.D:** nút "Ngắm cảnh"/"Hiện giao diện": ẩn toàn bộ panel/nút/đồng hồ, giữ joystick và GA/PHANH trong suốt để vẫn điều khiển được; vùng nút được đăng ký chặn chạm mỗi khung hình.
- **PO-14.E:** footer nền alpha 0,55, thấp hơn, chữ gợi ý 15 pt; vẫn ẩn khi đang lái.
- Version tăng 0.7.0 / code 7 (`project.godot`, `export_presets.cfg`, nhãn trong game). Save format, route, checkpoint, traffic, POI không đổi; scene 3D giữ nguyên như 0.6.

## Bằng chứng kiểm tra

**17 suite, 1.015 checks, 0 failures** — chạy lại toàn bộ bằng Godot 4.6.3 headless trong môi trường của Muse, bằng đúng tổng số của mốc 0.6 (không suite nào mất checks). Các suite nhạy với UI đều đạt: pass/integration 41 (gồm kiểm tra hình chữ nhật nút Lên xe/Khám phá không chồng nhau ở 1280×720), batch03/integration 38 (gồm nội dung nhãn điều hướng), quality/goals integration 38, pass/touch 11.

**Vòng chơi GUI thật:** `qa/drive_stop_live_05.gd` chạy lại trên bản 0.7 đạt `LIVE_LOOP05_PASS`: vào demo qua nút UI, lái cảm ứng thật 5 → 232,45, phanh trong vịnh dừng, xuống xe, đi bộ, bấm F khám phá, quay lại lên xe; không reset/teleport. Đây là scripted input trên desktop, không phải playtest người dùng.

**Ảnh UI:** `qa/ui_capture_07.gd` chụp trực tiếp HUD đang chạy (không ẩn UI như bản chụp mỹ thuật) tại `docs/screenshots07/`:

| Ảnh | Trạng thái |
| --- | --- |
| `travel07-ui-idle.png` | Vừa vào đèo, ngồi trên xe đứng yên: thanh mỏng, pill dẫn đường, đồng hồ ở 0 |
| `travel07-ui-ride.png` | Đang lái ~45 km/h bằng bàn đạp GA thật: kim và số trên đồng hồ khớp nhãn dẫn đường |
| `travel07-ui-clean.png` | Chế độ Ngắm cảnh: chỉ còn nút Hiện giao diện, joystick và GA/PHANH |
| `travel07-ui-walk.png` | Đi bộ tại vịnh dừng Ban công mây: footer gọn, nút Lên xe và Khám phá không chồng nhau |

Khung hình đi bộ dùng đặt xe kiểu QA tại vịnh dừng (cùng quy ước các bản chụp đối chiếu mỹ thuật); việc lái thật tới vịnh dừng do drive QA bao phủ, không suy diễn từ ảnh tĩnh.

## Phần chưa làm / còn mở

- **APK 0.7 chưa build** — cùng lý do như 0.6: môi trường của Muse thiếu Android build-tools 36.0.0 và chứng thư thử nghiệm gốc; người dùng đã dừng phương án build chứng thư riêng trong phiên này.
- Chưa kiểm điện thoại thật: cảm ứng đa điểm, độ đọc của HUD xuyên sáng dưới nắng và trên hai máy đích vẫn là cửa riêng.
- HUD vẫn dùng chữ và nút phẳng; khung hình tham chiếu gần như không có chữ — mức tối giản tuyệt đối đó đánh đổi khả năng dẫn đường cho người chơi mới, nên batch dừng ở mức pill + chế độ Ngắm cảnh thay vì xóa hẳn lớp dẫn đường.
