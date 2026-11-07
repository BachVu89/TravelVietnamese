# Chuyển Dọc miền Việt sang Unreal Engine 5

## Quyết định và trạng thái

Unreal Engine là yêu cầu mới của chủ sản phẩm. Nhánh triển khai mới đặt trong `unreal/TravelVietnamese/`, đích ban đầu **UE 5.5**; muốn dùng 5.4 hoặc bản mới hơn cần mở, biên dịch và kiểm tra lại bằng đúng phiên bản đó. Không suy ra tính tương thích chỉ từ việc các phiên bản cùng mang tên UE5.

Môi trường hiện không có `UnrealEditor`, `UnrealBuildTool` hoặc Xcode. Mã UE là **source scaffold chưa được biên dịch, mở trong editor, cook hay chạy trên thiết bị**. Kiểm tra văn bản/cấu trúc không thay cho build hoặc kiểm thử đồ họa. APK Godot hiện có được giữ nguyên; không gọi APK đó là bản Unreal. Source, save và vòng đời hai engine tách biệt.

Không có asset, plugin trả phí hoặc nội dung Marketplace/Fab nào được mua/tải trong bước này. Mesh thủ tục và material slots chỉ là placeholder; không phải chất lượng tương đương ảnh tham khảo hoặc đèo thực địa.

## Nền tảng và khả năng cần phân biệt

| Hạng mục | Android/iOS offline | Desktop cấu hình cao |
| --- | --- | --- |
| Renderer | Bắt đầu bằng pipeline mobile tiêu chuẩn; cấu hình và shader phải kiểm tra riêng theo thiết bị | Có thể đánh giá deferred và các tính năng cao hơn trong profile riêng |
| Nanite | Không dựa vào Nanite cho gói mobile cơ sở; cần mesh thông thường, LOD/HLOD phù hợp | Có thể đánh giá khi GPU/RHI và phiên bản UE đáp ứng |
| Lumen | Không dùng làm giả định chiếu sáng mobile; chọn baked lighting/ánh sáng đơn giản và reflection phù hợp | Có thể đánh giá cùng chi phí GPU, độ phân giải và mục tiêu FPS |
| Android desktop renderer | Không lấy chế độ Vulkan desktop/experimental làm đường phát hành mặc định | Không liên quan đến việc game desktop dùng GPU hỗ trợ |
| iPhone 13 | Cần build Metal/iOS thật, đo frame time, RAM và nhiệt; không hứa Nanite/Lumen vì tên thiết bị | Không áp dụng khả năng GPU desktop sang điện thoại |
| PCG | Dùng trong editor để tạo và bake nội dung trước cook khi phù hợp; nội dung đã bake đi trong bản cài | Có thể nghiên cứu sinh runtime sau khi profile, không bắt buộc ở bước đầu |
| Offline | Map, mesh, material, texture, âm thanh và dữ liệu thiết yếu phải được cook/package đầy đủ | Cùng nguyên tắc; không dựa vào tải asset hoặc API mạng lúc chơi |

Bảng này xác định hướng nền tảng, không tuyên bố tính năng cao cấp không bao giờ chạy được. Mọi ngoại lệ phải có phiên bản engine, RHI, thiết bị hỗ trợ và kết quả đo cụ thể; chưa phải baseline Android/iOS của dự án.

## Lộ trình có cổng nghiệm thu

### 1. Xác minh toolchain và scaffold

Cài UE 5.5 qua kênh Epic hợp lệ hoặc build source theo quyền truy cập/license tương ứng. Dùng toolchain C++ được phiên bản UE hỗ trợ. Mở `.uproject`, tạo project files, compile module và xác minh GameMode/Character, spawn, input và collision. Chốt working map rồi lưu một map `.umap` thật; mã C++ tự tạo actor không đồng nghĩa đã có startup map hợp lệ.

Cổng qua bước: editor mở được, không lỗi module/asset/map, PIE chạy được, có log build và smoke test. Chưa đạt cổng này thì chỉ giao source scaffold.

### 2. Một đoạn đèo chơi được

Dựng một đoạn đường spline nhỏ có mesh/collision nhất quán, nhân vật/xe điều khiển được, camera tránh vật cản, traffic tối thiểu, dừng/xuống xe và một POI. Character đi bộ thử nghiệm không được nghiệm thu thay xe máy third-person. Tách gameplay và profile hình ảnh; không dùng ảnh tham khảo làm texture hoặc tài nguyên có bản quyền chưa rõ.

Cổng qua bước: người chơi hoàn thành vòng lái → phanh → đỗ → đi bộ → tương tác, không xuyên đường/rào/traffic hoặc mắc kẹt; save/load hoạt động; cảnh thể hiện rõ đang minh họa. Phải đánh giá đường và chiều dài theo dữ liệu thực nếu muốn quảng bá là tái hiện đèo Khánh Lê.

### 3. Nghệ thuật bán hiện thực và đo mobile

Thay placeholder bằng asset có nguồn, quyền sử dụng, attribution và điều kiện phân phối rõ. Dùng LOD cho xe/người/cây/đá, HLOD hoặc phân vùng phù hợp, culling, instancing, texture LOD/compression, ngân sách draw call và bộ nhớ. Ánh sáng bake hoặc phương án mobile được đo; không yêu cầu Lumen để đạt hiệu ứng đường ẩm/sương/núi xa. PCG trong editor phải bake ra nội dung có thể cook, không để plugin editor-only trở thành phụ thuộc runtime.

Chốt điện thoại thấp nhất, dung lượng gói, FPS và chất lượng hình ảnh với PO trước khi mở rộng. Mục tiêu 30 FPS là mục tiêu cần đo, chưa phải kết quả. Đo trên Android và iOS riêng: frame time CPU/GPU, RAM, shader stutter, nhiệt và pin trong lượt chơi dài, không chỉ chụp hình editor.

### 4. Cook, cài và kiểm tra offline

Build Shipping/Development theo mục đích, cook đúng map và tài nguyên được tham chiếu; kiểm tra tài nguyên được tải động có mặt trong cook list/Asset Manager. Cài bản standalone lên máy, tắt mạng và mở lạnh; chơi, lưu, đóng/mở lại và chuyển khu. Editor PIE hoặc Mobile Preview không thay kiểm thử gói native.

### 5. Mở rộng Việt Nam theo dữ liệu và năng lực nội dung

Giữ registry 34 tỉnh/thành và dataset đảo hiện có như nguồn dữ liệu cần rà soát; không coi 47 tên/cảnh minh họa là 47 vùng Unreal đã hoàn thiện. Mỗi vùng có trạng thái riêng: đăng ký metadata, scene chơi được, asset biên tập, kiểm chứng địa lý và kiểm thử thiết bị. Chốt coverage đảo, độ chính xác, cách thể hiện đường biên và số vùng đầu tiên với PO trước sản xuất toàn quốc. Chỉ nhân rộng sau khi đoạn mẫu qua cổng gameplay, visual, licensing và hiệu năng.

## Build/cook và những gì còn thiếu

- **Desktop/editor:** UE 5.5 + compiler/SDK phù hợp hệ điều hành; module C++ và plugin được build thành công. Không tự tải engine hoặc plugin trả phí trong script thiết lập.
- **Android:** dùng hướng dẫn/Turnkey của đúng UE 5.5 để xác nhận Android Studio, SDK, NDK, JDK và target API tương thích. SDK/JDK đã dùng cho Godot/Expo không tự động chứng minh phù hợp UE. Cần package identifier, cấu hình ABI, signing theo mục đích và thử nghiệm thiết bị. Tách khóa thử nghiệm khỏi khóa phát hành, không đưa secret vào source.
- **iOS:** macOS/Xcode được UE hỗ trợ, Metal toolchain, Apple team/certificates/provisioning cho kênh phân phối được chọn; C++ cần build trên Mac hoặc remote Mac được cấu hình đúng. Môi trường Linux hiện tại không chứng minh tạo hoặc ký được IPA.
- **Cook:** startup map được tạo/lưu rõ, tài nguyên gameplay được cook đủ, shader platform tương ứng, không phụ thuộc editor-only modules. Nêu rõ log, engine version và thiết bị cho mỗi kết quả.

Sau khi đã compile và lưu map, có thể dùng AutomationTool `BuildCookRun` của engine với `.uproject`, map, target platform và cấu hình phù hợp. Không lưu một lệnh cook giả định như bằng chứng build: tên map, target, ký và toolchain phải được xác minh trên máy thực trước.

## Save và dữ liệu khi chuyển engine

Godot lưu `user://journey3d.json` version 1 với region/positions/visited và các nhánh tùy chọn. Unreal cần save riêng (ví dụ `USaveGame`) với version, stable region/POI IDs và dữ liệu gameplay tương ứng. Tọa độ và route parameter của Godot không được copy trực tiếp sang Unreal vì scale, trục, scene và collision khác nhau.

Không tự động tuyên bố chuyển được save cũ. Một tính năng import tương lai cần thao tác rõ của người chơi, mapping ID có phiên bản, kiểm tra dữ liệu, bảo toàn tệp cũ và điểm spawn an toàn. APK sandbox của ứng dụng cũ cũng không mặc nhiên đọc được từ app Unreal. Ưu tiên import dấu/tiến trình có stable IDs; vị trí/xe phải phục hồi theo world version hợp lệ hoặc checkpoint an toàn.

## Tiêu chí bàn giao hiện tại

Bàn giao scaffold UE và tài liệu, không bàn giao APK/IPA Unreal đã chạy. Nêu rõ placeholder, thiếu toolchain/compile/editor/device validation và giữ artifact Godot riêng. Cổng nghiệm thu kế tiếp là mở và build scaffold trên UE 5.5, sau đó tạo map và xác minh vòng chơi mẫu trước khi đặt mục tiêu sản xuất toàn quốc.

## Entrypoint được cung cấp, chưa phải bản build

`python scripts/build-unreal.py --engine /path/to/UE --target editor|android [--check-only]` hỗ trợ kiểm tra đường dẫn và gọi toolchain của engine thực. Chọn một giá trị `editor` hoặc `android`; dấu `|` ở đây chỉ biểu thị lựa chọn. Script yêu cầu UE 5.5 trở lên trong UE5, target editor `TravelVietnameseEditor`; Android gọi `BuildCookRun` Development/ASTC và archive mặc định `artifacts/unreal-android`.

`--check-only` chỉ xác nhận metadata/project/entrypoint tồn tại; không xác nhận compiler/SDK, plugin, map, shader, material hoặc cook được. Với engine thiếu hiện tại, kiểm tra trả exit code 2 và `BLOCKED`, không chạy build và không tạo APK mới. Người dùng xác nhận chưa có UE, asset hoặc máy triển khai, nên bước mở editor/compile/cook cần môi trường mới đáp ứng tiền đề; tài liệu không giả định có engine đã cài.

Yêu cầu hình ảnh nguyên văn được giữ tại `docs/inputs/GRAPHICS_BRIEF_2026-11-07.txt` để đối chiếu trong quá trình duyệt scope và chất lượng. Nó là brief tham khảo, không phải nguồn asset hoặc bằng chứng tính năng đã hoàn thành.

## Đối chiếu scaffold thực tế

`ATravelPassEnvironment` cung cấp spline `Route`, `UProceduralMeshComponent` cho bề mặt, HISM cho cây/rào và các material slots. `Regenerate()` hỗ trợ CallInEditor; `RoutePosition()`/`RouteLengthCm()` dùng centimet của Unreal. `ATravelPassGameMode` hiện chọn `ATravelExplorerCharacter` đi bộ với camera góc thứ ba ở mức source chưa chạy; chưa chuyển gameplay xe, traffic, POI, touch và save Godot sang UE. Targets là `TravelVietnamese` và `TravelVietnameseEditor`, module runtime `TravelVietnamese`.

`Content/Python/bootstrap_pass.py` chỉ chạy sau compile Editor để tạo `/Game/Maps/PassPreview` với actor môi trường/đèn/sương/PlayerStart và từ chối ghi đè map sẵn có. Startup/game/cook config trỏ `/Game/Maps/PassPreview`; map chưa có trong source và phải sinh/lưu qua bootstrap. Script từ chối map trùng và map hiện tại còn thay đổi chưa lưu. Build wrapper Android chặn nếu thiếu file `.umap`. `create_mobile_materials.py` là công cụ Editor tạo material PBR tham số (wetness trộn màu/roughness), giữ asset có sẵn và bootstrap gán slots còn trống; chưa có texture scan/normal/puddle/weather và chưa có bằng chứng script đã thực thi hoặc `.uasset` được cook. Config thử nghiệm dùng app ID riêng `com.travelvietnamese.unrealproof`, không thay thế sandbox/save Godot. PCG được bật nhưng chưa có graph hoặc nội dung PCG được bake; Python chỉ được bật cho Editor.

## Tiến triển source và asset gốc sau scaffold

Source đã thêm `ATravelExplorerCharacter` với CharacterMovement/camera collision, input và điểm phục hồi đầu tuyến; chưa kiểm runtime. Đã có ba mesh FBX gốc từ Blender (đá/dương xỉ/chuối), source `.blend`, UV và material slots, không có scan/Marketplace. Xem [ORIGINAL_ASSETS.md](art/ORIGINAL_ASSETS.md). Preview Blender không phải ảnh UE hoặc bằng chứng đạt tham chiếu. Importer UE cùng HISM optional hard references đã chuẩn bị; còn phải kiểm scale, hai mặt lá, shader, map/cook và điện thoại. Không đóng cổng editor/gameplay/device của lộ trình chỉ vì các file nguồn có mặt.

Kiểm tra kênh source Epic chính thức trong phiên này trả `Repository not found`, nên chưa thể tải/cài từ kênh đó với danh tính hiện tại. Không dùng mirror không rõ quyền hoặc bỏ qua quyền truy cập. Cần bản engine được cung cấp hợp lệ hoặc tài khoản Epic/GitHub đã có entitlement được cấu hình trong môi trường để tiếp tục compile thực; không gửi token/mật khẩu vào tài liệu hoặc cuộc trò chuyện.
