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

## Rà soát hình ảnh sau 0.4 — đề xuất batch 0.5

Đã xem trực tiếp `docs/screenshots04/start.png`, `bend.png`, `viewpoint.png` và đối chiếu nguồn dựng cảnh. Đối chiếu ảnh tham chiếu ở mức các đặc trưng đã mô tả trong yêu cầu: asphalt ướt, rừng lá nhiều lớp, đá/sương và người đi xe. Đây không phải đánh giá ảnh gốc pixel-by-pixel. Ảnh 0.4 chứng minh bố cục đèo và xe hoạt động ở mức prototype; chưa đạt chất lượng bán hiện thực mong muốn, càng chưa phải photoreal.

### Ba ưu tiên có tác động nhìn thấy rõ

| Ưu tiên | Bằng chứng hiện tại | Thay đổi cần nhìn thấy | Ràng buộc mobile |
| --- | --- | --- | --- |
| 1 — Rừng nhiều lớp | Tán là 420 sphere cùng cấu trúc, thân đơn; bờ vực trống, tạo cảm giác cây kẹo mút | Tán nhiều cụm lệch nhau, thân có cành; gần đường có leaf-card/cụm fern, giữa có cây biến thể, xa là canopy/silhouette liền | MultiMesh và vật liệu dùng chung; card cận/trung cảnh có khoảng cách cắt; không shadow mọi lá |
| 2 — Đá và mặt đất | Vách là strip nghiêng phẳng với noise kéo dài; asphalt nhìn nhòe từ camera sau xe | Mỏm/ledge đá tạo chiều sâu, chân đá có đất ẩm/rêu; asphalt có hạt mịn, mảng ẩm lớn nhẹ, vạch không phát sáng | Thêm silhouette bằng mesh lặp có xoay/tỷ lệ; texture 512–1024 phù hợp, mipmaps; không SSR/displacement nặng |
| 3 — Chiều sâu và ánh sáng | Fog làm bạc màu gần cảnh; núi xa hiện như tấm tam giác dựng đứng, guardrail gần trắng | Núi nền liền silhouette thành 2–3 lớp, rừng gần còn tối/sắc; fog tăng theo xa, rail satin dịu | Basic fog Compatibility, giảm shadowcaster/drawcall; không volumetric fog hay hiệu ứng đắt để che thiếu geometry |

### Hợp đồng leaf-card nếu được duyệt

Ảnh cây lá phải là asset nguyên gốc hoặc có quyền phân phối rõ, nền alpha thật, không chứa ảnh nền trời/cảnh rừng bị cắt giả. Mỗi card nên chứa một cụm cành/lá đọc được ở camera gameplay, không nhồi hàng trăm lá cực nhỏ thành nhiễu. Dùng biến thể màu vừa phải, bố trí 2–3 mặt cắt nhau cho bụi/cụm lá, thân/cành vẫn là mesh. Không thay toàn bộ cây gần bằng một billboard phẳng quay như tấm biển.

Vật liệu alpha-scissor/cutout ưu tiên cho mobile; có thể đánh giá alpha-hash/dither nếu Compatibility và thiết bị mục tiêu cho kết quả ổn định, không mặc định tuyên bố alpha-hash đã hỗ trợ/tối ưu. Giữ ngưỡng cắt đủ tránh viền trắng, dùng texture filter có mipmaps và kiểm tra shimmer khi xe chạy. Tránh alpha blending nhiều lớp toàn rừng, bóng lá alpha và mặt card gần camera che đường. Không đổi collision theo leaf alpha.

Nếu root tạo asset bằng image generation: lưu ảnh nguồn, phiên bản xử lý được duyệt và ghi nguồn tạo; dùng công cụ chỉnh ảnh được chỉ định để thay đổi hình ảnh, không tự giả lập alpha bằng lệnh xử lý không được phép. Nếu chưa có texture, có thể dựng geometry lá nguyên gốc để kiểm chứng layering nhưng cần ghi rõ là fallback procedural.

### Khung review 0.5

Chụp lại cùng ba vị trí/camera start, bend, viewpoint để so trực tiếp với 0.4; thêm một ảnh nhìn gần rừng/đá nếu hữu ích. Không đổi góc nhìn để giấu cảnh chưa đẹp. Điều kiện nhìn thấy: giảm rõ hàng cây cùng dáng, cliff có silhouette/outcrop, nền núi không còn tấm tam giác rời, mặt đường và vạch vẫn rõ qua fog. Ghi riêng tính đúng chức năng, review thị giác GPU và hiệu năng thiết bị; headless factory test không xác nhận hình ảnh đẹp. Chưa đặt nhãn “photoreal” hoặc “giống ảnh 100%” cho batch này.

### Quyết định triển khai 0.5 đã chốt với PO/Dev

PO-11.A–C duyệt ba cải thiện nêu trên. Batch này chọn **geometry foliage opaque nguyên gốc**, không chờ ảnh tạo sinh hoặc leaf-card alpha: Dev dựng ba dạng cây (broadleaf nhiều cụm lệch, pine phân tầng, thân cao mảnh), understory fern/bush và các cụm rừng theo khoảng cách. Đây là cách giảm chi phí alpha overdraw và giữ nguồn tài nguyên rõ; không được suy ra geometry procedural đã đạt photoreal. Leaf-card vẫn là phương án nghiên cứu sau, không phải phụ thuộc chặn giao batch.

`pass_materials.gd` cập nhật `road()` dùng texture hạt asphalt 512×512 và UV scale2; geometry hiện cung cấp UV XZ×0,16 nên tile khoảng 3,125 m, thay tile cũ 12,5 m gây nhòe. Noise roughness giữ biến thiên ẩm nhẹ; normal giảm để tránh hạt lấp lánh/giả đá. `rock()` chuyển đá ấm xám-olive, giảm kéo dài strata; `grass()` tối hơn để rừng gần có độ tương phản; `metal()` rail satin dịu `#87948E`, roughness0,78. `foliage()` mới: opaque, vertex/instance tint, roughness1, specular0,08. `bark()` mới: texture vỏ cây nâu ẩm nguyên gốc, world-triplanar. Không đổi geometry/collision, không thêm shader/custom asset ngoài.

Palettes gợi ý cho instance màu tán: gần `#244A34`/`#345C3E`/`#47674A`; trung cảnh `#365844`/`#4C6C52`; xa nhẹ hơn theo fog, không sáng trắng. Tránh dùng một màu xanh cho cả đất, cây và đá; thân vỏ nâu trầm phải tách được tán. Tắt bóng vẫn phải đọc rõ các lớp bằng màu/silhouette.

Đã chạy `PASS05_MATERIALS` trên Godot4.6.3 headless: sáu vật liệu cache opaque và bảy texture procedural tạo được ảnh 256/512px. Đây là kiểm tra tài nguyên, chưa phải kết luận visual/fps. Renderer thực phải review lại ba camera cùng vị trí cũ.

Hai preset do PO chốt: **Tiết kiệm** mặc định, **Chi tiết** tăng chi phí trang trí/tầm nhìn có ghi cấu hình. Không đổi collision, POI, traffic, objective hoặc dấu khi chuyển preset; bật/tắt bóng là setting độc lập, không bị preset ghi đè. UI gọi đây là preset chất lượng, không bảo đảm “máy yếu chạy mượt” khi chưa benchmark thiết bị.

Thiết bị mục tiêu người dùng vừa cung cấp: **Oppo Find X7 Ultra** và **iPhone 13**. Đây là mục tiêu để lựa chọn bài kiểm và cấu hình, chưa phải bằng chứng đã cài, đo FPS/nhiệt, kiểm đa chạm hoặc xác nhận tương thích. Không dựa vào cấu hình danh nghĩa để công bố performance; lưu riêng kết quả thực của từng thiết bị khi có.

### Review ảnh render đối chiếu 0.5

Designer đã xem trực tiếp bộ capture GPU/Mesa của root tại `/tmp/travel05-pair-{04-legacy,05-economy,05-detail}-{start,bend,stop}.png`: kiểm tra ảnh 04/05 khúc cua, 04/05 đầu tuyến, 04/05 điểm dừng230 và so Tiết kiệm/Chi tiết. Theo metadata, cùng station/lane, góc và vị trí camera, FOV69°, ảnh1280×720; far plane là biến cấu hình được giữ khác nhau có chủ đích (Tiết kiệm440, Chi tiết650). Root báo bóng Bật cho mọi capture. Vì vậy đây là đối chiếu tổng thể preset, không phải phép đo chỉ một biến duy nhất.

| AC hình ảnh | Nhận xét trực tiếp từ ảnh |
| --- | --- |
| PO-11.A đường/mép | Asphalt tối và hạt mịn hơn, giảm mảng nhòe lớn của 0.4; guardrail bớt trắng phát sáng. Cua và vạch vẫn đọc được. Mảng ẩm chỉ nhẹ, chưa phải vật liệu ướt chân thực. |
| PO-11.B cảnh quan | Thấy rõ pine nhiều tầng, broadleaf nhiều cụm, bụi sát đất và mỏm đá mới; giảm cây một sphere đồng dạng. Chi tiết dày hơn Tiết kiệm nhìn thấy được từ cùng camera. Vách nền vẫn là dải nghiêng lớn, cây/bụi còn hình học rõ. |
| PO-11.C chiều sâu | Núi nền chuyển từ các tấm tam giác rời thành silhouette liên tục; gần cảnh tối và tương phản hơn, đường/traffic/điểm dừng vẫn thấy. Núi xa còn quá nhạt trắng-cyan, có thể gợi tuyết hơn rừng nhiệt đới. |

Không thấy lỗi hình học nghiêm trọng chặn đường trong các ảnh đã xem; ảnh tĩnh không chứng minh không có clipping ở toàn tuyến hoặc chuyển động. Một số bụi/mỏm trên slope trông đặt nổi hoặc giao nền thô; cần xem gần và khi xe chạy. Điểm dừng còn mặt nền phẳng trống, nhãn/marker vàng lớn mang phong cách prototype. Đây là các điểm mỹ thuật còn mở, chưa đủ để tuyên bố đạt fidelity ảnh tham chiếu.

Kết luận review phạm vi này: **có cải thiện hiển thị thực so với 0.4 ở cả ba nhóm**, vẫn là stylized prototype. Không gọi photoreal, không kết luận bán hiện thực đã hoàn tất, không suy hiệu năng thiết bị từ ảnh Mesa. Nên ưu tiên vòng sau giảm trắng-cyan của núi xa, xử lý chân bụi/đá bám slope và tăng chi tiết điểm dừng trước khi thêm hiệu ứng hậu kỳ.
