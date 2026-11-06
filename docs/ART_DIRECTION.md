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

## Art direction 0.4 — Đèo rừng bán hiện thực

### Mục tiêu hình ảnh

Cảnh đèo 750 scene-m lấy cảm hứng ảnh tham chiếu người dùng: đường asphalt sẫm hơi ướt, cua ôm sườn núi, một phía vách đá, một phía vực/rừng, núi xa phủ sương, xe máy có người lái và giao thông thưa. Hướng bán hiện thực nhẹ cho mobile khác rõ cảnh capsule trên thảm cỏ cũ. Không cần photoreal hoặc sao chép đúng 100% ảnh; cũng không dùng nhãn mô phỏng địa danh thật khi tuyến chỉ minh họa.

Ưu tiên theo thứ tự: hình tuyến/cua và mặt đường → tỷ lệ xe/người → vách đá/guardrail → lớp rừng và núi xa → độ ướt/sương → vật nhỏ. Primitive có thể làm khung dựng, nhưng cần tạo silhouette có chủ đích, vật liệu và biến thể; không dùng một mặt phẳng xanh cùng hàng nón cây lặp đều làm thành phẩm.

### Palette và vật liệu đèo

| Thành phần | Màu nền đề xuất | Cách tạo hình/đọc |
| --- | --- | --- |
| Asphalt ướt | `#252D30` | Mặt liền theo tuyến, biến thể nhẹ `#343C3D`; roughness vừa, không như gương |
| Lề sỏi/đất | `#74766C` | Viền bất quy tắc, tối hơn ở nơi đọng ẩm |
| Vạch vàng | `#E4B84C` | Chạy theo tim tuyến; hình học đặt nhô rất ít tránh z-fighting |
| Guardrail | `#B6BFBE` | Thanh liên tục theo cua, cọc `#545D5C`, đặt phía vực |
| Đá gần | `#68716A` | Mảng lồi lõm/chéo, đổi sắc độ; không một tường hộp phẳng toàn tuyến |
| Rừng trung cảnh | `#345C45` | Tán nhiều kích thước, thân nhìn được ở khoảng gần |
| Rừng tối | `#223E33` | Mảng nền dày, tránh đen đặc |
| Fern/cây thấp | `#4D7350` | Cụm dọc chân đá/lề, không tràn làn xe |
| Núi xa | `#6F8D83` | Nhiều lớp sáng/dịu dần theo chiều sâu |
| Sương | `#A6B6B3` | Che chuyển tiếp phía xa, giữ rõ cua và xe gần |
| Trời u ám | `#B2C2C3` | Ánh sáng khuếch tán, tương phản vừa |

Sắc độ mặt đường và vạch phải đọc được cả khi tắt bóng. Dùng vật liệu opaque, roughness điều chỉnh và ánh sáng đơn giản để gợi ướt; không cần reflection realtime nặng/SSR. Vũng ẩm nhỏ không được tạo cảm giác mặt đường thủng hoặc vật thể nguy hiểm khi gameplay không có cơ chế đó. Fog cơ bản phù hợp Compatibility renderer; không dựa vào volumetric fog không hỗ trợ trên cấu hình mục tiêu.

### Tỷ lệ và bố cục cảnh

- Mặt đường mục tiêu 6,5–7 m cho hai làn, lề khoảng 0,6 m mỗi bên. Tỷ lệ này để đọc và điều khiển trên mobile, không phải thông số đo tuyến thật.
- Guardrail cao khoảng 0,75 m, cọc cách đều có biến thiên ở cua; collision đủ ngăn xe vượt vực ngoài ý muốn. Không chặn miệng điểm dừng.
- Địa hình gần cao hơn đường phía vách, thấp dần phía vực; tạo nhiều mặt và gờ ngang thay tường thẳng đều. Tránh cho địa hình xuyên mặt asphalt.
- Hai lay-by tại vị trí tầm nhìn tốt, ví dụ khoảng 1/3 và 2/3 tuyến, không đặt ở apex cua khuất. Làn vào/ra trơn và chỗ quay xe/đứng cạnh xe.
- Đường có ít nhất hai kiểu cua/nhịp nhìn; mesh và vạch bám cùng spline/quy tắc tuyến, tránh vạch đi tắt qua góc nối.
- Xa cảnh: 2–3 lớp núi/rừng silhouette lệch nhịp; fog làm mềm nhưng không thay thế toàn bộ nền bằng màn trắng.

### Xe, người lái và giao thông

Xe máy phải có hai bánh với lốp tối, trục theo hướng chạy; thân xe, yên, tay lái và đèn nhận diện được từ camera sau. Người lái có đầu/mũ bảo hiểm, thân nghiêng nhẹ, tay hướng tay lái và chân hai bên; không chỉ đặt capsule dựng đứng trên xe. Dùng mesh tự tạo rõ tỷ lệ và material dùng chung. Bánh có thể quay theo vận tốc; nghiêng ở cua vừa phải, không cần mô phỏng vật lý thực xe máy trong slice.

Giao thông thưa, chạy cùng bề mặt/tuyến hợp lý, có khoảng cách spawn an toàn; không đặt xe làm vật trang trí giữa làn đang chạy rồi gọi đó là traffic hoạt động. Đèn/vật liệu tương phản giúp thấy trong fog. Không dùng tên/logo thương hiệu thật hoặc asset không rõ giấy phép.

### Thảm thực vật có chủ đích

Cây thông/tán lá rộng và cụm tre tạo biến thể theo vùng cảnh, không rải tất cả loài ngẫu nhiên với mật độ đều. Gần đường có thân/cành và fern/cỏ cụm nhỏ; trung cảnh dùng mesh đơn giản đa biến thể; xa cảnh dùng khối canopy/silhouette. Rải bằng seed ổn định, chừa vùng mặt đường/lề/lay-by, tránh cây mọc xuyên guardrail. Dùng MultiMesh/mesh tái sử dụng nếu phù hợp; không bật shadow trên mọi bụi cây.

Tất cả asset trong batch ưu tiên tự dựng procedural và vật liệu do nhóm tạo. Nếu bổ sung thư viện ngoài, kiểm tra giấy phép phân phối trước, đóng gói offline và ghi attribution/nguồn. Không lấy ảnh tham chiếu làm texture phân phối khi chưa có quyền.

### Review hình ảnh và hiệu năng

Review ba camera: từ xe ở cua có vách đá, đoạn mở nhìn núi xa, và đi bộ tại lay-by nhìn lại xe. Mỗi ảnh phải phân biệt được đường, lề, đá, tán cây, xe và đường chân trời; không quá bão hòa xanh/cam. Kiểm tra mesh asphalt không hở/vỡ ở góc cua, guardrail không cắt vào làn xe, bánh xe không nổi/lún rõ.

Mục tiêu 30 fps trên thiết bị đại diện vẫn phải đo; batch0.4 tăng chiều dài/traffic/cây nên cần profiler lại, không kế thừa kết luận từ scene cũ. Tắt bóng là tùy chọn hình ảnh, không chứng minh tối ưu xong. Hạn chế vật liệu riêng, shadow caster và alpha overdraw; ưu tiên fog/culling/mesh chung. Không thêm hiệu ứng nặng để bù thiếu bố cục hoặc silhouette.

### Module vật liệu đã cung cấp

`game3d/scripts/pass_materials.gd` cung cấp bốn static factory `road()`, `rock()`, `grass()`, `metal()` trả về `StandardMaterial3D` dùng chung/cached. Asphalt có albedo noise sẫm, roughness biến thiên giới hạn và normal nhẹ; rock có texture rêu/đá cùng world-triplanar kéo lớp; grass có màu đất rừng biến thiên; guardrail là kim loại satin. Texture procedural 256×256, deterministic seed, mipmaps; không dùng tài nguyên tải mạng hoặc custom shader. Geometry đường cần UV theo mét (module đặt scale 0,5); rock/grass dùng world-triplanar. Nếu sửa riêng từng mesh, duplicate material để không ảnh hưởng vật liệu dùng chung.

Đã kiểm tra factory khởi tạo/cache và cả sáu texture procedural tạo ảnh 256×256 bằng Godot 4.6.3 headless. Đây là kiểm tra tài nguyên, chưa phải review hình ảnh GPU hoặc benchmark trên điện thoại. Cần xem ánh sáng/fog thực tế và điều chỉnh độ ướt nếu bị phản sáng quá mức.
