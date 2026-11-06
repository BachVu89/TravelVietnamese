# Xác minh Dọc miền Việt 3D 0.2.0

## Bản thử nghiệm theo hướng mới

Đã chuyển gameplay sang Godot 4.6.3: nhân vật đi bộ trong cảnh 3D, camera góc nhìn thứ ba, va chạm, joystick/đa chạm, tương tác khi gần POI, chuyển khu và lưu local. Bản Expo câu đố cũ được giữ riêng; kết quả kiểm thử của nó không được dùng thay cho bản 3D.

## Đã kiểm tra

- Bốn suite Godot headless: **676 assertion đạt, 0 lỗi** (21 điều khiển/physics, 502 registry/world, 135 save/transitions và 18 giấy phép/UI). Đây là số điều kiện kiểm tra, không phải 676 kịch bản chơi độc lập.
- Tất cả 47 mục trong dataset vào được cảnh riêng: 34 tỉnh/thành và 13 vùng đảo/đặc khu. Có terrain/collision, nhân vật đứng trên đất, POI gần/xa và chỉ một world hoạt động tại một thời điểm.
- Visual smoke bằng Xorg dummy + Mesa llvmpipe, Compatibility renderer, 1280×720: render Hà Nội, danh mục 47 mục, hộp giấy phép có cuộn, Phú Quốc, POI trên đảo và cảnh cao nguyên. Nhân vật thực di chuyển hơn 1 m trong physics; tương tác POI thành công. Không có lỗi GDScript/runtime trong phiên kiểm tra này. Software renderer không dùng làm bằng chứng FPS trên điện thoại.
- `scripts/build-3d-android-apk.sh`: export release, căn chỉnh 16 KiB, ký khóa thử nghiệm local ngoài repository và xác minh thành công. Engine/templates chính thức cùng phiên bản; archive templates đã kiểm tra SHA512.
- `scripts/verify-3d-apk.py`: ZIP nguyên vẹn, chữ ký v2/v3 hợp lệ, alignment đạt, không debuggable, mã Godot/dữ liệu/giấy phép nhúng, ARM64 và ARM 32-bit. APK không có quyền INTERNET.

## Artifact Android

- File: `artifacts/doc-mien-viet-3d-0.2.0.apk`.
- Dung lượng: 51.634.285 byte, khoảng 51,6 MB.
- App ID: `com.travelvietnamese.docmienviet3d`; version name 0.2.0, code 2.
- Android tối thiểu API 24 (Android 7.0), target API 36; thiết bị cần hỗ trợ đồ họa OpenGL ES 3 cho renderer Compatibility.
- SHA256: `fd428fa672e6dc62b5c186afa8ca01758fe957fa86b616081f73bd4e355ae184`.
- Đây là app cài riêng, tên **Dọc miền Việt 3D**, có thể tồn tại cùng bản câu đố cũ. Tiến trình Expo không được tự chuyển sang Godot.

## Chưa đạt mục tiêu nội dung đầy đủ

47 mục là số khu có thể vào trong prototype, không phải tái hiện toàn bộ lãnh thổ hoặc địa danh. Ngoài khu Hà Nội mẫu, các cảnh chủ yếu sinh thủ tục theo nhóm địa hình và mã địa danh; đảo có địa hình nổi, bờ cát và POI nhưng chưa số hóa đường bờ, độ cao hay công trình thực tế. **13 vùng đảo không phải tất cả đảo có tên của Việt Nam**, cũng không phải 13 đảo đơn. Metadata giữ `all_vietnam_islands_verified=false`.

Còn cần nguồn danh mục đảo thành phần, hình học có giấy phép, kiểm duyệt địa lý và các cảnh/POI đặc trưng. Xem [phạm vi và lộ trình dữ liệu](GEOGRAPHIC_SCOPE.md). Không coi việc có tên trong menu hoặc một scene minh họa là hoàn thành chất lượng tham quan của địa danh.

## Chưa kiểm tra trên thiết bị

Chưa cài/chạy APK này trên điện thoại Android; mở lạnh ở chế độ máy bay, đa chạm trên màn hình thật, safe area, FPS/RAM/nhiệt và độ ổn định dài hạn vẫn chưa xác minh. Chưa có IPA hoặc iOS runtime test; thử export iOS dừng vì thiếu Apple App Store Team ID. Preset iOS chỉ là cấu hình dự kiến, không phải bằng chứng game đã chạy trên iPhone.

## Ảnh từ phiên render thật

- [Hà Nội mẫu](screenshots3d/hanoi.png)
- [Khu đảo minh họa](screenshots3d/island.png)
- [Danh mục khu vực](screenshots3d/catalog.png)
- [Giấy phép đọc offline](screenshots3d/licenses.png)

## Cài và thử nhanh

Mở APK trên điện thoại, cho phép cài từ nguồn đó nếu Android yêu cầu, rồi mở **Dọc miền Việt 3D**. Giữ joystick trái để đi, kéo vùng phải để nhìn, đến gần cột mốc vàng để mở nội dung. Dùng **Đổi địa điểm**, tìm tên tỉnh hoặc vùng đảo rồi vào cảnh. Bật chế độ máy bay, đóng/mở lại để kiểm tra lưu tiến trình trên thiết bị.
