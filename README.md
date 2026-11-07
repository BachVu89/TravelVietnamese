# Dọc miền Việt 3D

Hướng sản phẩm hiện tại là **tự điều khiển nhân vật tham quan Việt Nam trong không gian 3D**, offline trên Android/iOS. Bản câu đố Expo 0.1 được giữ lại để tham khảo, không còn là gameplay chính.

Bản 0.3 đã triển khai ba yêu cầu đầu của Product Owner: hướng dẫn bằng thao tác thật, chỉ hướng POI chưa ghé và tùy chỉnh camera/bóng đổ. Xem [kết quả xác minh 0.3](docs/VALIDATION_0.3.md), [nghiên cứu PO](docs/market/RESEARCH.md), [backlog](docs/PRODUCT_BACKLOG.md) và [thành viên/quy trình team](docs/TEAM.md).

Bản 0.4 bổ sung tuyến đèo mẫu, xe máy, giao thông và hai điểm dừng để xuống đi bộ. Vào **Đổi địa điểm → LÁI XE TRÊN ĐÈO MÂY**. Xem [kết quả 0.4 và giới hạn chất lượng](docs/VALIDATION_0.4.md), [báo cáo BA](docs/STATUS_REPORT.md). Nhánh source đang phát triển là **`codex-work`**; APK phân phối ở **`apk-download`**.

Bản 0.5 cải thiện cây/đá/mặt đường/chiều sâu cảnh, thêm hai mức chi tiết và mục tiêu tuyến. Vào trực tiếp bằng **Chơi đèo mẫu**; [kết quả 0.5](docs/VALIDATION_0.5.md), [ảnh đối chiếu cùng camera](docs/ART_COMPARE_0.5.md). Oppo Find X7 Ultra và iPhone 13 là thiết bị đích được người dùng nêu, chưa phải thiết bị đã kiểm chứng.

## Hướng hiện tại: Unity 6/C#

Người dùng đã chuyển lựa chọn engine sang Unity 6. Source mobile ở [`unity/TravelVietnamese`](unity/README.md), dùng **URP** cho Android/iOS; [`TravelVietnamese-HDRP`](unity/TravelVietnamese-HDRP/README.md) là companion **desktop riêng**. HDRP không phải pipeline phát hành cho hai điện thoại mục tiêu. Có source vòng xe→dừng→đi bộ→hai POI, save offline, input cảm ứng và script dựng scene với ba asset gốc. **Chưa compile/chạy bằng Unity Editor**, chưa có scene sinh từ Editor hoặc APK/IPA Unity. Logic Domain thuần C# đã chạy test .NET riêng; đó không phải kiểm gameplay/graphics Unity.

Xem [migration](docs/UNITY_MIGRATION.md) và [bằng chứng/giới hạn](docs/UNITY_VALIDATION.md). Môi trường thiếu Editor/license, truy cập kênh tải chính thức hiện bị proxy trả CONNECT 403. Tỷ lệ chất lượng “90–95%”, kích thước bộ cài, hiệu năng và plugin thương mại chưa được xác minh. Godot 0.5 vẫn là bản APK chơi được đã giao; UE giữ lại như công việc lịch sử.

### Scenic V3 — cập nhật cảnh Unity đang có

[Hướng dẫn V3](docs/UNITY_SCENIC_V3.md): menu **Update Scene Graphics** hiện gán rừng, xe/người và địa hình có khối vào scene cũ. Xem [asset rừng](docs/art/forest-preview.png) và [xe/người](docs/art/travel-characters-preview.png) được render bằng Blender, không phải Unity. Asset vẫn cách điệu; chưa có nghiệm thu ảnh Unity hoặc hiệu năng mobile.

## Hướng UE5 trước khi chuyển Unity

Theo yêu cầu đồ họa ngày 07/11/2026, team bắt đầu chuyển sang UE5.5+ trong [`unreal/`](unreal/README.md). Đã bổ sung source Character đi bộ/camera và [ba asset gốc từ Blender](docs/art/ORIGINAL_ASSETS.md), kèm [ảnh preview Blender](docs/art/asset-preview.png). Đây là **project nguồn khởi đầu, chưa biên dịch/render/cook bằng UE**, chưa có APK/IPA mới. Môi trường hiện không có Unreal Editor; người dùng cũng chưa có engine/asset sẵn. APK Godot 0.5 vẫn là bản chơi được đã giao trước đó, không phải bản đáp ứng chất lượng mới.

Xem [yêu cầu đồ họa và tiêu chí](docs/GRAPHICS_REQUIREMENTS.md), [kế hoạch chuyển engine](docs/UNREAL_MIGRATION.md), [kiểm chứng hiện tại](docs/UNREAL_VALIDATION.md), [danh sách asset cần bổ sung](docs/art/asset-manifest.json) và [nội dung gốc người dùng cung cấp](docs/inputs/GRAPHICS_BRIEF_2026-11-07.txt). Nanite/Lumen là mục tiêu cấu hình desktop riêng; mobile có pipeline riêng cần kiểm trên thiết bị. Chưa mua/tải gói Fab hoặc asset thương mại và chưa tuyên bố đạt hình ảnh tham chiếu.

## Bản nền tảng 3D

Dự án Godot 4.6.3 ở `game3d/`, dùng Compatibility renderer và nội dung đóng gói. Có đi bộ, xoay camera, va chạm, tương tác khi ở gần điểm tham quan và lưu tiến trình local. Các cảnh tạo theo quy tắc là cảnh minh họa; chưa số hóa địa hình hoặc toàn bộ tỉnh ngoài thực tế.

Danh mục hiện có **34 tỉnh/thành và 13 vùng đảo/đặc khu**, lấy từ bộ dữ liệu cộng đồng có nguồn và giấy phép MIT. Mọi mục có đường vào khu tham quan 3D. **13 vùng đảo không phải toàn bộ đảo có tên của Việt Nam**; chưa có dữ liệu mọi đảo thành phần, đường bờ, độ cao và nội dung đặc trưng đầy đủ. Xem [phạm vi địa lý và kế hoạch bổ sung](docs/GEOGRAPHIC_SCOPE.md).

## Mở dự án và điều khiển

Mở `game3d/project.godot` trong Godot 4.6.3 và chạy scene chính, hoặc:

```sh
/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64 --path /workspace/TravelVietnamese/game3d
```

Trên mobile dùng joystick bên trái để đi và kéo vùng bên phải để xoay camera. Trên máy tính dùng WASD/phím mũi tên; thao tác camera và tương tác được hướng dẫn trong game. Đến gần cột mốc để mở nội dung tham quan. Đổi địa điểm qua danh mục có tìm kiếm; các đảo cũng vào được cảnh riêng.

## Skill cho Codex và Muse

[Bộ 7 Skill của team và cách sử dụng](docs/skills/README.md) nằm trong `.agents/skills/`, bao gồm Product Owner, BA, SA, Designer, Developer, Tester và điều phối. Codex dùng repository skills; Muse có hướng dẫn đọc Markdown trực tiếp, chưa kiểm chứng tích hợp native.

## Tài liệu và kiểm chứng

- [Sản phẩm và tiêu chí nghiệm thu](docs/PRODUCT.md)
- [Kiến trúc Godot và offline](docs/ARCHITECTURE.md)
- [Thiết kế điều khiển và giao diện](docs/DESIGN.md), [định hướng đồ họa](docs/ART_DIRECTION.md)
- [Kế hoạch kiểm thử 3D](docs/TEST_PLAN_3D.md)
- [Bản APK 0.2.0, kết quả xác minh và ảnh 3D](docs/VALIDATION_3D.md)
- Nguồn địa lý: `game3d/data/geography/sources.json` và license đi kèm.

Đây là nền tảng thử nghiệm theo hướng mới, chưa phải bản du lịch toàn quốc đã hoàn thiện. Việc build Android, chạy trên thiết bị và build iOS phải được báo cáo riêng. iOS cần môi trường macOS/Xcode và ký phù hợp khi phân phối.

## Bản cũ

`App.tsx`, `src/`, `android/` và `package.json` thuộc prototype câu đố Expo 0.1. Hướng dẫn cũ được giữ ở [README legacy](docs/legacy/README_QUIZ_PROTOTYPE.md); các kiểm tra Expo không xác nhận chất lượng bản Godot3D.
