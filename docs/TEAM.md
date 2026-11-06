# Team Dọc miền Việt

## Vai trò và trách nhiệm

| Thành viên/vai trò | Trách nhiệm chính | Đầu ra |
| --- | --- | --- |
| Chủ sản phẩm — người dùng | Xác định hướng, phạm vi và ràng buộc; phản hồi bản chơi thử | Khám phá Việt Nam 3D, điều khiển nhân vật, Android/iOS, offline, tỉnh/thành và đảo có thể vào cảnh |
| **Product Owner — `product_owner`** | Nghiên cứu sản phẩm/thị trường, phân biệt bằng chứng với giả thuyết, xác định vấn đề người chơi, ưu tiên backlog và quyết định nghiệm thu giá trị | `market/RESEARCH.md`, `PRODUCT_BACKLOG.md`, acceptance notes/decision log |
| BA — `ba` | Chuyển yêu cầu PO thành user story/quy tắc/AC rõ, quản lý phạm vi địa lý | `PRODUCT.md`, `GEOGRAPHIC_SCOPE.md` |
| SA — `sa` | Kiến trúc, dữ liệu/save tương thích, offline, hiệu năng và rủi ro triển khai | `ARCHITECTURE.md`, technical review |
| Designer — `designer` | Luồng chơi, điều khiển, giao diện, trợ năng và định hướng mỹ thuật | `DESIGN.md`, `ART_DIRECTION.md`, UX review |
| Developer — `dev` | Hiện thực yêu cầu trong Godot, sửa lỗi, chuẩn bị build tái tạo được | `game3d/`, build scripts, APK/project xuất phù hợp |
| Tester — `tester` | Test dựa trên AC, hồi quy và phân biệt logic/render/device test | `game3d/tests/`, `TEST_PLAN_3D.md`, bằng chứng lỗi/đạt |
| Điều phối — root | Điều phối giao việc, tích hợp, kiểm tra trực tiếp và giao artifact trong phạm vi được phép | Bản có thể review, kết quả xác minh và giới hạn thực tế |

PO là thành viên chức năng trong team, không phải người dùng thật được phỏng vấn hoặc một công ty nghiên cứu độc lập. Việc có vai trò PO không biến benchmark nguồn mở thành nghiên cứu thị trường đã đại diện người mua.

## Cách team thực hiện yêu cầu mới

1. PO đọc phản hồi và quan sát bản hiện tại; ghi nguồn, vấn đề và giả thuyết, không bắt đầu từ danh sách tính năng tùy ý.
2. PO chọn batch nhỏ, cân bằng cải thiện vòng chơi với nội dung Việt Nam và dữ liệu đảo còn thiếu; BA/Designer/SA làm rõ AC, UX và chi phí/rủi ro.
3. Root giao triển khai; Developer làm việc trong phạm vi đã chốt, Tester kiểm các AC có thể sai trong implementation. Các thao tác viết chung file được phối hợp để tránh ghi đè.
4. QA báo bằng chứng, root kiểm bản render/artifact phù hợp. PO đối chiếu trải nghiệm và AC rồi ghi accepted/needs revision; test pass không tự xác nhận nhu cầu thị trường.
5. Báo cáo rõ phần hoàn thành, phần chưa kiểm chứng trên thiết bị, gap địa lý/nội dung và kết quả nghiên cứu còn thiếu. Quyền ký/phát hành/dịch vụ ngoài vẫn theo phạm vi người dùng và công cụ được phép.

## Quyết định iteration 0.3

- PO-01: học thao tác bằng ba hành động thực, có bỏ qua/xem lại.
- PO-02: có mục tiêu POI chưa thăm, khoảng cách/hướng trong scene và tiến trình cục bộ rõ.
- PO-03: điều chỉnh bóng và ba mức độ nhạy camera, lưu trên máy.

Root đã chấp thuận batch này để triển khai. Tài liệu đầu vào, AC và các mục chiến lược tiếp theo nằm trong [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md). Không thêm đăng nhập, backend, quảng cáo hoặc bắt buộc Internet vào vòng chơi offline.


## Decision log — 06/11/2026

- PO đã đối chiếu 17 AC với implementation; root xác nhận desktop visual smoke cho thao tác, mục tiêu kế tiếp và settings. Tester báo 257 kiểm tra PASS qua sáu suite (83 mới + 174 hồi quy); PO accepted cho 17 AC trong phạm vi prototype logic/headless + desktop smoke. Root xác minh APK 0.3 artifact ready ở local (51.642.944 byte; SHA256 `99649f3cb829098d8a7cbde8f06604a2320bed98ca3c0ed9df4197a0241eca99`), chữ ký/alignment đạt, package/certificate giữ để hỗ trợ update 0.2→0.3. Chưa kiểm cài đè thiết bị; chưa mobile verified; GitHub released chờ URL remote xác nhận.
- PO yêu cầu checkpoint khi bước/trạng thái hướng dẫn đổi để restart không lùi bước; Dev đã bổ sung save ngay trên transition, giữ gate bảo vệ save lỗi và tránh ghi mỗi frame.
- Quyết định sau 0.3: ưu tiên PO-04 dữ liệu đảo có provenance + PO-05 nội dung riêng đất liền/đảo; PO-08 device test là cửa phát hành. BA/SA/Designer lập đề xuất dữ liệu và hai cảnh mẫu trước khi mở rộng, Dev/Tester xác nhận pipeline/offline/save.
- Benchmark công khai vẫn là đầu vào giả thuyết; test logic/render không thay phỏng vấn hay playtest người dùng và không chứng minh nhu cầu thị trường.


## Decision log — vertical slice 0.4

- Theo bước khả thi BA đã được người dùng duyệt, PO chốt PO-10: một đèo minh họa khoảng 750 scene-m, xe máy điều khiển được, traffic đơn giản có va chạm, hai điểm dừng và vòng lái→dừng→đi bộ tham quan→lái tiếp. PO-10 được ưu tiên trước mở rộng địa lý; PO-04/05 vẫn mở.
- Phạm vi hình ảnh bán hiện thực theo cảm giác ảnh tham chiếu; không cam kết photoreal, địa hình GIS Khánh Lê chính xác, toàn Việt Nam hoặc FPS điện thoại chưa đo. Asset phải do team tạo hoặc có license/provenance.
- Photo mode offline optional/deferred; ưu tiên loop, input cảm ứng/keyboard, save tương thích và desktop/Android artifact gates. Chi tiết AC nằm trong PRODUCT_BACKLOG.md; chưa nghiệm thu implementation 0.4.

- PO làm rõ reset 0.4: về checkpoint an toàn gần nhất đã đi qua trên tuyến (d470→230 nếu các mốc0/230/550), không nhảy tới mốc chưa chạy; hai điểm dừng cần đoạn nội dung riêng, không dùng chung mô tả chỉ đổi tên.


## Nghiệm thu PO-10 prototype 0.4

QA báo 417 assertion PASS (160 mới + 257 hồi quy); root báo desktop `PASS04_VISUAL_PASS` và pilot vật lý đi từ s5 tới s738,02. PO accepted **technical playable prototype**, gồm reset latest-passed đúng ranh giới và nội dung điểm dừng riêng. Hình ảnh hiện vẫn stylized; chưa đạt hình ảnh bán hiện thực theo tham chiếu. APK 0.4 đang build, chưa artifact ready; cài thật Android/iOS, FPS/đa chạm/upgrade và market validation còn mở. Không dùng nghiệm thu kỹ thuật để tuyên bố hoàn thành art hoặc phủ đủ Việt Nam/đảo.
