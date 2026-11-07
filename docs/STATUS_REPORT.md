# Báo cáo tiến độ Dọc miền Việt

**Ngày cập nhật: 07/11/2026 — giờ Việt Nam (UTC+7).**

**Bản thử mới nhất là 3D 0.5, đã đăng APK và ZIP source lên GitHub.** Mã nguồn ở **`codex-work`**, bản cài ở **`apk-download`**. 466 kiểm tra/13 suite, ảnh đối chiếu và vòng chơi GUI đạt trong phạm vi desktop. **Chưa kiểm trên điện thoại thực; hình ảnh vẫn là prototype cách điệu.**

## Quyết định mới nhất — Unity 6/C#

Người dùng chuyển từ UE sang Unity 6, đề xuất HDRP và hệ sinh thái Unity Asset Store. Team tách **URP mobile Android/iOS** và **HDRP desktop**, vì HDRP không hỗ trợ hai nền tảng mobile này. Source mới ở `unity/`, giữ Godot/UE như lịch sử, không gọi APK Godot là bản Unity.

Đã chuẩn bị source vòng xe arcade → đỗ đúng vịnh → đi bộ → hai POI theo thứ tự → lên xe, camera, input và journal offline; scene/bootstrap URP, entrypoint build, companion HDRP và bản sao ba FBX gốc. **60 assertion Domain chạy thực bằng .NET**, tách khỏi Unity compile, JSON/file runtime và gameplay. Xem [UNITY_VALIDATION.md](UNITY_VALIDATION.md), [hướng dẫn](../unity/README.md).

Chưa có Unity Editor/license để resolve packages, compile toàn project, tạo scene, render/cook/build APK/IPA hoặc thử điện thoại. Kênh tải Editor chính thức trả CONNECT 403 qua proxy; source/.NET test vẫn tiếp tục được. Chưa mua gói Asset Store, chưa có asset scan hoặc kết quả “90–95%” hình ảnh. Cổng kế tiếp là mở đúng Editor/pipeline, kiểm mini-loop và render thực, sau đó đo Android/iOS.

## Yêu cầu UE5 trước đó — 07/11/2026

Người dùng yêu cầu UE5 và hệ sinh thái PBR/scan/rừng nhiệt đới/đường ướt/sương theo [brief gốc](inputs/GRAPHICS_BRIEF_2026-11-07.txt), sau đó xác nhận chưa có UE hoặc asset sẵn. Team đã chuẩn bị project C++ UE5.5, spline/mesh đường, Character đi bộ/camera góc thứ ba, material slots, script tạo material PBR và map trong Editor, cấu hình mobile, entrypoint build và kế hoạch chuyển engine. Đã tạo ba FBX gốc (đá/dương xỉ/chuối) với UV/materials, source Blender và [ảnh render Blender](art/asset-preview.png); importer và HISM cho UE đã có source. Chưa nhập/chạy các file này trong UE. Xem [hướng dẫn](../unreal/README.md), [tiêu chí đồ họa](GRAPHICS_REQUIREMENTS.md), [kiểm chứng](UNREAL_VALIDATION.md).

**Chưa có UE trong môi trường để compile/render/cook. Chưa có map/material `.uasset` sinh từ Editor, APK/IPA Unreal, xe máy/touch/save đã port hoặc bằng chứng đồ họa đạt mẫu.** Kiểm tra source/config không thay runtime. Godot 0.5 vẫn là APK chơi được đã giao; UE là nhánh công việc mới trong cùng `codex-work`, không phải bản nâng đồ họa đã cài được.

Ưu tiên triển khai mới là xác minh scaffold trên UE, rồi hoàn thiện một đoạn đèo với asset có license và kiểm điện thoại trước khi nhân rộng; catalog đảo vẫn là nghĩa vụ dữ liệu riêng, không coi danh mục cũ là scene Unreal đã có. Nanite/Lumen chỉ đánh giá ở profile desktop riêng, không hứa chạy trên iPhone 13/Oppo từ config.

## 1. Team đã làm được gì?

| Phiên bản | Nội dung đã có | Trạng thái và giới hạn |
| --- | --- | --- |
| **0.1 — prototype cũ** | Game mobile theo tuyến du lịch, câu hỏi văn hóa, dấu hộ chiếu và lưu tiến trình; có APK thử nghiệm. | Là bản quiz/Expo để tham khảo lịch sử. Không phải hướng khám phá 3D hiện tại. |
| **0.2 — nền game 3D** | Chuyển sang Godot: điều khiển nhân vật đi bộ, camera góc nhìn thứ ba, địa hình/va chạm, POI, lưu offline và đổi địa điểm. Danh mục 47 mục gồm 34 tỉnh/thành và 13 vùng đảo, mỗi mục vào được cảnh minh họa có ba POI. Có APK và gói source. | Phần lớn nội dung sinh bằng thuật toán; Hà Nội có khu mẫu riêng. Đây không phải toàn bộ địa hình hoặc công trình của mỗi tỉnh/đảo. |
| **0.3 — cải thiện trải nghiệm** | Hướng dẫn ba thao tác thật; chỉ tới POI chưa thăm gần nhất; bật/tắt bóng và ba mức nhạy camera; giữ save 0.2. Có APK/gói source đã phân phối trên GitHub. | PO nghiệm thu phạm vi logic/desktop. Chưa xác minh cảm ứng, hiệu năng hoặc cài đè trên điện thoại thực. |
| **0.4 — bản thử đã phân phối** | Đường đèo, xe máy, ba xe traffic, hai điểm dừng, đi bộ tham quan, checkpoint và HUD/touch đã tích hợp. QA 417 kiểm tra đạt; vòng chơi render desktop đạt. APK và ZIP source đã đăng GitHub. | Source đã push lên `codex-work`; artifact trên `apk-download`. Chưa mobile/iOS verified. Hình ảnh là prototype cách điệu, chưa đạt ảnh tham chiếu. |
| **0.5 — bản thử đã phân phối** | PO-11/12 đã triển khai: cải thiện ba lớp mỹ thuật, hai preset, entry demo và mục tiêu hành trình. 466 kiểm tra đạt; ảnh đối chiếu cùng camera và vòng chơi GUI đạt; có APK đã kiểm. | APK/source ZIP đã đăng nhánh `apk-download`. Hình ảnh vẫn cách điệu; hai điện thoại đích và iOS chưa kiểm chứng. |

Bên cạnh mã game, team đã lập tài liệu yêu cầu và điều kiện nghiệm thu, kiến trúc, UX/mỹ thuật, phạm vi dữ liệu địa lý, nghiên cứu định tính có nguồn, backlog và bộ kiểm thử. Nghiên cứu PO là đối chiếu sản phẩm công khai; chưa phải khảo sát thị trường đại diện hoặc bằng chứng người chơi thật.

## 2. Bản 0.3 đã được kiểm chứng tới đâu?

Theo [báo cáo xác minh 0.3](VALIDATION_0.3.md):

- **257 assertion đạt, 0 lỗi** trong sáu suite của đợt kiểm thử: quy tắc, player/tutorial, integration, controls, save/transitions và giấy phép.
- Đã kiểm thử render desktop: thực hiện đi bộ, xoay camera và tương tác thật; HUD đổi mục tiêu; settings hoạt động và giữ qua đổi cảnh. Lỗi hộp thoại vượt màn hình đã được sửa và kiểm lại.
- APK 0.3 đã kiểm tra file, chữ ký v2/v3, alignment 16 KiB, application ID/version, tài nguyên đóng gói và không khai báo quyền INTERNET.
- APK 0.3 có cùng application ID/chứng thư thử nghiệm với 0.2, versionCode tăng 2 → 3. Đây là kiểm tra metadata hỗ trợ cập nhật, **chưa phải thử cài đè giữ dữ liệu trên điện thoại**.

APK local: `artifacts/doc-mien-viet-3d-0.3.0.apk`, **51.642.944 byte**, SHA-256:

```text
99649f3cb829098d8a7cbde8f06604a2320bed98ca3c0ed9df4197a0241eca99
```

**Chưa kiểm chứng:** Android/iPhone thực, đa chạm và safe area trên thiết bị, mở lạnh ở chế độ máy bay trên điện thoại, FPS/RAM/nhiệt/pin và bản iOS đã ký/chạy. Kiểm thử desktop và artifact APK không thay thế các bước này.

## 3. Bản 0.4 đã đạt những gì?

Phạm vi đã chốt là một **mẫu riêng khoảng 750 đơn vị scene**, cửa nghiệm thu chiều dài centerline 700–800; không phải đo đường thực hoặc tái dựng GIS đèo Khánh Lê. Giữ Godot hiện tại để kiểm chứng trước khi cân nhắc thay engine.

| Hạng mục | Hiện trạng tại thời điểm báo cáo |
| --- | --- |
| Tuyến đường đèo | Có tuyến cong/cao độ/mặt đường và cảnh minh họa, mục tiêu 750 đơn vị scene. Công cụ QA đã điều khiển xe thực theo vật lý từ mốc 5 tới **738,02**, qua **5.916 fixed ticks**, không ghi nhận va chạm trong lượt đó. Đây là kịch bản kiểm thử, không phải chức năng tự lái trong game hoặc phép đo FPS. |
| Xe máy/nhân vật | Ga, phanh, lái, camera và chuyển xe/đi bộ hoạt động trong vòng render desktop; nhân vật đi bộ có mũ bảo hiểm. |
| Giao thông | Có ba xe traffic; logic, fixed-step và va chạm nằm trong phạm vi QA. Lượt pilot không va chạm không có nghĩa game không có collider hoặc mọi tình huống giao thông đã được kiểm trên điện thoại. |
| Dừng và tham quan | Đã kiểm vòng lái → dừng trong vùng → xuống đi bộ → tương tác → lên xe tại **cả hai điểm dừng**. Guard yêu cầu tốc độ ≤0,5 đơn vị/giây khi đỗ, sau đó đi bộ đủ gần mới nhận dấu; không tự nhận khi chạy qua. |
| Hình ảnh | Cảnh/tài nguyên procedural theo phong cách prototype cách điệu. **Chưa đạt photoreal hoặc chất lượng ảnh tham chiếu**; gameplay đạt không đồng nghĩa mỹ thuật đã đạt mục tiêu tham chiếu. |
| HUD và input | Đã tích hợp HUD/touch/keyboard. Fresh render smoke đạt `PASS04_VISUAL_PASS` sau khi sửa vùng hiển thị F/Inspect. Đa chạm trên thiết bị thật vẫn chưa xác minh. |
| Lưu checkpoint | Đã có kiểm thử save/checkpoint và tương thích dữ liệu cũ. Reset về mốc an toàn đã đi qua gần nhất theo tuyến: 0/230/550; ví dụ đang ở 470 trở về 230, không nhảy tới 550. |
| APK/thiết bị | APK 0.4 đã kiểm hash/chữ ký/alignment/tài nguyên và đăng lên nhánh phân phối. Chưa chạy thử điện thoại/iOS hoặc đo FPS/RAM/nhiệt. |

**Bằng chứng mới:** Tester báo **417 kiểm tra đạt**. Root chạy lại render trên mã hiện tại, hoàn thành hai vòng dừng–đi bộ–tương tác–lên xe, kết quả `PASS04_VISUAL_PASS`. Kịch bản pilot chạy xe bằng simulation vật lý là bằng chứng tuyến đi được trong điều kiện thử; không thay thế playtest người chơi hoặc profiling điện thoại.

**APK 0.4 đã phân phối:** `artifacts/doc-mien-viet-3d-0.4.0.apk`, **51.685.158 byte**, SHA-256:

```text
69fc06ac2577ea223080d7adccf233556f9126474a86b315fd08db9fc160bfa4
```

Đã kiểm tra chữ ký v2/v3, ZIP và alignment 16 KiB; không quyền INTERNET; đóng gói tám module đường đèo cùng JSON/giấy phép của registry 47 mục. Chứng thư khớp 0.3, versionCode tăng 3 → 4. Root đã xác nhận push artifact lên remote. Đây là bằng chứng phân phối file, **chưa phải xác nhận cài đè hoặc chạy thật trên Android/iOS**.

Photo mode/album tiếp tục **hoãn khỏi cửa nghiệm thu 0.4**. Tiêu chí chi tiết ở [PRODUCT.md — phần 0.4](PRODUCT.md) và [PO-10 trong backlog](PRODUCT_BACKLOG.md). Các kiểm tra logic/render đạt không tự xác nhận mọi tình huống, chất lượng hình ảnh tham chiếu hay khả năng chạy trên thiết bị.

## Bản 0.5 — đã phân phối trên GitHub

Hai hạng mục đã được hiện thực hóa trong scene/vòng chơi:

- **PO-11:** cải thiện mặt đường, cảnh quan và ánh sáng/sương; preset Tiết kiệm (default) và Chi tiết áp dụng live, lưu lại, không đổi gameplay và không ghi đè lựa chọn bóng.
- **PO-12:** entry demo rõ; mục tiêu theo mode/vị trí/dấu thật qua lái → đỗ → đi bộ/tương tác → lên xe → điểm kế tiếp; đi lại từ đầu giữ dấu.

**Bằng chứng mới của 0.5:**

- QA báo **466 kiểm tra đạt qua 13 suite**; đây là kết quả 0.5, phân biệt với 417 của 0.4.
- Có ảnh 0.4 đối chiếu 0.5 Tiết kiệm/Chi tiết tại ba góc. Camera pose, FOV và độ phân giải được xác nhận khớp chính xác, sai lệch 0; ba lớp thay đổi mỹ thuật hiện diện trong render. **Cảnh vẫn stylized, chưa đạt photoreal hoặc chất lượng ảnh tham chiếu.**
- Root thao tác touch qua GUI, lái vật lý từ mốc 5 đến **232,278**, đỗ → xuống xe → đi bộ → F tương tác → đi về xe → lên xe; mục tiêu chuyển sang điểm dừng 2. Lượt này không reset hoặc teleport. Đây là input touch mô phỏng trên desktop, không phải thử OPPO/iPhone thật.

**APK 0.5 đã phân phối:** `artifacts/doc-mien-viet-3d-0.5.0.apk`, **51.697.778 byte**, SHA-256:

```text
282b805f5715e7320815f83535cfb5e58e406b489bf40da05c6140a4331d3772
```

Đã kiểm chữ ký v2/v3, alignment 16 KiB, không quyền INTERNET, dữ liệu 47 vùng và module mới đóng gói. Package/chứng thư khớp 0.4, versionCode 4 → 5. APK và source ZIP đã được push lên GitHub; chưa kiểm cài đè thật trên điện thoại.

Người dùng nêu **OPPO Find X7 Ultra và iPhone 13** làm máy đích; chưa có OS/version hoặc truy cập thiết bị. Chưa có kết quả FPS/RAM/nhiệt/đa chạm native cho hai máy, chưa có IPA hoặc iOS chạy thực. Sau 0.5, trước feature phụ đèo, team phải đưa ra đề xuất catalog đảo v0 có nguồn/version/license/ID và báo cáo gap. Registry 47 mục và khoảng trống đảo/GIS không đổi. Photo mode/album vẫn deferred.

## 4. Phạm vi Việt Nam và đảo: đã đủ chưa?

**Chưa.** Registry hiện có **34 tỉnh/thành + 13 vùng đảo/đặc khu = 47 mục**. Tên có nguồn dataset cộng đồng được pin phiên bản/giấy phép; chưa đối soát trực tiếp đầy đủ mọi thông tin hành chính với văn bản nhà nước.

13 vùng đảo không phải 13 đảo đơn và không đại diện mọi đảo có tên của Việt Nam. Hiện còn thiếu catalog đầy đủ đảo thành phần, geometry/đường bờ/cao độ thực và nội dung đặc trưng từng nơi. Cảnh minh họa vào được không đồng nghĩa đã tái dựng địa phương chi tiết. Mẫu đèo 0.4 cũng không làm tăng độ phủ địa lý đã xác minh.

Team giữ rõ khoảng trống này trong [GEOGRAPHIC_SCOPE.md](GEOGRAPHIC_SCOPE.md); PO-04/05 về dữ liệu đảo và cảnh đặc trưng vẫn còn mở. Không công bố đã hoàn thành toàn quốc, mọi đảo hoặc địa hình thực địa.

## 5. Đang làm trên nhánh nào?

**Nhánh đang làm là [`codex-work`](https://github.com/BachVu89/TravelVietnamese/tree/codex-work)**. Theo yêu cầu người dùng, root đã tạo nhánh, commit source/tài liệu và push thành công lên GitHub, có tracking `origin/codex-work`.

| Nơi | Tên/trạng thái | Ý nghĩa |
| --- | --- | --- |
| Workspace phát triển và GitHub | **`codex-work`**, đã có commit và remote xác nhận. | Chứa source/tài liệu và mã tích hợp 0.5 đã push; đây là nhánh để theo dõi công việc hiện tại. Báo cáo có thể có commit tài liệu bổ sung sau mốc code. |
| Nhánh phân phối | **`apk-download`**. | Chứa APK, ZIP source 0.5 và các bản phân phối trước; không phải nhánh source đang phát triển. |
| Nhánh `main` | **Chưa tồn tại trên remote** tại lần kiểm tra. | Không dùng `main` để tìm source hiện tại. |

Checkpoint source đầu tiên được push: [`35e7deceeb2d9d1986dcf93ac1bac8ed172931ee`](https://github.com/BachVu89/TravelVietnamese/commit/35e7deceeb2d9d1986dcf93ac1bac8ed172931ee), nội dung commit: `Checkpoint 3D prototype and mountain-pass development`. Trước checkpoint, workspace ở tên nhánh local `work` chưa có commit; tình trạng chưa bảo vệ source bằng commit này đã được xử lý. Cache, khóa ký và artifact build không đưa vào commit source.

**Mã nguồn 0.4 đã push:** [`197432a196e1b58ca1fb2a8431677caca87eb412`](https://github.com/BachVu89/TravelVietnamese/commit/197432a196e1b58ca1fb2a8431677caca87eb412) trên `codex-work`. Đây là mốc code 0.4 đã được xác nhận, không phải mốc hoàn thiện code 0.5.

**Mã nguồn 0.5 đã push:** [`b800021`](https://github.com/BachVu89/TravelVietnamese/commit/b800021). **Phân phối 0.5 đã push:** [`3b3b35a`](https://github.com/BachVu89/TravelVietnamese/commit/3b3b35a), gồm APK, source ZIP, checksum và bằng chứng kiểm thử. Source ZIP là snapshot trước cập nhật trạng thái phân phối cuối cùng trong báo cáo này.

**Phân phối 0.4 đã push:** [`cd0794febc1ae240c38c68a8b231665711117cfa`](https://github.com/BachVu89/TravelVietnamese/commit/cd0794febc1ae240c38c68a8b231665711117cfa) trên `apk-download`, gồm APK và ZIP source. Mốc phân phối 0.3 trước đó là `2f0346d5d417ee6f21fe0d1c41560b71376e1cc3`; ZIP source 0.3 không chứa thay đổi 0.4. Việc push source/artifact xác nhận khả năng xem/tải bản thử, không xác nhận chất lượng ảnh tham chiếu hoặc kiểm thử thiết bị.

## 6. Xem bản đã giao ở đâu?

- [Đọc báo cáo này trên GitHub](https://github.com/BachVu89/TravelVietnamese/blob/codex-work/docs/STATUS_REPORT.md).
- [Source đang phát triển — `codex-work`](https://github.com/BachVu89/TravelVietnamese/tree/codex-work).
- [Nhánh phân phối GitHub `apk-download`](https://github.com/BachVu89/TravelVietnamese/tree/apk-download): bản 0.5 đã giao cùng APK và ZIP source; các bản cũ được giữ để tham khảo. Đây là nơi xem/tải bản đã phân phối; source ZIP là snapshot đóng gói, không phải lịch sử commit source đang phát triển.
- [Tải APK 0.5 mới nhất](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-0.5.0.apk).
- [Tải source ZIP 0.5](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-source-0.5.0.zip).
- [Tải APK 0.3 cũ đã phân phối](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-0.3.0.apk).
- [Tải source ZIP 0.3 đã phân phối](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-source-0.3.0.zip).
- APK 0.5 local tương ứng bản đã phân phối: `artifacts/doc-mien-viet-3d-0.5.0.apk`.
- APK 0.4 local tương ứng bản đã phân phối: `artifacts/doc-mien-viet-3d-0.4.0.apk`.
- File APK 0.3 local: `artifacts/doc-mien-viet-3d-0.3.0.apk`.
- Gói source local: `artifacts/doc-mien-viet-3d-source-0.3.0.zip`.
- [Báo cáo kiểm thử 0.3](VALIDATION_0.3.md), [yêu cầu sản phẩm](PRODUCT.md), [backlog](PRODUCT_BACKLOG.md), [kiến trúc](ARCHITECTURE.md) và [phạm vi địa lý](GEOGRAPHIC_SCOPE.md).

## 7. Ai đang phụ trách và mốc tiếp theo?

| Vai trò | Việc phụ trách |
| --- | --- |
| PO | Nghiên cứu có nguồn, ưu tiên backlog, chốt scope và nghiệm thu giá trị |
| BA | Làm rõ yêu cầu/AC, phạm vi và báo cáo tiến độ |
| SA | Kiến trúc, save/offline, tương thích và rủi ro kỹ thuật |
| Designer | Luồng chơi, HUD/điều khiển, mỹ thuật và chất lượng cảnh |
| Developer | Module gameplay, dữ liệu, sửa lỗi và build |
| Tester | Test theo AC, hồi quy và bằng chứng logic/render/thiết bị |
| Root/điều phối | Tích hợp, chạy kiểm trực tiếp, review và giao artifact |

Đây là team tác nhân AI theo vai trò, không mặc nhiên có studio nghệ thuật 3D hoặc phòng thử thiết bị chuyên nghiệp. Chi tiết tại [TEAM.md](TEAM.md).

Mốc kế tiếp: đề xuất catalog đảo v0 có nguồn/version/license/ID và báo cáo khoảng thiếu, trước các feature phụ cho đèo. Tiếp tục chuẩn bị thử trên OPPO Find X7 Ultra/iPhone 13. Kiểm thử Android/iOS thực và hiệu năng còn mở; chưa cam kết FPS, ngày giao hoặc chi phí.

---

**Nguồn báo cáo:** kết quả Git; QA 417 của 0.4 và 466/13 suite của 0.5; render smoke, ảnh đối chiếu và kiểm APK do root/Tester xác nhận; `game3d/scripts/main.gd`, `mountain_pass.gd`, `pass/`, `road_save.gd`, `pass_materials.gd`; danh sách artifact local; `VALIDATION_0.3.md`, `PRODUCT.md`, `PRODUCT_BACKLOG.md`, `TEAM.md` và `GEOGRAPHIC_SCOPE.md`. Báo cáo này không thay đổi app code hoặc tự xuất bản source.

## Phản hồi chạy Unity thực tế và hướng sửa

Người dùng đã mở/chạy project và gửi ảnh lỗi đường nhấp nháy chỉ khi xe chạy; đồ họa hiện còn prototype. Team bổ sung camera query lọc actor, near-plane guard và recovery; menu cập nhật scene cũ với chín map PBR gốc. Đây là source patch và kiểm logic, chưa tái hiện/đánh dấu hết lỗi trong Unity. Xem [UNITY_CAMERA_GRAPHICS_FIX.md](UNITY_CAMERA_GRAPHICS_FIX.md).

## Phản hồi chất lượng hình ảnh — Scenic V3

Sau khi người dùng tiếp tục từ chối chất lượng texture-only, batch này thay đổi cấu trúc cảnh/asset: ridged terrain, núi xa, rừng instancing, xe/người gốc và HUD desktop gọn. Có ảnh Blender và FBX readback thực, sửa mesh fold bằng audit số; chưa có Unity screenshot/performance do team chạy và chưa đạt ảnh tham chiếu. Xem [UNITY_SCENIC_V3.md](UNITY_SCENIC_V3.md).
