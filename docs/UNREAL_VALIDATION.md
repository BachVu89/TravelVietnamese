# UE5 — kết quả kiểm tra và giới hạn xác minh

Đối tượng: source scaffold tại `unreal/TravelVietnamese/`. Bản Godot và APK đã có là sản phẩm khác; kết quả chạy của Godot không chứng minh source UE5 biên dịch hoặc game UE5 hoạt động.

## Khả năng thực thi hiện tại

Đã chạy kiểm tra tên công cụ bằng Python `shutil.which`: `UnrealEditor`, `UnrealEditor-Cmd`, `UnrealBuildTool`, `RunUAT.sh` đều **không có trên PATH**. Không tìm thấy thư mục ứng viên `*Unreal*` hoặc `UE_*` trực tiếp trong `/opt`, `/workspace`, `/usr/local`. `clang++` cũng không có trên PATH; một compiler C++ độc lập dù có sẵn cũng không thay thế Unreal Engine, UHT và hệ thống build của engine.

Chưa có engine/toolchain UE được cung cấp để chạy UHT/UBT, mở editor, compile shader, cook/package hoặc khởi chạy game. Các kiểm tra source/config bên dưới chỉ là static validation, **không phải kết quả compile, cook, gameplay hoặc kiểm thử điện thoại**.

## Phạm vi review

Đã chạy `python3 scripts/validate-unreal-source.py`: **30 structural checks PASS**, exit 0. Kiểm JSON `.uproject`, module/target/source hiện hữu, generated-header ở cuối danh sách include, plugin Python/EditorScriptingUtilities chỉ Editor, plugin procedural mesh, AST hai script Python, map/config renderer mobile, application ID thử riêng và các Markdown link local trong ba tài liệu Unreal. AST không import `unreal` và không thực thi API Editor. Link bên ngoài không được kiểm HTTP.

Đã chạy `python3 scripts/build-unreal.py --engine /opt/UnrealEngine --check-only`: **BLOCKED**, exit 2, thiếu `/opt/UnrealEngine/Engine/Build/Build.version`; không gọi compiler hoặc cook, không tạo APK.

Đọc độc lập C++: component được tạo bằng `CreateDefaultSubobject`, gắn root và giữ bằng `UPROPERTY`; generation xóa section/instance cũ, giới hạn segment 64–512 và cây 0–1500, dùng seed cố định. Tham chiếu mesh là primitive có sẵn trong Engine; không thấy download asset, network client, khóa ký hoặc telemetry trong scaffold. Đây là nhận xét source, không phải xác minh mọi quyền mạng của artifact tương lai.

Phát hiện bay ban đầu thiếu mặt collision đã được dev sửa bằng sections 6/7 có collision. Chỉ xác nhận nhánh source tạo chúng; chưa xác minh floor, winding, asynchronous cooking, guardrail, spawn hoặc clipping trong engine. API C++/Python vẫn cần UHT/UBT và Editor UE5.5 để xác nhận. Các material chỉ là tham số màu/roughness do script sinh; chưa có `.uasset` và không phải photogrammetry.

**Chặn runtime/cook từ checkout hiện tại:** `/Game/Maps/PassPreview` được khai báo nhất quán ở startup/default/cook nhưng `Content/Maps/PassPreview.umap` chưa tồn tại. Phải build editor, chạy `bootstrap_pass.py`, lưu map/material rồi kiểm cook. Source bootstrap có guard map dirty và từ chối ghi đè map đã tồn tại; material generator giữ asset đã có. Những guard này đã đọc source, chưa chạy trong UE. Project chứa source/config/script cần thiết cho bước thử đó, chưa phải game hoặc package tự chạy từ clean checkout.

Scaffold dùng flying `ADefaultPawn`; chưa port motorbike, traffic, touch gameplay, POI, save hay danh mục 47 vùng của Godot. Không có bằng chứng đáp ứng brief đồ họa UE5, offline gameplay Android/iOS hoặc hiệu năng điện thoại. Không có APK Unreal mới.

## Cửa còn chưa chạy

- UHT/UBT trên engine phù hợp với `EngineAssociation` và target project.
- Mở editor, sinh world, kiểm lỗi component/material/collision và xử lý input.
- Cook/package Android và iOS; shader/material compile theo renderer đích.
- Kiểm artifact thực tế: map/material/mesh được đóng gói, chữ ký, application ID và quyền Android.
- Chạy standalone offline, lưu/khôi phục và kiểm input trên thiết bị.
- Chất lượng đồ họa, FPS/frame time/RAM/nhiệt trên Oppo Find X7 Ultra và iPhone 13.

Không gọi scaffold là game UE5 đã chạy hoặc đáp ứng chất lượng hình ảnh trước khi các cửa tương ứng có bằng chứng.
