# Kiểm thử bản game 3D native

Phạm vi: `game3d/`, Godot 4, nhân vật điều khiển trong cảnh 3D, bản chọn địa điểm, điểm tham quan tương tác và lưu tiến trình offline. Bản Expo cũ được giữ riêng; kết quả của bản Expo không chứng minh bản Godot đạt yêu cầu.

## Nguyên tắc báo cáo

- Registry phải chứa đúng 34 tỉnh/thành trong bộ dữ liệu hành chính được chọn, có ID duy nhất, và các mục đảo/quần đảo mang tên trong dataset.
- Mỗi mục registry phải vào được cảnh chi tiết 3D; một chấm trên bản đồ hoặc chỉ có thông tin văn bản không đạt điều kiện này.
- Đảo/quần đảo trong dataset là tập con được nêu tên, **không phải tuyên bố đã bao phủ tất cả đảo Việt Nam**. Kiểm thử đếm hoặc kiểm tra schema không chứng minh tính đầy đủ ngoài đời.
- Cảnh dựng thủ tục là minh họa, **không phải bản sao địa hình, đường biên hoặc di tích chính xác**. Phân biệt cảnh mẫu được chăm chút với cảnh minh họa dùng lại quy tắc dựng.
- Headless có thể xác minh scene tree, physics, input được mô phỏng, chuyển cảnh và file save. Nó không chứng minh cảm giác điều khiển, bố cục chạm, FPS hoặc hình ảnh trên điện thoại.

## Tự động trong Godot headless

Suite thuộc `game3d/tests/`, dùng exit code khác 0 nếu bất kỳ điều kiện nào thất bại. Mỗi test phải in tên và kết quả; không coi việc editor mở project thành công là test gameplay.

| Nhóm | Bằng chứng cần có |
| --- | --- |
| Registry | 34 mục tỉnh/thành; ID không trùng; tên, type, vùng, tọa độ, scene style, detail level và source ID hợp lệ; có mục đảo/quần đảo |
| Bao phủ cảnh | Đi qua từng ID thật trong registry qua API chuyển địa điểm; cảnh chứa hình học 3D, mặt đất có collision và nhân vật; đảo cũng dùng flow này |
| Di chuyển | Nhân vật có CharacterBody3D/collider; đầu vào di chuyển thay đổi vị trí sau physics ticks; không rơi qua nền hoặc xuyên vật cản thử nghiệm |
| Camera/chạm | Joystick được giới hạn biên và trả về 0 khi thả; pointer riêng cho joystick/camera; đổi góc nhìn không tạo vector không hợp lệ |
| POI | Điểm tham quan có vị trí; tương tác ngoài tầm không ghi nhận; tới gần và tương tác cập nhật đúng tiến trình, không ghi trùng |
| Chuyển địa điểm | ID không hợp lệ được từ chối an toàn; chuyển lặp không tích lũy cảnh/nhân vật; nhân vật được đặt ở vị trí spawn hợp lệ |
| Save | Round-trip vùng hiện tại, POI đã thăm và trạng thái cần thiết; JSON hỏng, schema/version lạ và ID ngoài registry không làm crash hoặc phá save hợp lệ |

Lệnh đã chạy cho điều khiển và physics:

```bash
cd /workspace/TravelVietnamese
XDG_DATA_HOME=/tmp/travel-godot-test-data \
XDG_CONFIG_HOME=/tmp/travel-godot-test-config \
XDG_CACHE_HOME=/tmp/travel-godot-test-cache \
godot --headless --path game3d --script tests/test_controls_player.gd
```

Godot 4.6.3: **21 điều kiện đạt, 0 lỗi**. Kiểm tra dùng physics ticks thật với sàn và tường collision, không chỉ kiểm tra tên class. Hai ngón chạm được mô phỏng độc lập qua InputEventScreenTouch/InputEventScreenDrag. Thư mục XDG tách biệt giữ dữ liệu test khỏi save người chơi và tránh ghi vào home chỉ đọc trong sandbox.

Hai suite bổ sung dùng cùng cách đặt biến XDG và lần lượt đổi đối số `--script`:

```bash
# Từ thư mục /workspace/TravelVietnamese, sau khi Godot import project để đăng ký class:
XDG_DATA_HOME=/tmp/travel-godot-test-data XDG_CONFIG_HOME=/tmp/travel-godot-test-config XDG_CACHE_HOME=/tmp/travel-godot-test-cache \
  godot --headless --path game3d --script tests/test_registry_worlds.gd
XDG_DATA_HOME=/tmp/travel-godot-integration-data XDG_CONFIG_HOME=/tmp/travel-godot-test-config XDG_CACHE_HOME=/tmp/travel-godot-test-cache \
  godot --headless --path game3d --script tests/test_save_transitions.gd
```

| Suite thực thi | Kết quả cuối | Nội dung đã xác minh |
| --- | --- | --- |
| `test_controls_player.gd` | 21 điều kiện đạt, 0 lỗi | Hai pointer, joystick/camera, collider, movement, floor/wall collision, giới hạn camera, hồi phục sau rơi |
| `test_registry_worlds.gd` | 502 điều kiện đạt, 0 lỗi | Đủ mã 34 tỉnh/thành, 13 vùng đảo được chọn, schema/ID/parent, từng mục dựng cảnh 3D có terrain/collider/player, spawn trên mặt đất, POI gần/xa, biên đảo |
| `test_save_transitions.gd` | 135 điều kiện đạt, 0 lỗi | Flow thật `enter_region` qua cả 47 mục, chỉ một world active, joystick/camera nối vào nhân vật, menu hủy input, POI ghi một lần, save/restore/restart, từ chối dữ liệu hỏng, bảo toàn save gốc, fallback vùng không còn trong dataset |
| `test_licenses.gd` | 18 điều kiện đạt, 0 lỗi | Giấy phép mở/đóng modal, hủy hai pointer đang giữ, dừng di chuyển, không ghi dấu POI, nội dung read-only có đầy đủ Godot MIT/dataset/third-party và thực sự cuộn được, đóng trả đúng trạng thái menu/gameplay |

Tổng **676 điều kiện kiểm tra đạt, 0 lỗi** trên Godot headless. Đây là số assertion trong bốn suite, không phải 676 kịch bản chơi độc lập. Suite save dùng thư mục XDG riêng, giữ lại và khôi phục file có trước nếu có. Suite giấy phép dùng cùng dạng lệnh với `--script tests/test_licenses.gd` và `XDG_DATA_HOME=/tmp/travel-godot-license-data`.

Lần chạy đầu của suite terrain phát hiện mặt tam giác collision đảo chiều khiến nhân vật không đứng trên sàn; Developer đã sửa thứ tự đỉnh. Kết quả 502/502 phía trên là lần chạy lại sau sửa, xác nhận nhân vật đứng trên terrain của toàn bộ 47 mục.

## Thủ công Android/iOS

Các trường hợp này **chưa chạy** cho đến khi có bằng chứng trực tiếp trên nền tảng tương ứng.

1. Cài bản standalone, bật chế độ máy bay, force-stop và mở lại; vào cảnh tỉnh và cảnh đảo, di chuyển/tương tác không cần server.
2. Dùng hai ngón đồng thời: joystick trái để đi, vùng camera để nhìn; thả từng ngón, kéo ra khỏi vùng, đổi ngón và chuyển nền để kiểm tra không kẹt di chuyển.
3. Chạm UI chọn vùng không đồng thời xoay camera hoặc làm nhân vật bước đi; các nút không nằm dưới thanh hệ thống/notch.
4. Tiếp cận POI, kiểm tra nhãn/tầm tương tác; rời xa thì không còn tương tác; mở lại ứng dụng vẫn giữ dấu đã thăm.
5. Vào tất cả 34 mục tỉnh/thành và toàn bộ mục đảo của dataset; kiểm tra mỗi mục có cảnh chơi 3D, không chỉ chuyển tên cùng màn hình thông tin.
6. Kiểm tra collision khi đi thẳng vào tường, góc công trình, mép bờ và vùng nước; không rơi vô hạn hoặc mắc kẹt không có cách trở lại.
7. Chạy liên tiếp ít nhất 15 phút, chuyển nhiều địa điểm, kiểm tra nóng máy, RAM, FPS và crash trên thiết bị Android cấu hình trung bình. Kiểm tra iOS riêng khi có bản ký phù hợp.
8. Kiểm tra chữ tiếng Việt, cỡ chữ lớn, vùng chạm và thông báo lỗi save. Không mất save âm thầm khi phiên bản/dữ liệu không hợp lệ.

## Kết quả hiện tại

Đã xác minh điều khiển/physics, toàn bộ registry, POI, chuyển địa điểm và save ở mức headless như trên. Chưa xác nhận build/cài đặt hay chơi offline trên Android/iOS của bản Godot. Tính đầy đủ của tất cả đảo Việt Nam, tính chính xác địa lý và chất lượng đồ họa/hiệu năng trên thiết bị không nằm trong kết quả đạt này.

## Artifact Android 0.2.0 và smoke test đồ họa

Kết quả do agent chính thực thi và chuyển cho QA ghi nhận:

- APK cuối: `artifacts/doc-mien-viet-3d-0.2.0.apk`, **51.634.285 byte**.
- SHA-256: `fd428fa672e6dc62b5c186afa8ca01758fe957fa86b616081f73bd4e355ae184`.
- `scripts/verify-3d-apk.py` và đối chiếu checksum đạt: chữ ký APK v2/v3 hợp lệ, zipalign 16 KiB đạt; gói chứa Godot bytecode, giấy phép MIT và JSON của 47 mục (34 tỉnh/thành, 13 vùng đảo được chọn).
- Manifest APK: package `com.travelvietnamese.docmienviet3d`, min SDK 24, target SDK 36, hỗ trợ arm64-v8a và armeabi-v7a; không yêu cầu quyền `INTERNET`.
- Smoke test đồ họa desktop Mesa ở 1280×720 đạt: cảnh Hà Nội, menu 47 điểm đến, hộp giấy phép, cảnh đảo và POI, cảnh cao nguyên; nhân vật di chuyển hơn 1 m. Ảnh nằm trong `docs/screenshots3d/`.

Đã chạy lại suite save/transitions sau khi thêm hộp giấy phép: **135/135 đạt**. Không chạy lại suite 502 kiểm tra world vì thay đổi giấy phép không sửa world; suite giấy phép bổ sung 18/18 đạt.

Đây là bằng chứng build artifact, kiểm tra tĩnh APK và chạy đồ họa desktop. **Chưa cài APK, chạy chế độ máy bay hoặc đo hiệu năng trên điện thoại Android thực; chưa xác minh build/chạy iOS.** Không suy kết quả desktop hoặc manifest thành kết quả kiểm thử thiết bị.
