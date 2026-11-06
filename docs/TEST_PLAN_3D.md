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

## Batch 0.3 — điều kiện nghiệm thu bổ sung

Các kết quả 0.2 ở trên được giữ làm mốc. Batch mới chưa được coi là đạt cho đến khi các kiểm tra tương ứng thực thi.

| Mã PO | Điều kiện cần kiểm chứng |
| --- | --- |
| PO-01 | Hướng dẫn theo thứ tự: di chuyển phẳng ít nhất 2 m bằng đầu vào liên tục, không tính teleport; sau đó tích lũy ít nhất 0,25 rad đầu vào xoay camera trong bước nhìn; sau đó tương tác POI qua proximity guard. Không tính hành động trước bước tương ứng. POI đã ghé vẫn tính cho lượt hướng dẫn chơi lại. |
| PO-01 lưu trạng thái | Skip phải phân biệt completed; replay về bước đầu và giữ nguyên vị trí/dấu khám phá. Khôi phục bước/status sau mở lại; save 0.2 thiếu trường mới bắt đầu hướng dẫn ở bước đầu, giữ toàn bộ dữ liệu cũ. |
| PO-02 | Chọn POI chưa thăm gần nhất theo XZ, cập nhật khi nhân vật/camera/tập visited thay đổi; khoảng cách dùng đơn vị cảnh minh họa, hướng tương đối camera; không hướng tới POI đã thăm. Khi hết POI hiển thị hoàn thành khám phá cục bộ, không khẳng định hoàn thành toàn bộ tỉnh. |
| PO-03 | Bóng mặc định bật; độ nhạy camera chọn 0,6 / 1 / 1,4, mặc định 1; áp dụng ngay, giữ qua đổi cảnh và khởi động lại. Settings không hợp lệ đưa về giá trị an toàn, giữ tiến trình cốt lõi. |
| Regression | Menu/dialog dừng điều khiển và hủy pointer; không thêm analytics mạng. App ID và khóa ký được giữ để hỗ trợ cập nhật APK; phải xác minh riêng artifact cuối, không suy từ source. |

Fixture `game3d/tests/fixtures/progress-v0.2.json` đóng băng schema save 0.2: vùng đảo đang chơi, hai vị trí/camera và hai dấu POI. Kiểm tra migration phải dùng fixture này thay vì tạo save cũ từ hàm default mới.

### Kết quả thực thi batch 0.3

Kết quả cuối sau sửa kiểu `checkpoint`, lưu ngay khi đổi bước và sửa chiều cao dialog settings: **257 assertion đạt, 0 lỗi** trong sáu suite; mỗi lệnh có exit code 0, log không có `ERROR` hoặc `FAIL`. Trong đó 83 assertion mới cho batch 0.3, 174 assertion regression liên quan được chạy lại. Sau thay đổi nhãn settings chỉ chạy lại suite integration chịu ảnh hưởng; các suite khác giữ kết quả chạy trước đó của batch này. Không chạy lại 502 assertion registry/world vì batch này không thay đổi world generator; kết quả đó vẫn là bằng chứng của mốc 0.2, không được cộng thành số test vừa chạy trên batch 0.3.

| Suite | Assertion đạt | Bằng chứng chính |
| --- | --- | --- |
| `test_batch03_rules.gd` | 36 | Thứ tự/ngưỡng tutorial, skip khác complete, replay; nearest unvisited XZ và hướng theo camera; preset/default settings; golden fixture 0.2 và optional fields hỏng không mất core progress |
| `test_player_tutorial.gd` | 9 | Physics đi bộ thực đủ 2 m và camera input thực; không tính gravity/teleport/đẩy vào tường; sensitivity 0,6 và 1,4 áp dụng vào góc quay thực |
| `test_batch03_integration.gd` | 38 | Main migrate file 0.2 giữ vùng/vị trí/góc nhìn/visited; input thực chuyển bước; checkpoint 0→1 và 1→2 ghi file ngay trước chu kỳ autosave 5 giây; POI ngoài tầm không hoàn tất; POI đã ghé vẫn hoàn tất replay không nhân dấu; completed/skip/partial step khôi phục; replay giữ core; settings live/đổi cảnh/restart và dialog/nút Trở lại nằm trong viewport 1280×720; HUD bỏ POI đã ghé và hoàn thành cục bộ 3/3 |
| `test_controls_player.gd` | 21 | Regression chạm/camera và collision |
| `test_save_transitions.gd` | 135 | Regression 47 chuyển cảnh, file save, dữ liệu hỏng và không ghi đè save lỗi |
| `test_licenses.gd` | 18 | Regression dialog modal, hủy pointer, cuộn giấy phép, không tạo dấu |

Lệnh chạy lại toàn bộ phạm vi trên từ thư mục repository:

```bash
set -e
for test_suite in test_batch03_rules test_player_tutorial test_batch03_integration test_controls_player test_save_transitions test_licenses; do
  XDG_DATA_HOME="/tmp/travel-qa03-final/$test_suite/data" \
  XDG_CONFIG_HOME="/tmp/travel-qa03-final/$test_suite/config" \
  XDG_CACHE_HOME="/tmp/travel-qa03-final/$test_suite/cache" \
    godot --headless --path game3d --script "tests/$test_suite.gd" \
    > "/tmp/travel-$test_suite-03-final.log" 2>&1
  tail -1 "/tmp/travel-$test_suite-03-final.log"
done
```

Tiến trình tutorial và các bộ đếm phục vụ điều kiện chơi được lưu trong JSON cục bộ; rà soát scripts không thấy HTTP client, analytics endpoint hoặc gửi sự kiện mạng. Kết luận này là kiểm tra source, chưa thay thế xác minh quyền mạng của APK 0.3 cuối. Không build APK song song trong quá trình QA.

Root phát hiện lỗi UI thực: nhãn autowrap làm dialog settings cao hơn màn hình khi tính minimum size trước khi có chiều rộng. Sau sửa nhãn hai dòng cố định, integration thêm ba assertion về kích thước dialog, toàn bộ rect trong viewport và nút Trở lại nằm trong vùng client. Lần chạy lại **38/38 đạt**; log `/tmp/travel-test_batch03_integration-03-final.log`. Kiểm tra này dùng viewport 1280×720 headless, không thay cho kiểm tra bố cục các kích cỡ điện thoại.

### Artifact Android 0.3.0 cuối cùng

Agent chính đã chạy xác minh APK 0.3 cuối và chuyển kết quả cho QA ghi nhận:

- APK: `artifacts/doc-mien-viet-3d-0.3.0.apk`, **51.642.944 byte**.
- SHA-256: `99649f3cb829098d8a7cbde8f06604a2320bed98ca3c0ed9df4197a0241eca99`.
- Chữ ký v2/v3 và zipalign 16 KiB đạt; không có quyền `INTERNET`; gói chứa main Godot bytecode, JSON 47 mục và giấy phép.
- Đối chiếu artifact thực: cùng application ID và chứng thư ký với bản 0.2; versionCode tăng từ 2 lên 3. Đây là điều kiện cho cài cập nhật, không phải bằng chứng đã cài cập nhật trên điện thoại.
- Root chạy lại GUI sau sửa nhãn settings: dialog nằm trong viewport và toàn bộ flow PO-03 đạt smoke test desktop.

Checksum và bằng chứng 0.2 phía trên vẫn chỉ thuộc APK 0.2. **Chưa kiểm thử cài cập nhật APK trên điện thoại, giữ save sau nâng cấp ứng dụng thực tế, hiệu năng Android hoặc iOS.** Kiểm thử migration golden fixture và đối chiếu app ID/chữ ký không thay thế các kiểm tra thiết bị này.
