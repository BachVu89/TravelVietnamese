# Unreal Engine — Dọc miền Việt

Dự án mới nằm tại `TravelVietnamese/`, hướng tới **Unreal Engine 5.5** theo yêu cầu chuyển engine. Bản Godot và các APK hiện có ở repository gốc được giữ nguyên để tham khảo; chúng không phải bản build Unreal.

**Trạng thái:** source scaffold chưa được compile, mở trong Unreal Editor, cook hoặc chạy trên Android/iOS. Môi trường hiện không có UE/Xcode. Mesh thủ tục, môi trường và material slots là placeholder; chưa có asset/plugin trả phí được mua hoặc tải.

## Bắt đầu trên máy có UE

1. Cài UE 5.5 và toolchain C++ tương thích qua kênh hợp lệ.
2. Mở `TravelVietnamese/TravelVietnamese.uproject`, tạo/build project files và xử lý mọi lỗi compiler/module trước khi chạy.
3. Tạo/lưu một map trong Editor, thiết lập GameMode/startup map phù hợp, rồi thử Play In Editor. Character đi bộ/camera góc thứ ba mới chỉ có source, chưa chạy UE và chưa thay cho cơ chế lái xe máy.
4. Gán material/asset có quyền sử dụng vào các slots và kiểm tra collision. Giữ profile mobile không phụ thuộc Nanite/Lumen; triển khai LOD, ánh sáng và texture theo ngân sách thiết bị.
5. Cấu hình Android bằng Turnkey của đúng phiên bản UE; iOS cần macOS/Xcode và provisioning phù hợp. Cook/map/package thành công rồi mới thử standalone offline trên điện thoại.

Không xem việc tạo `.uproject`, C++ hoặc config là build thành công. Không đoán rằng SDK/NDK dùng cho Godot đã tương thích UE. Không lưu khóa ký hoặc credential trong repository.

## Phạm vi và bước tiếp theo

Trước tiên hoàn thiện một đoạn đèo mẫu: xe, camera, traffic, dừng/đi bộ/POI, save và bản cài offline. Sau đó thay asset và đo Android/iOS thật; 30 FPS là mục tiêu chưa đo. Danh mục địa danh không đồng nghĩa đã có nội dung Unreal cho mọi tỉnh/đảo. Save Godot cần tính năng import rõ ràng trong tương lai; không tự chuyển tọa độ hoặc đọc sandbox ứng dụng khác.

Xem [kế hoạch chuyển engine](../docs/UNREAL_MIGRATION.md) cho cổng nghiệm thu, khả năng mobile/desktop, PCG bake, licensing và build/cook. Mọi lệnh hoặc quy trình UE cần được kiểm chứng bằng engine thật trước khi coi là hướng dẫn đã thử thành công.

## Lệnh hỗ trợ build

Từ gốc repository, sau khi có UE hợp lệ tại đường dẫn thực:

```bash
python scripts/build-unreal.py --engine /path/to/UE --target editor --check-only
python scripts/build-unreal.py --engine /path/to/UE --target editor
python scripts/build-unreal.py --engine /path/to/UE --target android
```

Script chấp nhận UE 5.5 trở lên trong nhánh UE5; UE 5.4 chưa được entrypoint này hỗ trợ. `--check-only` chỉ kiểm tra metadata engine/project và entrypoint, không xác minh SDK, module, plugin, material hoặc thiết bị; target Android chỉ kiểm thêm file map có tồn tại, không kiểm nội dung map. Android chạy AutomationTool với Development/ASTC và archive mặc định vào `artifacts/unreal-android`; cần startup map và cấu hình cook đã được xác minh trước. Editor target là `TravelVietnameseEditor`.

Kiểm tra khi chưa có engine trả exit code 2 với thông báo `BLOCKED`; không chạy compiler/cook và không tạo APK mới. Chủ sản phẩm xác nhận hiện chưa có engine, asset hoặc máy UE để thực hiện các bước này. Nội dung yêu cầu hình ảnh gốc được lưu tại [GRAPHICS_BRIEF_2026-11-07.txt](../docs/inputs/GRAPHICS_BRIEF_2026-11-07.txt).

## Source hiện có

- `TravelVietnamese/Source/TravelVietnamese/TravelPassEnvironment.*`: `ATravelPassEnvironment`, spline `Route`, mặt đường procedural và HISM cho rào/cây. `Regenerate()` gọi trong Editor; `RoutePosition(DistanceCm, LateralCm)` và `RouteLengthCm()` dùng **centimet**, không phải tọa độ GIS.
- `TravelPassGameMode.*` chọn `ATravelExplorerCharacter`: source đi bộ bằng capsule/CharacterMovement, camera góc thứ ba, WASD/mouse, nhảy, trace kiểm tra và reset spawn đầu tuyến. Spawn dùng route 500 cm qua actor transform; chưa chạy để xác minh collision. Joystick mặc định UE được map cho thử nghiệm, chưa có HUD/actions mobile hoàn chỉnh, xe máy, traffic, nội dung POI hoặc save Unreal.
- Targets: `TravelVietnamese` (game) và `TravelVietnameseEditor`; runtime module cùng tên. Plugin Python chỉ cho Editor; PCG được bật nhưng chưa có graph PCG hoặc chứng minh cook.
- Config tắt Nanite/Lumen/ray tracing, chọn mobile forward và app ID thử riêng `com.travelvietnamese.unrealproof`. Đây là cấu hình dự kiến, chưa xác minh thiết bị hoặc chính sách store.

Sau khi C++ compile được, trong Editor chọn **Tools → Execute Python Script**, chạy `TravelVietnamese/Content/Python/bootstrap_pass.py` để tạo `/Game/Maps/PassPreview`. Script từ chối ghi đè map đã tồn tại; tự kiểm tra nguồn map trước khi thay đổi nội dung người dùng. Config startup/game/cook đã trỏ `/Game/Maps/PassPreview`; map chưa có trong source và bắt buộc phải sinh/lưu trước khi chạy hoặc cook. Bootstrap từ chối tiếp tục nếu map hiện tại đang sửa chưa lưu, rồi tạo material PBR tham số và gán vào slots còn trống. Đây không phải scan, normal map, vũng nước hoặc hệ thời tiết. Build wrapper Android sẽ chặn khi thiếu `Content/Maps/PassPreview.umap`.

Material slots gồm road/shoulder/rock/foliage/trunk/marking/metal. Script `Content/Python/create_mobile_materials.py` cung cấp bước tạo material trong Editor; sự tồn tại của script chưa chứng minh đã tạo `.uasset`, gán material hoặc đạt chất lượng hình ảnh. Toàn bộ thao tác editor phía trên vẫn chưa chạy trong môi trường hiện tại.

## Asset gốc và tích hợp cảnh — bước tiếp theo đã chuẩn bị

Ba FBX nguyên gốc kèm `.blend` và báo cáo checksum nằm tại `TravelVietnamese/ArtSource/`: `SM_CliffRock`, `SM_Fern`, `SM_BananaClump`. [Ảnh preview thực](../docs/art/asset-preview.png) được render bằng Blender CPU, **không phải Unreal** và vẫn là hình học prototype. [Hướng dẫn tái tạo/units/materials](../docs/art/ORIGINAL_ASSETS.md).

Bootstrap gọi `import_original_pass_assets.py` để nhập ba FBX vào `/Game/TravelVietnamese/Original`, gán slots còn trống và lưu hard references trong map. Import giữ asset sẵn có; chỉ bật two-sided cho material lá vừa nhập. Các HISM đá/dương xỉ/chuối trang trí có seed riêng, giới hạn số lượng và không collision; không dùng chúng để thay collision đường. Source dùng cooking collision đồng bộ cho mesh thử nhỏ trước spawn Character; chi phí startup và scale phải đo trong UE.

Các bước này mới được kiểm source/AST và file xuất qua Blender. Chưa chạy importer/Python API trong UE, chưa có `.umap`/`.uasset` đã cook, gameplay hoặc FPS trên thiết bị. Quy trình build hiện vẫn bị chặn vì thiếu engine.
