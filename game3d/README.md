# Dọc miền Việt 3D · bản mẫu 0.4

Game tham quan offline bằng Godot 4.6.3 Compatibility renderer, tách biệt bản Expo/câu đố cũ ở thư mục gốc. Chạy `project.godot` hoặc scene `scenes/main.tscn`.

## Chơi

**Tuyến đèo mới:** Đổi địa điểm → LÁI XE TRÊN ĐÈO MÂY. Touch dùng joystick để lái, GA và PHANH; bàn phím dùng A/D, W/S. Vào vịnh dừng và phanh trước khi xuống xe bằng nút HUD/E; đi bộ tới POI, bấm Khám phá/F, rồi đến gần xe để lên lại. Về điểm dừng phục hồi checkpoint đã đi qua. Tuyến minh họa không phải dữ liệu khảo sát; xem `docs/VALIDATION_0.4.md` ở repository gốc.

- Đi bộ: joystick bên trái; trên máy tính dùng WASD/phím mũi tên.
- Ngắm cảnh: kéo phía phải; trên máy tính giữ chuột phải và kéo.
- Đi gần cột mốc vàng rồi bấm **Khám phá** để xem nội dung và ghi dấu.
- **Đổi địa điểm** mở danh mục. Cả 47 mục (34 tỉnh/thành và 13 vùng đảo) đều vào được khu 3D có địa hình, va chạm và 3 điểm tương tác.
- **Lưu** lưu vị trí, hướng nhìn và dấu khám phá trên thiết bị. Tự lưu mỗi 5 giây và khi chuyển cảnh/tạm dừng ứng dụng. **Về lối vào** đưa nhân vật về vị trí an toàn.

## Bản 0.3: làm quen và tìm điểm tham quan

Lần đầu vào, hướng dẫn lần lượt yêu cầu đi bộ thực tế 2 m trong cảnh, xoay camera ít nhất 0.25 radian bằng thao tác nhìn, rồi tương tác với một điểm tham quan ở gần. Có thể **Bỏ qua** hoặc mở **Đổi địa điểm → Xem lại hướng dẫn điều khiển**. Bỏ qua được lưu riêng với hoàn thành; xem lại không xóa vị trí hoặc dấu khám phá. Đổi bước và trạng thái được lưu ngay, phần tiến độ trong bước theo lịch tự lưu.

HUD chỉ điểm chưa khám phá gần nhất, khoảng cách thẳng xấp xỉ theo mét trong mô hình và hướng trước/trái/phải/sau so với camera. Đây không phải chỉ đường theo địa lý thực hoặc tìm đường tránh vật cản. Hoàn thành 3 dấu chỉ có nghĩa đã khám phá 3 điểm trong cảnh mẫu.

Trong **Đổi địa điểm → Cài đặt**, có thể bật/tắt bóng đổ và chọn độ nhạy camera Thấp 0.6× / Chuẩn 1× / Cao 1.4×. Thay đổi áp dụng ngay và giữ qua chuyển cảnh, mở lại ứng dụng. Bản lưu 0.2 vẫn dùng được: giữ nguyên vị trí/dấu, bổ sung hướng dẫn mới và mặc định bóng bật/camera 1×. APK 0.3 dùng cùng application ID và khóa thử nghiệm của 0.2 để cài cập nhật; không cần xóa dữ liệu.

Khu Hà Nội có hồ, tháp gợi Tháp Rùa, dãy phố và sân kiến trúc minh họa. Mỗi vùng đảo có cảnh sinh thủ tục riêng theo mã địa danh: địa hình nổi, bờ cát, cây và các công trình minh họa. Các khu còn lại sinh thủ tục theo nhóm đô thị, ven biển hoặc cao nguyên.

**Đây chưa phải bản số hóa thực địa**: không dùng đường bờ, tọa độ, tỷ lệ hoặc công trình để dẫn đường hay suy ra vị trí thực. Danh mục 13 vùng đảo không phải danh sách đầy đủ mọi đảo Việt Nam. Xem `data/geography/sources.json` và các tài liệu phạm vi trong `docs/` ở repository gốc.

## Chạy và kiểm tra

```bash
cd /workspace/TravelVietnamese
XDG_DATA_HOME=/workspace/godot-data \
XDG_CONFIG_HOME=/workspace/godot-config \
XDG_CACHE_HOME=/workspace/godot-cache \
/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64 --path game3d
```

Tài nguyên game và danh mục địa danh được đóng gói. Không có backend, tài khoản hoặc yêu cầu Internet trong game. Tệp lưu là `user://journey3d.json` trong sandbox ứng dụng; xóa dữ liệu ứng dụng sẽ mất tiến trình.

## Android APK

```bash
./scripts/build-3d-android-apk.sh
```

Script ở repository gốc dùng SDK/JDK có sẵn, template Godot chính thức đã xác minh SHA512, export release không Gradle, align 16 KiB và ký khóa thử nghiệm local ngoài repository. Không in hoặc đưa khóa ký vào mã nguồn. Đầu ra: `artifacts/doc-mien-viet-3d-0.3.0.apk`; hỗ trợ arm64-v8a và armeabi-v7a. Đây là APK thử nghiệm, không phải bản phát hành Google Play.

Templates cần ở `$XDG_DATA_HOME/godot/export_templates/4.6.3.stable/`: `android_release.apk`, `android_debug.apk` và `ios.zip`. Lấy từ release Godot chính thức, đối chiếu `SHA512-SUMS.txt` trước khi dùng.

## iOS

Cùng mã Godot và điều khiển cảm ứng dùng được cho iOS. `export_presets.cfg` có preset iOS và bundle identifier riêng. Việc tạo bản cài iOS đã ký cần macOS/Xcode, Apple team và provisioning hợp lệ; repository không chứa thông tin ký. Không xem preset là bằng chứng đã chạy trên iPhone. Bản mẫu hiện được xác minh bằng Godot desktop/headless và kiểm tra tĩnh APK; kiểm thử thiết bị Android/iOS thực là bước riêng.


Trong **Đổi địa điểm → Giấy phép & nguồn dữ liệu**, người chơi có thể đọc giấy phép Godot, thông báo bản quyền các thư viện tích hợp và giấy phép MIT của dữ liệu địa danh hoàn toàn offline.

Lần thử export iOS trong Linux hiện dừng ở kiểm tra `App Store Team ID not specified`; chưa tạo Xcode project hoặc IPA đã ký.
