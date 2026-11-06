# Dọc miền Việt 3D 0.6.0 — không khí đèo và đạo cụ tham chiếu

Ngày xác minh: 07/11/2026, UTC+7. Batch thực hiện bởi Muse trên nhánh **`muse-work`** (rẽ từ `codex-work` tại `39885ab`) theo bộ skill team trong `.agents/skills/` và yêu cầu trực tiếp của người dùng kèm ảnh design tham chiếu. Hai điện thoại người dùng nêu là **Oppo Find X7 Ultra** và **iPhone 13**; chưa có truy cập thiết bị, phiên bản OS hoặc phép đo trên hai máy này.

## Phần đã hiện thực hóa (PO-13)

- **PO-13.A:** trời u ám phân lớp (đỉnh trời xanh xám sâu, chân trời sáng sương), nắng dịu 0,9 và ambient mát; fog theo preset tăng có kiểm soát (Chi tiết 0,0021 / Tiết kiệm 0,0028). Ba lớp núi xa ở **cả hai phía** tuyến, đỉnh răng cưa, tông xanh lam–lục phân lớp; dải sương alpha nhẹ trên thung lũng và giữa các lớp núi.
- **PO-13.B:** 16 vũng nước tối độ nhám thấp (seed 7707, không collision) trên asphalt; lan can có đoạn gỉ sét xen kẽ xác định; mỗi vịnh dừng thêm 4 blốc bê tông mép ngoài.
- **PO-13.C:** 3 cột mốc trắng–đỏ "ĐÀ LẠT / KHÁNH LÊ" tại station 60/245/565; 2 thác bậc thang trên vách đá (station 372/470) kèm vệt đá ướt và bọt chân thác. Toàn bộ procedural, không dùng ảnh tham chiếu làm texture.
- **PO-13.D:** xe đổi silhouette Cub — chắn chân trước trắng bạc phếch, baga sau + cuộn hành lý có dây chằng; người lái thêm ba lô, mũ bảo hiểm xám đậm đồng nhất bản đi bộ. Không đổi vật lý/collider/tốc độ.
- **PO-13.E:** tán cây/bụi đậm màu hơn; bụi 215/cụm (trước 180); thêm dải dương xỉ sát mép đường (tránh mặt vịnh dừng); cây phía thung lũng vươn tới lateral 100. Instance trang trí hiển thị: Tiết kiệm 1.682 / Chi tiết 3.323.
- Version tăng 0.6.0 / code 6 (`project.godot`, `export_presets.cfg`, nhãn trong game). Save format không đổi; route/checkpoint/traffic/POI không đổi.

## Bằng chứng kiểm tra

**17 suite, 1.015 checks, 0 failures** — chạy lại toàn bộ bằng Godot 4.6.3 headless trong môi trường của Muse (cách chạy theo TEST_PLAN_3D.md; tổng số khác snapshot 466/13 suite của 0.5 vì phạm vi suite nạp được ở môi trường này rộng hơn, không cộng dồn kết quả lịch sử):

| Suite | Checks | Suite | Checks |
| --- | --- | --- | --- |
| batch03/integration | 38 | pass/touch | 11 |
| batch03/rules | 36 | pass/world | 49 |
| controls/player | 21 | player/tutorial | 9 |
| licenses | 18 | quality/goals integration | 38 |
| pass/integration | 41 | quality/preferences | 24 |
| pass/physics | 14 | quality/world | 14 |
| pass/route | 17 | registry/worlds | 502 |
| pass/save | 28 | route/objectives | 20 |
| save/transitions | 135 | | |

Suite quality/world xác nhận preset chỉ đổi phần trang trí: tổng instance bằng nhau giữa hai preset, Chi tiết hiển thị nhiều hơn Tiết kiệm, collision/POI/traffic không đổi.

**Vòng chơi GUI thật:** `qa/drive_stop_live_05.gd` trên Xvfb/Mesa đạt `LIVE_LOOP05_PASS`: vào demo qua nút UI, lái bằng input touch mô phỏng từ station 5 tới 232,45, phanh trong vịnh dừng đầu, xuống xe, đi bộ, bấm F khám phá, quay lại lên xe; không dùng reset/teleport. Đây là scripted input trên desktop, không phải playtest người dùng hoặc đa chạm điện thoại.

**Ảnh đối chiếu:** 9 ảnh (baseline 0.5 + 0.6 hai preset) tại 3 camera cố định, UI ẩn, bóng Bật — phương pháp, nhận xét Designer/root và phần còn xa tham chiếu ở [ART_COMPARE_0.6.md](ART_COMPARE_0.6.md), file trong `docs/screenshots06/`.

## Phần chưa làm / còn mở

- **APK 0.6 chưa build:** môi trường của Muse thiếu Android build-tools 36.0.0 và chứng thư thử nghiệm gốc của team; tự ký bằng chứng thư mới sẽ phá tính liên tục cài đè/giữ save đã kiểm chứng ở 0.4/0.5. Cửa artifact (PO-10.J) giữ mở — cần build trên môi trường chuẩn của team hoặc bàn giao chứng thư/build-tools phù hợp.
- Chưa kiểm điện thoại thật: cảm ứng đa điểm, FPS/frame-time, RAM/nhiệt/pin, cài đè giữ save và iOS vẫn là cửa riêng PO-08.
- Hình ảnh vẫn là prototype stylized; chưa đạt bán hiện thực/photoreal của ảnh tham chiếu (xem mục còn mở trong ART_COMPARE_0.6.md).

## Cách thử

Mở source nhánh `muse-work` bằng Godot 4.6.3, chạy scene chính → **Chơi đèo mẫu**. Lái W/S/A/D hoặc GA/PHANH/joystick; ngắm cột mốc và thác ở vách trái quanh station 372; dừng ở vịnh để xem blốc bê tông và cột mốc station 245 ở cự ly gần. Trong **Đổi địa điểm → Cài đặt**, đổi Tiết kiệm/Chi tiết để thấy khác biệt mật độ trang trí và sương.
