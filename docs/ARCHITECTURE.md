# Kiến trúc Dọc miền Việt 3D

## Quyết định kỹ thuật

Game chuyển sang khám phá 3D góc nhìn thứ ba: người chơi trực tiếp điều khiển nhân vật đi tham quan, đến gần điểm quan tâm để tương tác và khám phá Việt Nam. Android và iOS là đích phát hành, chơi offline sau khi cài. Dùng **Godot 4.6.3, GDScript và renderer Compatibility** trong thư mục `game3d/`. Compatibility là điểm xuất phát để hỗ trợ nhiều GPU di động; chất lượng và hiệu năng phải được đo trên thiết bị thực, không suy ra từ tên renderer.

Prototype React Native/Expo v0.1 ở gốc repository được giữ để so sánh; không dùng làm lõi 3D và không xóa mã nguồn hoặc APK cũ. `game3d/` có project, scene, scripts và dữ liệu riêng. Không nhúng engine vào React Native trong giai đoạn này: cách đó tăng rủi ro vòng đời, input, render và build mà chưa mang lại lợi ích cho vòng chơi chính.

## Công cụ đã kiểm tra

- Engine có sẵn: `/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64`. Lệnh `--headless --version` trả về `4.6.3.stable.official.7d41c59c4`.
- Android SDK hiện có tại `/workspace/android-sdk`: platform 36, build-tools 35.0.0 và 36.0.0, platform-tools, NDK và CMake. JDK 17 tại `/workspace/java/jdk-17.0.17+10`.
- `ANDROID_HOME`, `ANDROID_SDK_ROOT` và `JAVA_HOME` chưa được export trong shell lúc kiểm tra. Script build cần chọn các đường dẫn đã có; không cài thêm một bộ SDK/JDK chỉ vì thiếu biến môi trường.
- Build 0.2 sử dụng templates đúng **4.6.3 stable** tại `/workspace/godot-data/godot/export_templates/4.6.3.stable/` qua `XDG_DATA_HOME`; script build cấu hình `XDG_CONFIG_HOME` và `XDG_CACHE_HOME` trong `/workspace`. Không chỉ tìm ở thư mục home mặc định để kết luận thiếu templates.
- Linux không có Xcode. Build, ký và kiểm thử iOS cần macOS/Xcode cùng chứng chỉ/provisioning phù hợp cho cách phân phối được chọn.

Không in hoặc đưa khóa ký, mật khẩu, token vào repository hoặc tài liệu. Giữ kiểm tra TLS/chữ ký/checksum khi lấy templates hay tool bổ sung. Các kết quả build thực tế thuộc tài liệu validation, không coi checklist trong tài liệu này là kết quả đã đạt.

## Phạm vi thế giới và dữ liệu

Danh mục phủ **34 tỉnh/thành theo cơ cấu hiện hành** và các điểm đảo/quần đảo đã biên tập là mục tiêu dữ liệu. Phải phân biệt ba khái niệm:

| Lớp | Ý nghĩa | Bằng chứng hoàn thành |
| --- | --- | --- |
| Registry | ID, tên, loại địa danh, vùng, nguồn và độ phủ | Dữ liệu được kiểm tra trùng/thiếu, có nguồn và ngày rà soát |
| Scene có thể chơi | Môi trường 3D có nhân vật, va chạm và tương tác | Chạy được, đi lại và hoàn thành tương tác tại scene đó |
| Nội dung tham quan | Địa danh, mô hình, văn hóa và nhiệm vụ địa phương | Nội dung được biên tập, asset có quyền sử dụng và được kiểm thử |

Có đủ tên trong registry không đồng nghĩa đã dựng đủ tỉnh hoặc đảo 3D. Mỗi scene mẫu là một khu tham quan thu nhỏ, không phải mô phỏng toàn bộ diện tích địa phương. Dữ liệu đảo cần ghi rõ mức bao phủ và nguồn; không tự tuyên bố đã bao phủ mọi đảo. Không dùng bản đồ cách điệu như bản đồ hành chính, công cụ định vị hay bằng chứng về đường biên.

Bản 0.2 có 47 mục trong registry: 34 tỉnh/thành và 13 vùng đảo; mọi mục đều tạo được cảnh 3D với địa hình, va chạm và ba POI. Hà Nội là khu mẫu dựng riêng; các vùng khác được sinh thủ tục theo ID/nhóm cảnh. Mọi vùng đảo trong dataset phải vào được cảnh tương tác, không chỉ marker trong danh sách. Scene thủ tục phải được ghi là môi trường minh họa, không giả làm địa danh được tái hiện chính xác. Danh sách 13 vùng đảo chưa phải mọi đảo Việt Nam; mở rộng dataset và nội dung thực địa là công việc riêng.

## Cấu trúc dự án và thành phần

```text
game3d/
  project.godot           Cấu hình engine, renderer, input và scene khởi động
  scenes/                 Scene thế giới/nhân vật/giao diện nếu tách file
  scripts/                Điều khiển, thế giới, UI và lưu trữ
  data/                   Registry và POI được đóng gói
  assets/                 Mesh, material, âm thanh, font có giấy phép
  export_presets.cfg      Preset export không chứa bí mật
```

Các thành phần có thể gộp trong prototype; khi mở rộng cần giữ ranh giới trách nhiệm sau:

- **World:** lắp khu tham quan, spawn nhân vật/POI, collision tĩnh, ánh sáng và giới hạn thế giới.
- **Player:** `CharacterBody3D`, vận tốc theo camera, trọng lực và `move_and_slide`; không di chuyển trực tiếp bằng teleport mỗi frame để né collision.
- **Camera:** pivot và `Camera3D`; `SpringArm3D` hoặc truy vấn vật lý tránh xuyên tường, giới hạn pitch và khoảng cách.
- **Touch input:** joystick trái và kéo camera phải; theo dõi touch ID riêng để di chuyển và nhìn cùng lúc. Mở menu hoặc mất focus phải xóa input đang giữ. Có WASD/phím mũi tên và chuột để kiểm tra trên desktop.
- **POI:** vùng tương tác hoặc khoảng cách có kiểm tra, tên và nút tương tác khi đủ gần; không hoàn thành từ xa bằng cách chỉ chọn tên trong menu.
- **HUD/menu:** joystick, nút tương tác, tiến trình, tạm dừng/bộ chọn địa phương, hướng dẫn và nút quay về vị trí an toàn.
- **Save:** đọc/ghi local và nâng cấp schema, tách khỏi nội dung địa danh.

Màn hình landscape, UI theo safe area và co giãn bằng anchor/container. Input ở UI không được đồng thời xoay camera hoặc kích hoạt thao tác thế giới.

## Lưu trữ và offline

Mọi mesh, dữ liệu, font và âm thanh bắt buộc đi trong bản cài/PCK. Không dùng API bản đồ, tải tile, đăng nhập, quảng cáo hoặc CDN trong đường chơi. Chuyển địa phương chỉ nạp nội dung cục bộ đã đóng gói. Sau khi cài, mở lạnh trong chế độ máy bay phải vào được scene và chơi tiếp.

Tiến trình ở `user://` cần có schema version, địa phương hiện tại, POI đã khám phá và các thiết lập điều khiển. Dùng ID địa danh/POI ổn định, không dùng tên hiển thị làm khóa. Nếu lưu tọa độ, chỉ phục hồi khi world version và vị trí hợp lệ; nếu không, đặt nhân vật ở spawn an toàn. Không chuyển trực tiếp AsyncStorage của prototype Expo sang save Godot vì hai game có schema và vòng chơi khác nhau.

Ghi ra tệp tạm rồi thay tệp chính hoặc giữ bản sao gần nhất để giảm nguy cơ cắt ngang khi đóng ứng dụng. Kiểm tra lỗi mở/ghi/parse và báo rõ khi không lưu được. Chỉ đặt cờ hoàn thành POI một lần; tương tác lại không nhân thưởng. Lưu sau tương tác/chuyển vùng và khi app vào nền; checkpoint vị trí theo chu kỳ nếu cần, không ghi đĩa mỗi frame. Xóa tiến trình phải xác nhận và chỉ xóa tệp của game.

## Hợp đồng save và batch 0.3

Bản 0.2 lưu tại `user://journey3d.json`, schema `version: 1` gồm `region_id`, `positions` và `visited`. Mỗi vị trí có x/y/z/yaw/pitch; decoder kiểm tra số hữu hạn, biên tọa độ, giới hạn số mục và loại dấu trùng. Tệp hỏng đưa game vào phiên phục hồi với tự lưu bị tắt; chỉ thao tác Lưu rõ ràng mới cho phép thay dữ liệu cũ. Ghi tệp tạm rồi rename giữ tệp chính nếu bước kiểm tra/ghi thất bại.

PO đã chốt batch 0.3; Developer đang triển khai hướng dẫn lần đầu, đích POI chưa ghé gần nhất và tùy chỉnh camera/bóng. Hợp đồng bắt buộc khi thêm dữ liệu:

- Save phiên bản 1 cũ phải giữ nguyên địa phương, vị trí và dấu. Trường tùy chọn thiếu được bổ sung mặc định; không coi thiếu trường mới là save hỏng.
- Nếu tăng schema version, decoder phải chấp nhận/migrate version 1 trước khi kiểm tra mới; version tương lai chưa hỗ trợ vẫn bị từ chối và không tự ghi đè.
- Kiểm tra kiểu, miền giá trị, NaN/Infinity và giới hạn sensitivity; giá trị settings hỏng không nên làm mất phần hành trình còn hợp lệ. PO chốt shadow mặc định bật; sensitivity chỉ nhận ba preset `0.6`, `1.0`, `1.4`, mặc định `1.0`. Trường tùy chọn sai kiểu/giá trị dùng mặc định thay vì từ chối toàn bộ hành trình hợp lệ.
- Áp dụng settings ngay lên scene hiện tại và khi đổi cảnh/tải lại, không chỉ ghi giá trị vào JSON. Sensitivity phải dùng cho cả kéo cảm ứng và chuột theo thiết kế; bật/tắt bóng cần tác động ánh sáng thực.
- Hướng dẫn/menu phải hủy touch đang giữ và chặn di chuyển/camera phía sau; hoàn tất hướng dẫn lưu đúng một lần. PO chốt save 0.2 thiếu trường hướng dẫn sẽ hiện lần đầu từ bước 0; phân biệt trạng thái bỏ qua với hoàn tất. Xem lại hướng dẫn chỉ đặt lại trạng thái hướng dẫn, không reset hành trình.
- Chỉ dẫn POI dùng ID cục bộ và khoảng cách trong scene minh họa, không phải khoảng cách địa lý thực. Chọn POI chưa ghé gần nhất theo mặt phẳng XZ, hướng chỉ dẫn tương đối camera; chuyển mục tiêu sau khi ghé và khi chuyển vùng. Đã ghé hết trả mục tiêu rỗng kèm thông báo tiến độ địa phương, không tự đánh dấu POI hoặc teleport khi điều hướng.

`main.gd` hiện điều phối vòng đời scene, nhập liệu, UI và autosave; `world.gd`, `player.gd`, `touch_controls.gd`, `save_store.gd` đã là các ranh giới riêng. Batch 0.3 bổ sung `onboarding.gd` (state machine tiến trình hướng dẫn), `navigation.gd` (helper chọn POI và hướng tương đối) và `preferences.gd` (mặc định, chuẩn hóa và áp dụng tùy chỉnh). Save vẫn dùng version 1, decoder bổ sung hai nhánh tùy chọn `onboarding` và `preferences` sau khi xác thực dữ liệu hành trình cũ. Với batch nhỏ, giữ orchestration tại main và tách logic chọn mục tiêu/chuẩn hóa settings nếu cần kiểm thử thuần; tránh tái cấu trúc toàn bộ UI cùng lúc với migration. Review mã 0.3 xác nhận các ranh giới helper và tích hợp main đã có: settings áp dụng ngay và sau chuyển vùng; mục tiêu tính theo XZ mỗi frame; player phát tín hiệu quãng đường di chuyển vật lý và góc camera thực tế cho hướng dẫn. Bước di chuyển chỉ đếm khi có input, chạm đất và quãng đường nằm trong giới hạn tốc độ; teleport không được tính. Hoàn tất/bỏ qua/xem lại hướng dẫn lưu ngay; tiến độ một phần dùng checkpoint tự lưu 5 giây và lúc ứng dụng vào nền. Tất cả modal dùng một guard chung để chặn camera và di chuyển. Review mã không thay cho báo cáo kiểm thử và nghiệm thu 0.3.

## Chunk và ngân sách mobile

Không dựng toàn bộ Việt Nam trong một scene luôn hoạt động. Giai đoạn đầu dùng một khu tham quan hoạt động tại một thời điểm, chuyển qua màn bản đồ. Khi khu lớn hơn, chia chunk theo khoảng cách; nạp trước vùng sắp tới bằng resource loader, giải phóng vùng cũ và giữ save ngoài scene. Nội dung cục bộ có thể được nạp dần mà vẫn hoàn toàn offline.

Low-poly, material dùng lại, ít transparency, ánh sáng đơn giản và collision primitive là mặc định. Không tạo collision concave động cho nhân vật. Hạn chế bóng thời gian thực trên thiết bị yếu; thử LOD, visibility range hoặc MultiMesh cho cây/cảnh vật lặp lại. Đo frame time, RAM và kích thước gói trên thiết bị; mục tiêu ban đầu 30 FPS ổn định trên máy mục tiêu, không công bố đạt trước profiling. Danh sách 34 địa phương không cho phép nạp 34 cảnh cùng lúc.

## Build Android và iOS

Android sử dụng engine/templates cùng phiên bản. Ưu tiên export APK debug bằng templates tiêu chuẩn cho vòng thử đầu, tránh Android Gradle custom build khi chưa cần plugin. Cấu hình SDK/JDK trong editor settings hoặc script cục bộ được tài liệu hóa, preset package ID riêng với prototype Expo nếu cần cài song song. Artifact 3D phải có tên khác APK v0.1 để không nhầm hai trò chơi. Kiểm tra manifest, ABI, chữ ký, tệp game nhúng và checksum; kiểm tra gói không thay thế kiểm tra chạy trên thiết bị.

Build APK hiện dùng script ở gốc repository: `./scripts/build-3d-android-apk.sh`. Script export release không Gradle, align 16 KiB và ký bằng khóa thử nghiệm nằm ngoài repository. Artifact có phiên bản riêng và không phải bản phát hành cửa hàng. Ví dụ import dưới đây không thay cho chạy build script hoặc kiểm tra thiết bị:

```bash
cd /workspace/TravelVietnamese/game3d
/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64 --headless --editor --import
/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64 --headless --path . --export-debug Android ../artifacts/doc-mien-viet-3d-debug.apk
```

iOS xuất project Xcode trên công cụ hỗ trợ rồi build/ký trên macOS. Phải chạy kiểm tra touch, safe area, renderer và lưu dữ liệu trên iPhone/iPad riêng. APK chạy được không chứng minh iOS chạy được. Không cam kết IPA hay phát hành cửa hàng khi chưa có toolchain, quyền ký và kiểm thử tương ứng.

## Kiểm chứng kiến trúc

1. Import/headless parse không có lỗi GDScript; chạy scene nhiều frame, xác nhận các node thiết yếu được dựng.
2. Kiểm tra desktop có ảnh thực: nhân vật di chuyển có va chạm, camera theo và tránh vật cản, POI chỉ tương tác khi ở gần.
3. Kiểm tra đa chạm trên Android: vừa giữ joystick vừa kéo camera, thả ngón/menu/background không để nhân vật tự chạy.
4. Save/reload: khám phá POI, đóng mở lại; vị trí hợp lệ hoặc spawn an toàn, nội dung đã khám phá giữ nguyên. Save hỏng có đường khôi phục rõ.
5. Kiểm tra registry khác scene coverage; không quảng bá danh sách tên thành thế giới đã hoàn thiện.
6. Build APK và thử mở lạnh offline trên thiết bị; đo FPS/RAM. iOS có báo cáo kiểm thử riêng khi có máy hỗ trợ.

Các mục là điều kiện cần thực thi, chưa phải tuyên bố đã đạt. Hạn chế, lỗi và kết quả đo phải được ghi vào báo cáo validation của build cụ thể.
