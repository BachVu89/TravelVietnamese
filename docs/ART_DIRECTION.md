# Định hướng mỹ thuật — Việt Nam 3D cách điệu

## Phong cách

Stylized low-poly, màu ấm và hình khối rõ để đọc tốt trên màn hình điện thoại. Góc nhìn third-person, nhân vật có silhouette đơn giản, môi trường có đường đi và mốc nhận diện. Dùng mesh 3D thật và collision cho các vật thể chính. Phong cách tối giản không có nghĩa thay mọi địa phương bằng cùng một nhóm hộp và đổi tên.

Vertical slice là một khu tham quan nhỏ đại diện kỹ thuật và hướng mỹ thuật. Ghi rõ “cảnh mẫu/tái hiện cách điệu”; chưa đủ cơ sở để gọi là bản sao địa lý chính xác hoặc mô phỏng trọn tỉnh. Không dùng nhãn “đầy đủ Việt Nam” chỉ vì registry có đủ tên hoặc tạo được cảnh procedural cho mọi mục.

## Palette vật liệu

| Vai trò | Màu sRGB đề xuất | Ghi chú |
| --- | --- | --- |
| Trời | `#BBDDE5` | Nền sáng dịu, đường chân trời rõ |
| Nước | `#3E8998` | Mặt nước đơn giản, ưu tiên ổn định trên mobile |
| Cỏ/cây | `#537C52` | Tách sắc độ thân và tán cây |
| Đất/cát | `#D9BE8D` | Đường đi sáng để định hướng |
| Mái ngói | `#A9543E` | Nhận diện kiến trúc, không dùng cho mọi mái |
| Tường sáng | `#E8D6AE` | Phối với viền tối khi cần |
| Đá | `#8D9590` | Biến thể sáng/tối, tránh toàn cảnh đồng màu |
| UI nền giấy | `#FFF8ED` | Menu và bảng thông tin |
| UI chữ | `#173F35` | Chữ chính, nút trên nền sáng |
| UI nhấn | `#E9B44C` | Tương tác; luôn kèm chữ/icon |

Godot: ưu tiên vật liệu StandardMaterial3D đơn giản, opaque, roughness cao, dùng chung tài nguyên vật liệu. Palette trên là đề xuất thiết kế; đo tương phản thực tế khi triển khai UI. Tránh transparency nhiều lớp, post-processing nặng và shader nước phức tạp ở slice đầu. Ánh sáng ban ngày cố định; bóng tối không che lối đi.

## Tier nội dung và cách công bố

| Tier | Có gì | Được gọi là | Không được gọi là |
| --- | --- | --- | --- |
| D0 — registry (cấu trúc dữ liệu) | Tên, ID, loại mục, metadata nguồn; mỗi mục phải liên kết bộ tạo cảnh hoặc scene | Metadata cảnh | Bản tái dựng đã kiểm chứng |
| S1 — procedural minh họa | Mesh đất/đảo theo biome, bờ, spawn, collision, POI và vùng di chuyển an toàn | Địa hình tạo theo quy tắc · minh họa | Đảo chính xác/đầy đủ chi tiết |
| S2 — điểm tham quan | Địa hình, landmark có silhouette riêng, đường đi, POI và tương tác | Cảnh điểm tham quan cách điệu | Toàn tỉnh được mô phỏng |
| S3 — mở rộng | Nhiều điểm tham quan, trang trí, âm thanh cục bộ, tối ưu và kiểm chứng | Khu tham quan mở rộng | Tái hiện 1:1 nếu chưa có dữ liệu đo |

Mọi mục trong registry 34 tỉnh/thành và danh sách đảo/quần đảo phải có cảnh vào được, tối thiểu S1 có biome phù hợp, collision và POI. Mẫu Hà Nội và một đảo ưu tiên S2 làm chuẩn chất lượng; không vì chỉ có hai scene thủ công mà khóa các mục còn lại. Người dùng yêu cầu đảo cũng được làm chi tiết: S1 là bước triển khai minh họa có ghi nhãn, không được tuyên bố đã đáp ứng độ chi tiết riêng cho từng đảo. Tăng dần tài sản, đường đi và landmark riêng để nâng lên S2/S3. Không tạo scene sao chép tự động rồi báo đã tái hiện hoàn chỉnh mọi nơi. Tên tier là hợp đồng nội dung; tiến độ và chất lượng từng cảnh cần báo riêng.

## Scene mẫu có thể review

- Một đường đi có đầu/cuối và khoảng trống quay camera.
- Một landmark có hình dáng nhận diện, tỷ lệ hợp lý với nhân vật; mái, cột, đế hoặc khối chính được dựng có chủ đích.
- Cây, ghế, đá hoặc hàng rào hỗ trợ bố cục; số lượng ít và dùng chung mesh.
- Ít nhất một POI có điểm đứng thuận tiện, không bắt người chơi xuyên vật thể.
- Có ranh giới địa hình rõ; nước và cảnh nền không tạo kỳ vọng khu vực đi được khi chưa có collision.

Nếu chưa đủ tài sản để nhận diện landmark thật, gọi scene là khu tham quan mẫu hư cấu lấy cảm hứng, không gắn tên công trình có thật như đã tái dựng.

## Ngân sách ban đầu để đo trên thiết bị

Đây là mục tiêu thăm dò, không phải kết quả benchmark: viewport tham chiếu 1280×720 landscape; mục tiêu tối thiểu 30 fps ổn định trên thiết bị Android/iOS đại diện đã chọn. Bắt đầu từ khoảng dưới 100k tam giác hiển thị và dưới 100 draw calls cho slice, sau đó đo profiler và điều chỉnh. Giảm số vật liệu, tái sử dụng mesh, tránh bật bóng trên mọi vật thể. Đừng tăng chi tiết chỉ để đạt một con số polygon; ưu tiên silhouette và đường đi dễ đọc.

Không cam kết hiệu năng iOS từ phép đo Android, hoặc ngược lại. Thử cảnh ngoài trời, vùng sát landmark, mở/đóng menu và xoay camera liên tục. Kiểm tra nhiệt/pin trong phiên dài sau khi có build thiết bị.

## Asset và tính offline

Ưu tiên mesh dựng trực tiếp, primitive được tạo hình có chủ đích và vật liệu màu cục bộ. Nếu thêm asset ngoài: lưu cùng nguồn, giấy phép và attribution; chỉ dùng asset được phép phân phối trong game. Font tiếng Việt phải được đóng gói hoặc dùng font hệ thống đã kiểm chứng với engine. Không tải font, model, nhạc hay texture từ mạng khi chơi.

Không dùng emoji như landmark 3D. Không dùng texture ảnh địa danh để thay thế toàn bộ trải nghiệm khám phá. Ảnh tham khảo phục vụ dựng cảnh và kiểm chứng, không tự động chứng minh quyền sử dụng.

## Cấu hình hình ảnh 0.3

Menu cung cấp **Bóng đổ: Bật / Tắt**, mặc định Bật; giữ nguyên palette, độ sáng tổng thể, collision và nội dung khi đổi. Không coi Tắt bóng là bằng chứng đã tối ưu cho máy yếu hoặc đạt FPS cụ thể. Cần kiểm tra vật thể không bị hòa nền khi mất bóng, không dựa vào bóng để chỉ lối hay nhận diện POI. Đây là setting lưu trên máy và cần áp dụng cả khi dựng cảnh tiếp theo.
