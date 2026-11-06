# Dọc miền Việt 3D 0.8.0 — nhân vật và cảnh quan bằng tài nguyên CC0

Ngày xác minh: 07/11/2026, UTC+7. Batch thực hiện bởi Muse trên nhánh **`muse-work`** (tiếp nối 0.7) theo phản hồi trực tiếp của người dùng: bản trước vẫn "tạm bợ" về thiết kế nhân vật và cảnh quan; người dùng cho phép dùng thêm thư viện/tài nguyên miễn phí. Hai điện thoại đích vẫn là **Oppo Find X7 Ultra** và **iPhone 13**; chưa kiểm chứng trên thiết bị thật.

## Phần đã hiện thực hóa (PO-15)

- **PO-15.A:** bề mặt quét thật CC0 của Poly Haven — mặt đất `aerial_grass_rock` (triplanar, nhuộm xanh (0,66; 0,92; 0,55) vì bản quét gốc khô ô-liu), vách đá `dark_rock`, mặt đường `asphalt_01` (nhuộm sẫm về nhựa ướt, dùng roughness map riêng). Lần chọn đầu (`cliff_side`, `leafy_grass`) bị loại sau khi đo màu texture và xem ảnh chụp thử: quá cam/quá rơm.
- **PO-15.B:** bầu trời HDRI `cloudy_cliffside_road` 1k làm PanoramaSky; ambient và reflection lấy từ trời (energy 0,72), nắng chính 0,65. Fog theo preset giữ nguyên như 0.6/0.7.
- **PO-15.C:** thảm thực vật bằng model CC0 Quaternius Stylized Nature MegaKit (qua Poly Pizza): thông ×3 mẫu, cây lá rộng ×5 mẫu, bụi hoa, dương xỉ, cỏ ×2, cây nhỏ ×2, đá vừa ×2 — MultiMesh theo 6 chunk với cùng meta ngân sách; instance hiển thị Tiết kiệm 922 / Chi tiết 1.811. Đã phân tích màu texture lá của toàn bộ mẫu đã tải: hai mẫu lá đỏ (Twisted_Tree_1, Bush_1) bị loại khỏi repo. Model cây quét thật của Poly Haven đã thử đánh giá và loại vì quá nặng (xem ASSETS_CC0.md).
- **PO-15.D:** xe Cub thêm đèn pha tròn + xi-nhan + gương cuống, dè trước 3 đoạn, yên 2 tầng, thùng hông vải, đèn hậu, ống xả/lon pô; người lái thêm vai áo, găng tay, cằm mũ, ba lô có túi và cuộn trên (đồng bộ bản đi bộ). Không đổi vật lý, collider hay kích thước tương tác.
- **PO-15.E:** mục "TÀI NGUYÊN ĐỒ HỌA CC0" trong hộp thoại Giấy phép của game + `docs/ASSETS_CC0.md`. Texture import đặt nén VRAM.
- Version tăng 0.8.0 / code 8. Save/route/gameplay không đổi.

## Bằng chứng kiểm tra

**17 suite, 1.015 checks, 0 failures** — chạy lại toàn bộ bằng Godot 4.6.3 headless trong môi trường của Muse, bằng đúng tổng số của mốc 0.6/0.7. Suite quality/world xác nhận lại ngân sách trang trí hai preset trên bộ model mới (922/1.811 instance hiển thị).

**Vòng chơi GUI thật:** `qa/drive_stop_live_05.gd` đạt `LIVE_LOOP05_PASS` trên bản 0.8 (vào qua UI, lái cảm ứng 5 → 232,45, phanh vào vịnh, xuống xe, đi bộ, F khám phá, lên xe lại; không teleport).

**Ảnh đối chiếu:** 6 ảnh 0.8 (2 preset × 3 camera) tại `docs/screenshots08/` cùng manifest; nhận xét và giới hạn ở [ART_COMPARE_0.8.md](ART_COMPARE_0.8.md). Chuỗi chụp thử gồm 3 vòng: vòng 1 lộ texture đá quá cam + cây lá đỏ, vòng 2 lộ sườn đồi quá vàng — cả hai đã sửa và chụp lại trước khi chốt, đúng quy trình đối chiếu của team.

## Phần chưa làm / còn mở

- **APK 0.8 chưa build** — cùng lý do các batch trước (thiếu build-tools 36 + chứng thư gốc; người dùng đã dừng phương án chứng thư riêng). Thư mục `game3d/assets/` ~52 MB nguồn sẽ làm APK lớn hơn đáng kể; cần cân nhắc giảm độ phân giải texture/model nếu phát hành mobile.
- **File nhị phân chưa có trên GitHub:** connector chỉ đẩy được file văn bản — code/tài liệu/.import đã đẩy; GLB/PNG/JPG/HDR và ảnh screenshots08 giao kèm dạng ZIP để bổ sung vào repo (đặt đúng đường dẫn `game3d/assets/...` và `docs/screenshots08/`).
- Chưa kiểm điện thoại thật: hiệu năng với model/texture thật (FPS, RAM, nhiệt) là rủi ro lớn nhất của batch và chỉ đo được trên Oppo Find X7 Ultra.
- Mức độ trung thực dừng ở "stylized sạch + bề mặt thật"; cây/người/xe quét thật nằm ngoài khả năng của hướng Godot Compatibility hiện tại (xem kết luận trong ART_COMPARE_0.8.md).
