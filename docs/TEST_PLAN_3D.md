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

## Batch 0.4 — PO-10, vòng lái → dừng → tham quan

Kế hoạch bổ sung, chưa coi là kết quả đã đạt. Cảnh đường đèo procedural là một demo riêng, không thêm vào số 34 tỉnh/thành và 13 vùng đảo trong registry; không tuyên bố quãng đường/GIS thực địa.

| Nhóm kiểm tra | Bằng chứng bắt buộc |
| --- | --- |
| Tuyến | Centerline liên tục dài 700–800 đơn vị scene, mục tiêu 750; có thay đổi hướng/cao độ; đường và mép chắn có collider thực |
| Riding physics | Input ga làm tăng tốc; thả ga không tăng tốc; phanh từ tốc độ chạy giảm tới dừng; tốc độ hữu hạn; input lái đổi hướng/vị trí; không chìm/xuyên nền hoặc xuyên mép chắn |
| Traffic | Ít nhất hai xe có collider; cùng seed và số bước mô phỏng cho cùng vị trí trong sai số ghi rõ; va chạm thực chặn/giảm chuyển động xe người chơi |
| Điểm dừng | Hai điểm tên/nội dung khác nhau; ngoài bán kính hoặc tốc độ >0,5 từ chối tương tác; đi qua không tự đóng dấu; ở gần và dừng mới ghi dấu một lần |
| Chế độ | Đỗ hợp lệ → xuống xe đi bộ → tương tác POI → lên cùng xe tiếp tục; không nhân xe, không mất dấu, không cần đổi scene thủ công |
| Touch/modal | Ga+lái và phanh+lái có thể giữ cùng lúc; thả đúng pointer; mở modal/mất focus hủy input, đóng lại không tự ga; camera có giới hạn hợp lệ |
| Save | Schema v1 thêm road state tùy chọn với validation riêng cho tuyến dài, không nới validation vị trí cũ ±41; checkpoint lỗi chỉ chuẩn hóa phần mới; restart về trạng thái an toàn; dấu điểm dừng giữ nguyên |
| Legacy | Golden fixtures 0.2 và 0.3 giữ region/positions/visited, onboarding và preferences cũ khi không có road state; không nhập demo vào registry địa lý |

Fixture mới `game3d/tests/fixtures/progress-v0.3.json` đóng băng save 0.3 đã skip tutorial và tùy chọn shadows off/sensitivity 1,4. Fixture 0.2 được giữ nguyên. Chưa chạy hoặc công bố FPS, đa chạm trên điện thoại, cài đè APK hay iOS trong kế hoạch headless này.

### Kết quả kỹ thuật đang chốt cho 0.4

Các suite mới đã thực thi trong Godot headless; chưa thay cho cửa desktop render hoặc APK do agent chính phụ trách:

| Suite | Assertion đạt / lỗi | Bằng chứng |
| --- | --- | --- |
| `test_pass_route.gd` | 17 / 0 | Centerline 3D lấy mẫu dài **778,003 đơn vị scene** trong khoảng 700–800; station parameter là 750. Đường liên tục/có cua/cao độ; hai layby; inverse station/lateral round-trip sai số ≤0,05 theo ngưỡng SA |
| `test_pass_save.gd` | 28 / 0 | Validator road riêng, dữ liệu lỗi về checkpoint an toàn; golden 0.2/0.3 giữ core/tutorial/settings; legacy ±41 vẫn chặn dữ liệu sai; road state và dấu reload từ file thật |
| `test_pass_physics.gd` | 14 / 0 | Ga/phanh/thả ga/lái đồng thời, tốc độ hữu hạn, physics floor; xe traffic thật và vật cản chặn bike; hai lần simulation 180 bước 1/60 giây cùng trạng thái đầu cho vị trí sai khác ≤0,0001 |
| `test_pass_touch.gd` | 11 / 0 | Ga+lái và phanh+lái bằng các pointer riêng, phanh ưu tiên khi ga đang giữ, UI blocked rect, modal disable và chuyển walking hủy pedal |
| `test_pass_world.gd` | 49 / 0 | Bike đứng trên mesh/collider tại sáu station; camera clamp/SpringArm; **rail và endpoint barrier của cảnh thật chặn bike**; hai stop có nội dung riêng, speed/zone guard, nhân vật xuống xe đứng/đi được, không drift khi đứng yên, remount cùng bike; pause/reset và chín ví dụ/checkpoint boundary PO đã chốt |
| `test_pass_integration.gd` | 41 / 0 | Main giữ registry 47; touch thật vào handler làm bike chạy, ba ngón phanh ưu tiên; modal dừng cả traffic, mất focus hủy ga; hai vòng stop/walk/POI/remount, dấu không lặp; keyboard F có guard riding/proximity/modal và ghi dấu khi hợp lệ; nút lên xe/tương tác không chồng nhau; road save không lọt vào positions cũ; restart và về cảnh cũ |

Đã chạy lại sáu suite regression của 0.3 sau tích hợp road: **257 assertion đạt, 0 lỗi** (`test_batch03_rules`, `test_player_tutorial`, `test_batch03_integration`, `test_controls_player`, `test_save_transitions`, `test_licenses`). Không chạy lại suite 502 world địa lý cũ vì generator đó không đổi. Kết quả trên đang là mốc trước khi chốt các nội dung review cuối của PO/root.

PO đã chốt reset về checkpoint an toàn gần nhất **đã đi qua theo tiến độ**, không phải điểm có khoảng cách tuyệt đối nhỏ nhất. Sau sửa strict boundary, các ví dụ 100/220/229→đầu tuyến, 230/231/470/540→230 và 551/570→550 đều đạt. Sau khi Developer thêm nội dung riêng cho hai viewpoint, avatar đi bộ riêng cho road và strict checkpoint, cùng main thêm keyboard F và tránh chồng nút, QA chạy lại world **49/49** và main integration **41/41**, exit code 0 và không có ERROR/FAIL; log `/tmp/travel-test_pass_world-04-final.log` và `/tmp/travel-test_pass_integration-04-final.log`. Tổng kỹ thuật tại mốc này là **160 assertion mới + 257 regression = 417 assertion đạt, 0 lỗi**. Chỉ chạy lại hai suite chịu ảnh hưởng của các thay đổi cuối; không chạy lặp 257 regression khi không có thay đổi logic liên quan. Chưa gọi artifact 0.4 ready khi chưa có APK/hash/signature do agent chính xác minh.

Lệnh cho suite 0.4: từ repository dùng `godot --headless --path game3d --script tests/test_pass_<tên>.gd`, đặt XDG_DATA_HOME/CONFIG_HOME/CACHE_HOME vào `/tmp/travel-qa04/<tên>/{data,config,cache}` để tách save test. Log hiện tại ở `/tmp/travel-pass-{save,physics,touch,world,integration}.log` và `/tmp/travel-04-test_pass_route.log`; regression ở `/tmp/travel-04-<test_suite>.log`. Exit code phải kiểm riêng, không chỉ tìm dòng PASS.

### Artifact Android 0.4.0 và desktop gate

Agent chính đã thực thi và chuyển kết quả cuối cho QA ghi nhận:

- APK `artifacts/doc-mien-viet-3d-0.4.0.apk`: **51.685.158 byte**; SHA-256 `69fc06ac2577ea223080d7adccf233556f9126474a86b315fd08db9fc160bfa4`.
- Kiểm tra tĩnh đạt: chữ ký v2/v3, zipalign 16 KiB, không có quyền `INTERNET`; chứa bytecode mountain pass, route, bike, traffic, scenery, art/materials và road save cùng JSON 47 địa danh và giấy phép.
- Đối chiếu artifact với 0.3: cùng package/certificate; versionCode tăng 3→4. Chưa cài đè trên thiết bị thực, nên chưa kết luận save được giữ sau nâng cấp APK thực tế.
- Desktop GUI fresh **PASS04** sau sửa avatar mũ bảo hiểm, phím F và vùng nút không chồng nhau. Agent chính thực hiện cửa render/input riêng với các kết quả headless phía trên.
- Công cụ QA điều khiển vật lý theo script đi từ station 5 đến **738,02** qua **5.916 bước simulation cố định**, không ghi nhận va chạm trong lượt đó. Đây là pilot của công cụ kiểm thử, **không phải tính năng tự lái của game**, không phải số đo FPS, thời gian chơi thực hoặc bằng chứng hiệu năng điện thoại.

Tại mốc này có bằng chứng APK 0.4 đã build và xác minh tĩnh ở local. Chưa coi việc đẩy source Git là phát hành APK remote; việc tải artifact remote cần agent chính xác nhận riêng. Các cửa Android/iOS thực, đa chạm trên điện thoại, FPS/RAM/nhiệt và nâng cấp cài đè vẫn chưa chạy.

## Batch 0.5 — chất lượng hình ảnh và mục tiêu tuyến

Phạm vi QA: profile `economy` mặc định và `detail` chỉ thay đổi trang trí; giữ bóng đổ là lựa chọn độc lập; lưu profile trong preferences v1; một thao tác vào demo và hướng dẫn mục tiêu theo checkpoint/dấu/chế độ. Replay không xóa tiến trình. Art mới cần kiểm chứng render riêng, không suy chất lượng hình ảnh từ số assertion.

Thiết bị mục tiêu do người dùng nêu: Oppo Find X7 Ultra và iPhone 13. Team chưa có quyền truy cập thiết bị thực; **chưa đo FPS, frame time, RAM hoặc nhiệt** trên hai máy, chưa xác nhận tương tác đa chạm hay cài đè APK trên máy người dùng.

Kết quả cuối: `test_quality_preferences.gd` **24 assertion đạt, 0 lỗi**, exit code 0. Suite kiểm tra enum/default, mười nhóm dữ liệu quality không hợp lệ không làm mất shadow/sensitivity, golden save 0.2/0.3 giữ tiến trình, checkpoint/mode/stamp của save 0.4 vẫn giữ khi quality thiếu/hỏng, ghi/đọc file thật và canonical JSON. Lệnh:

```bash
XDG_DATA_HOME=/tmp/travel-qa05/preferences/data \
XDG_CONFIG_HOME=/tmp/travel-qa05/preferences/config \
XDG_CACHE_HOME=/tmp/travel-qa05/preferences/cache \
godot --headless --path game3d --script tests/test_quality_preferences.gd
```

Log: `/tmp/travel-05-preferences.log`.

### Kết quả headless 0.5

**466 assertion đạt, 0 lỗi qua 13 suite**: 96 assertion mới và 370 regression liên quan. Tất cả lệnh kết thúc exit code 0; log cuối không có `ERROR` hoặc `FAIL`.

| Suite mới | Assertion đạt | Bằng chứng |
| --- | --- | --- |
| `test_quality_preferences.gd` | 24 | Enum/default, lỗi chỉ ở quality không reset core/settings/road state; migration 0.2/0.3/0.4; file save canonical và reload |
| `test_quality_world.gd` | 14 | Economy bật ngân sách 1.398 instance trang trí, detail 2.724; đổi qua lại/idempotent. Collider identity/shape bounds/layers/transforms, pose/speed/input/mode/checkpoint/traffic/POI giữ nguyên. Shadow và sensitivity độc lập. Camera transform cho phép sai số ≤0,001 đơn vị scene do SpringArm cập nhật nội bộ, không tính thay đổi far clip có chủ đích là thay pose. |
| `test_route_objectives.gd` | 20 | Thứ tự stop1/đỗ/đi bộ/stop2/đích; guard can_exit; vượt stop không tự có dấu; thiếu một trong hai dấu không thể hoàn tất dù tới cuối; replay giữ hai dấu và không giả là chưa ghé |
| `test_quality_goals_integration.gd` | 38 | Nút entry thật một action; UI quality callback live; settings/nút Trở lại trong viewport 1280×720; hai stop qua proximity guard thực cập nhật objective; restart giữa tuyến giữ checkpoint/dấu1 và nhắm stop2; replay giữ core/stamps/settings; đổi scene/restart giữ profile và mục tiêu đúng |

Ngân sách instance là tổng `visible_instance_count` được cấu hình cho nhóm trang trí, **không phải số draw call hay FPS đo được**. Suite world tạm dừng physics để tách tác dụng của đổi profile khỏi chuyển động simulation; không suy các snapshot đó thành trải nghiệm chơi trên điện thoại.

Regression đã chạy lại: `test_pass_physics` 14, `test_pass_world` 49, `test_pass_integration` 41, `test_pass_save` 28, `test_pass_touch` 11, `test_batch03_rules` 36, `test_batch03_integration` 38, `test_save_transitions` 135, `test_licenses` 18, tổng **370**. Không chạy lại các suite địa lý/world không chịu ảnh hưởng khác chỉ để tăng số kiểm tra.

Lệnh cho các suite mới dùng cùng mẫu XDG ở trên và đổi `--script tests/<suite>.gd`. Log mới: `/tmp/travel-05-{preferences,world,objectives,integration}.log`; regression: `/tmp/travel-05-<test_suite>.log`. Main objective integration có bố trí vị trí để kiểm trạng thái/guard; **không dùng teleport làm bằng chứng lái end-to-end**. Cửa render trước/sau cùng camera, vòng chơi GUI bằng input thật và artifact 0.5 do agent chính xác minh riêng. Chưa ghi APK 0.5 ready hoặc đo hiệu năng Oppo/iPhone khi chưa có bằng chứng tương ứng.

### Artifact và cửa render 0.5 cuối

Agent chính đã thực thi và chuyển kết quả cho QA ghi nhận:

- APK local 0.5: **51.697.778 byte**, SHA-256 `282b805f5715e7320815f83535cfb5e58e406b489bf40da05c6140a4331d3772`.
- Xác minh tĩnh đạt: chữ ký v2/v3, zipalign 16 KiB, không quyền `INTERNET`; chứa JSON 47 địa danh có giấy phép và bytecode objective/profile/vegetation. Package/certificate khớp 0.4, versionCode tăng 4→5.
- GUI **LIVE_LOOP05_PASS**: vào demo qua UI, điều khiển chạm lái thực từ station 5 đến 232,278, đỗ/xuống xe, đi bộ thực, tương tác F, đi trở lại xe và lên xe; objective chuyển sang stop2. Lượt này **không reset hoặc teleport**.
- Chín capture so sánh theo cặp dùng cùng pose/camera, FOV 69 và độ phân giải 1280×720; độ lệch pose được báo cáo bằng 0. Far-clip budget: bản cũ 420, economy 440, detail 650. Đây là cấu hình render/tầm nhìn, không phải số đo FPS.
- Harness headless đã sửa cách lấy logical size của controls thay vì kích thước Window 64 và thêm đợi frame flush cho GUI capture. Các sửa này thuộc công cụ kiểm thử, không thay đổi product code; không chạy lặp suite khi không có thay đổi sản phẩm liên quan.

Như vậy đã có bằng chứng build/xác minh tĩnh APK local và cửa GUI/render riêng ngoài 466 assertion headless. **Chưa kiểm thử điện thoại thực, cài đè APK, đa chạm thật hoặc hiệu năng Oppo Find X7 Ultra/iPhone 13; chưa có kết quả iOS.** Không suy các capture, giới hạn far clip hay số instance thành cam kết hiệu năng thiết bị. Trạng thái upload/phát hành APK remote phải được agent chính xác nhận riêng.
