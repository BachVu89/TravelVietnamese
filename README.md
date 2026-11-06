# Dọc miền Việt 3D

Hướng sản phẩm hiện tại là **tự điều khiển nhân vật tham quan Việt Nam trong không gian 3D**, offline trên Android/iOS. Bản câu đố Expo 0.1 được giữ lại để tham khảo, không còn là gameplay chính.

Bản 0.3 đã triển khai ba yêu cầu đầu của Product Owner: hướng dẫn bằng thao tác thật, chỉ hướng POI chưa ghé và tùy chỉnh camera/bóng đổ. Xem [kết quả xác minh 0.3](docs/VALIDATION_0.3.md), [nghiên cứu PO](docs/market/RESEARCH.md), [backlog](docs/PRODUCT_BACKLOG.md) và [thành viên/quy trình team](docs/TEAM.md).

## Bản nền tảng 3D

Dự án Godot 4.6.3 ở `game3d/`, dùng Compatibility renderer và nội dung đóng gói. Có đi bộ, xoay camera, va chạm, tương tác khi ở gần điểm tham quan và lưu tiến trình local. Các cảnh tạo theo quy tắc là cảnh minh họa; chưa số hóa địa hình hoặc toàn bộ tỉnh ngoài thực tế.

Danh mục hiện có **34 tỉnh/thành và 13 vùng đảo/đặc khu**, lấy từ bộ dữ liệu cộng đồng có nguồn và giấy phép MIT. Mọi mục có đường vào khu tham quan 3D. **13 vùng đảo không phải toàn bộ đảo có tên của Việt Nam**; chưa có dữ liệu mọi đảo thành phần, đường bờ, độ cao và nội dung đặc trưng đầy đủ. Xem [phạm vi địa lý và kế hoạch bổ sung](docs/GEOGRAPHIC_SCOPE.md).

## Mở dự án và điều khiển

Mở `game3d/project.godot` trong Godot 4.6.3 và chạy scene chính, hoặc:

```sh
/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64 --path /workspace/TravelVietnamese/game3d
```

Trên mobile dùng joystick bên trái để đi và kéo vùng bên phải để xoay camera. Trên máy tính dùng WASD/phím mũi tên; thao tác camera và tương tác được hướng dẫn trong game. Đến gần cột mốc để mở nội dung tham quan. Đổi địa điểm qua danh mục có tìm kiếm; các đảo cũng vào được cảnh riêng.

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
