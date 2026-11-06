# Dọc miền Việt 3D 0.4.0 — tuyến đèo mẫu

Ngày xác minh: 06/11/2026. Đây là mốc **prototype chơi được**, nhằm kiểm chứng vòng lái xe → dừng trong vịnh → xuống đi bộ/tham quan → lên xe. Đồ họa hiện còn cách ảnh tham chiếu photoreal; chưa nghiệm thu chất lượng mỹ thuật đó hoặc hiệu năng mobile.

## Phạm vi đã làm

- Tuyến cong có cao độ, mặt đường asphalt, vạch đường, guardrail, vách núi, rừng instancing, núi xa và sương. Tham số tuyến dài 750; centerline lấy mẫu thực đo 778,003 đơn vị scene, nằm trong cửa 700–800 đã chốt. Không phải dữ liệu khảo sát đèo Khánh Lê.
- Xe máy arcade có ga, phanh ưu tiên, lái, camera theo/xoay, va chạm và giới hạn tốc độ 18 đơn vị/giây. Nhân vật có mũ bảo hiểm và tay/chân khi lái hoặc đi bộ trong tuyến mẫu.
- Ba xe giao thông chạy cục bộ theo fixed-step, có collider; không tải mạng, không tái xuất hiện bằng teleport trong lượt chạy.
- Hai vịnh tại station 230 và 550, có nội dung tham quan riêng. Chỉ xuống xe khi tốc độ ≤0,5 và trong vịnh; đi bộ đến gần mới tương tác, lên lại cùng xe khi đủ gần.
- Touch gồm lái, ga, phanh và camera với pointer riêng; bàn phím A/D lái, W ga, S phanh, E lên/xuống xe, F khám phá khi đang đi bộ gần POI. Mở menu/dialog hoặc mất focus hủy ga và dừng mô phỏng.
- Save version 1 mở rộng trường `road_demo`, không nới giới hạn tọa độ ±41 của cảnh cũ. Phục hồi riêng checkpoint đèo; reset chỉ về checkpoint đã đi qua, giữ dấu/cài đặt/hướng dẫn cũ.

Tuyến mẫu là mục riêng trong menu; danh mục địa lý vẫn 34 tỉnh/thành + 13 vùng đảo, không tính đèo thành một tỉnh hoặc đảo mới. Photo mode hoãn khỏi mốc này.

## Kiểm thử đã thực thi

**417 assertion đạt, 0 lỗi:** 160 mới (route 17, road save 28, bike/traffic physics 14, touch 11, road world 49, main integration 41) và 257 hồi quy liên quan từ 0.3. Các thay đổi cuối chỉ chạy lại suite bị ảnh hưởng; xem [TEST_PLAN_3D.md](TEST_PLAN_3D.md) để biết lệnh và lần chạy. Bộ world 502 điều kiện của 0.2 không cộng thành kết quả mới.

Root chạy visual smoke bằng Xorg/Mesa, 1280×720: ga/phanh qua handler touch làm xe di chuyển và dừng; xem cảnh đầu/cua; xuống xe, tương tác và lên lại tại cả hai vịnh; lưu checkpoint vượt ±41 mà không chạm `positions` cũ; mở menu. Lần cuối dùng avatar đã sửa và hai nút không chồng nhau. `PASS04_VISUAL_PASS`, exit 0.

Một bộ điều khiển **chỉ dành QA**, `qa/drive_full_pass.gd`, điều khiển vật lý xe từ station 5 đến 738,02 qua 5.916 fixed-step; không có va chạm trong lượt đó. Đây không phải tính năng tự lái trong game, không phải đo thời gian chạy thực hoặc FPS, và không chứng minh người chơi mới tự lái tốt trên điện thoại.

## APK đã kiểm tra

- File: `artifacts/doc-mien-viet-3d-0.4.0.apk`, **51.685.158 byte** (khoảng 51,7 MB).
- SHA256: `69fc06ac2577ea223080d7adccf233556f9126474a86b315fd08db9fc160bfa4`.
- Application ID `com.travelvietnamese.docmienviet3d`, version name 0.4.0/code 4; Android API 24+, target API 36, ARM64/ARM 32-bit và OpenGL ES 3.
- Chữ ký v2/v3, ZIP integrity và alignment 16 KiB đạt. APK release không debuggable, không quyền INTERNET, có các module bytecode đèo/xe/traffic/cảnh/checkpoint, 47 bản ghi địa lý và giấy phép nhúng.
- Chứng thư ký và application ID trùng bản 0.3, versionCode tăng 3 → 4. Chưa thử cài đè/giữ dữ liệu trên thiết bị thật.

```sh
./scripts/build-3d-android-apk.sh
python scripts/verify-3d-apk.py artifacts/doc-mien-viet-3d-0.4.0.apk \
  --previous-apk artifacts/doc-mien-viet-3d-0.3.0.apk
sha256sum -c artifacts/doc-mien-viet-3d-0.4.0.apk.sha256
```

## Cách vào tuyến mẫu

Cài/mở **Dọc miền Việt 3D** → **Đổi địa điểm** → **LÁI XE TRÊN ĐÈO MÂY · Tuyến mẫu 750 m**. Giữ GA/W để chạy, dùng joystick trái/A–D để lái và PHANH/S để dừng. Muốn xuống xe phải vào vịnh dừng; nút HUD ghi rõ khi điều kiện chưa đạt. **Về điểm dừng** phục hồi tại checkpoint an toàn đã đi qua.

## Giới hạn còn mở

Chưa có ảnh/asset đạt độ chân thực của thiết kế tham chiếu; hiện dùng hình khối, vật liệu và cảnh sinh thủ tục tự tạo. Chưa có dữ liệu địa hình thực hoặc danh mục đầy đủ mọi đảo Việt Nam. Chưa chạy Android/iPhone thực, đo FPS/frame time/RAM/nhiệt/pin, kiểm safe area/đa chạm thật hoặc mở lạnh offline trên điện thoại. Không công bố đạt 30 FPS. iOS chưa có bản cài đã ký.

Ảnh từ render thật: [đầu tuyến](screenshots04/start.png), [khúc cua](screenshots04/bend.png), [xuống xe tại điểm dừng](screenshots04/viewpoint.png), [menu](screenshots04/menu.png).
