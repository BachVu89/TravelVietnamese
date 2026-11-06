# Product backlog — Dọc miền Việt 3D

Owner: **Product Owner**. Cập nhật quyết định: 06/11/2026. Hướng bất biến do chủ sản phẩm đặt: khám phá 3D bằng nhân vật điều khiển, Android/iOS, offline, đủ tỉnh/thành và các đảo trong phạm vi dữ liệu được kiểm chứng; các đảo phải có cảnh đi vào. PO không tự đổi hướng này thành quiz hoặc game chỉ có marker.

Nghiên cứu đầu vào: [market/RESEARCH.md](market/RESEARCH.md). Bằng chứng hiện là benchmark tính năng nguồn công khai và quan sát code; chưa xác minh nhu cầu/thị phần bằng nghiên cứu người chơi. **P0/P1 là ưu tiên PO, S/M/L là ước lượng tương đối để trao đổi**, không phải lịch giao hàng hoặc số giờ đã cam kết.

## Iteration 0.3 đã chốt để triển khai

| ID | Ưu tiên/cỡ | Vấn đề và quyết định | Bằng chứng | Đo/kiểm chứng |
| --- | --- | --- | --- | --- |
| PO-01 | P0 / S–M | Người mới vào scene mà chưa có chuỗi học thao tác được xác nhận. Thêm hướng dẫn tương tác ba bước. | Khoảng trống code 0.2; pattern hướng dẫn hành động của Veloren S4. | Test trạng thái + playtest mới; mục tiêu 4/5 người tự hoàn thành trong 2 phút là giả thuyết chưa đo. |
| PO-02 | P0 / M | Người chơi chỉ thấy hành động khi đã đến gần POI; thêm mục tiêu chưa thăm, khoảng cách và hướng. | Khoảng trống code 0.2; waypoint/map trong S1/S4. | Kiểm thử hình học và chuyển mục tiêu; quan sát thời gian tìm POI thứ hai, chưa claim cải thiện retention. |
| PO-03 | P1 / S | Độ nhạy cố định và bóng luôn bật; thêm lựa chọn đơn giản, lưu local. | S2/S5 có tùy chỉnh cảm ứng/camera/bóng; code 0.2 chưa có menu. | Kiểm thử áp dụng/lưu; đo thiết bị riêng trước khi nói tiết kiệm pin hoặc tăng FPS. |

### PO-01 — Hướng dẫn bằng hành động thật

- Khi dữ liệu lưu chưa có trạng thái tutorial, khởi tạo `active`, bước 0. Bản nâng cấp từ 0.2 cũng thấy hướng dẫn này một lần; **không suy đoán đã học chỉ từ số dấu cũ**.
- Ba bước theo thứ tự: di chuyển tối thiểu **2 đơn vị XZ trong scene bằng input liên tục**, xoay camera tổng góc yaw/pitch tối thiểu **0,25 rad bằng look input**, rồi tương tác thành công với một POI qua kiểm tra khoảng cách hiện có. Khoảng cách trong scene minh họa không phải khoảng cách địa lý thực.
- Di chuyển do teleport, đổi vùng, hồi sinh hoặc nạp save không hoàn thành bước đi. Hành động làm trước khi tới bước tương ứng không tự bỏ qua các bước sau.
- Có **Bỏ qua** và **Xem lại hướng dẫn**. Bỏ qua ghi `skipped`, khác `completed`. Xem lại đặt tutorial về bước 0, không xóa vị trí, vùng, dấu hoặc settings.
- Tương tác lại POI đã có dấu vẫn được dùng hoàn thành bước học tương tác; không ghi dấu trùng hoặc yêu cầu người nâng cấp phải xóa progress.
- Lưu bước/trạng thái bằng trường tùy chọn tương thích save v1; khởi động lại tiếp tục đúng bước. Hoàn thành/đã bỏ qua không tự hiện lại khi vào vùng mới hoặc mở lại game.
- Không khóa quyền khám phá hoặc buộc hoàn thành tutorial để đổi địa điểm. UI/modal giữ quy tắc dừng input/cancel touches hiện có.

### PO-02 — Mục tiêu tham quan và hướng đi trong scene

- Khi chưa khám phá hết, chọn **POI chưa có dấu gần nhân vật nhất theo khoảng cách XZ** trong world đang hoạt động. Tie có thứ tự ổn định để mục tiêu không nhấp nháy.
- HUD hiển thị tên, khoảng cách xấp xỉ bằng đơn vị scene và hướng tương đối theo camera. Có nhãn rõ **“trong cảnh minh họa”**; không suy ra tọa độ GPS hoặc đường đi ngoài thực tế.
- Cập nhật khi nhân vật/camera di chuyển, sau tương tác và khi đổi vùng. Chỉ đọc POI của world hiện tại; ID/visited của vùng khác không làm sai tiến trình.
- POI đã có dấu không còn là mục tiêu. Khi đã thăm mọi POI, không truy cập mục tiêu rỗng; hiện “Đã khám phá N/N điểm trong cảnh”. Không viết “đã tham quan đầy đủ tỉnh/quần đảo”.
- HUD điều hướng không tự dịch chuyển nhân vật, không tự ghi dấu và không vượt điều kiện proximity để tương tác. Mở mục tiêu không phải hoàn thành tham quan.

### PO-03 — Tùy chỉnh camera và bóng

- Menu có bóng **Bật/Tắt**, mặc định **Bật** để giữ hành vi 0.2; độ nhạy camera **Thấp 0,6× / Chuẩn 1× / Cao 1,4×**, mặc định Chuẩn.
- Thay đổi áp dụng trực tiếp trong cảnh hiện tại. Lựa chọn giữ khi vào mọi cảnh khác và sau khởi động lại; không ghi đè vị trí/dấu.
- Save v1 không có trường mới dùng mặc định an toàn. Trường settings tùy chọn sai kiểu hoặc ngoài tập cho phép được chuẩn hóa riêng; không xóa progress lõi hợp lệ.
- Độ nhạy tác động cho input look cảm ứng và chuột; giới hạn pitch/collision camera giữ nguyên. Không đổi tốc độ đi khi thay độ nhạy.
- Mở settings dừng điều khiển thế giới và giải phóng touch đang giữ; đóng settings trở lại quyền điều khiển hợp lệ. Có nhãn chữ, không chỉ màu.
- Không quảng cáo “chạy mượt máy yếu”, “tiết kiệm pin X%” hoặc “30 FPS” chỉ vì có nút tắt bóng; các kết quả này cần đo thiết bị.

## Backlog chiến lược — không được thay bằng tiện ích UI

| ID | Ưu tiên/cỡ | Yêu cầu tiếp theo | Cửa nghiệm thu/không được tuyên bố sớm |
| --- | --- | --- | --- |
| PO-04 | P0 chiến lược / L | Danh mục đảo có tên với provenance, version, ID/alias, quan hệ đảo/quần đảo và geometry có giấy phép. | Công bố phạm vi dataset, kiểm tra thiếu/trùng và coverage từng ID. 13 vùng đảo hiện tại không đại diện mọi đảo thành phần; tiếp tục giữ cờ coverage false đến khi đối soát. Không dùng bbox hoặc tên suy đoán để gắn quốc gia. |
| PO-05 | P0 chiến lược / L | Dựng cảnh/landmark/POI đặc trưng có kiểm chứng, bắt đầu một khu đất liền và một đảo để làm chuẩn pipeline. | Người chơi nhận diện đặc trưng qua kiến trúc/địa hình/nội dung riêng có nguồn. Cảnh procedural chung chỉ mang nhãn minh họa, không tính thành số hóa địa danh hoàn thiện. |
| PO-06 | P1 / M | Hộ chiếu/nhật ký xem lại POI đã đến, lọc vùng và tiến trình. | Không nhân dấu, giữ ID ổn định và save cũ. Hoàn thành scene khác hoàn thành toàn tỉnh/đảo. |
| PO-07 | P1 / S–M | Danh mục tìm kiếm không dấu, lọc tỉnh/đảo/đã thăm, empty state rõ. | Tên có dấu vẫn hiển thị đúng; filter/search không làm mất cảnh/save, kiểm thử ví dụ Phú Quốc/phu quoc. |
| PO-08 | P0 phát hành / M–L | Playtest và profiling Android thực; iOS build/ký/test khi có môi trường. | Kiểm chứng mở lạnh offline, đa chạm, safe area, save/restore, FPS/RAM/nhiệt trên cấu hình nêu rõ. APK hoặc preset iOS không được tính là đã chạy trên điện thoại/iPhone. |
| PO-09 | P2 / M | Hoạt động ngắn gắn địa danh: quan sát chi tiết, chụp ảnh in-game hoặc nhiệm vụ tìm đường. | Không quay lại quiz làm cổng bắt buộc để đi bộ; cần nội dung đặc trưng và giấy phép tài nguyên trước triển khai. |

## Luồng trạng thái và quyết định

Trạng thái backlog: **Proposed → Ready → In progress → QA verified → PO accepted**. `Released/build available` là nhãn riêng, không thay cho hai cửa nghiệm thu QA và PO. Chưa ghi accepted/released nếu chưa có bằng chứng tương ứng.

PO-01/02/03 đã **QA verified / PO accepted cho phạm vi prototype desktop** trong iteration 0.3. Root báo desktop visual smoke `PO03_PASS`: thực hiện đi/nhìn/tương tác thật, chuyển sang POI chưa thăm kế tiếp, thay settings trực tiếp và giữ lựa chọn bóng khi đổi sang cảnh đảo. PO đã đối chiếu implementation với 17 AC của BA; chưa thấy blocker sản phẩm qua static review. Đây chưa phải xác nhận Android/iOS hoặc nghiên cứu người chơi. Tester đã báo 83 assertion mới và 174 assertion hồi quy liên quan, tổng **257 kiểm tra PASS** qua sáu suite trong đợt chạy mới; bao gồm integration/checkpoint/save legacy/navigation/preferences. PO chấp nhận 17 AC trong phạm vi logic/headless + desktop smoke được báo cáo. Root đã xác minh artifact APK 0.3 sẵn sàng ở local: **51.642.944 byte**, SHA256 `99649f3cb829098d8a7cbde8f06604a2320bed98ca3c0ed9df4197a0241eca99`. Chữ ký v2/v3 và alignment 16 KiB đạt; package/certificate khớp 0.2, versionCode 2→3. Đây là kiểm tra khả năng cập nhật của metadata, chưa phải cài đè thật trên thiết bị. Chưa ghi released trên GitHub khi URL remote chưa xác nhận. Nghiệm thu mobile và hiệu quả người chơi vẫn còn mở.

### Đối chiếu 17 AC — 06/11/2026

| AC trong PRODUCT.md | Bằng chứng hiện có | Trạng thái/cửa còn lại |
| --- | --- | --- |
| PO-01.A | Save v1 mở rộng tùy chọn; fixture 0.2 và kiểm thử startup có trong integration suite. | QA PASS: fixture 0.2 giữ dữ liệu lõi. |
| PO-01.B–D | Player phát tín hiệu chuyển động/nhìn thật; interaction dùng proximity guard. Root đã chơi chuỗi thật trên desktop. | QA PASS ngưỡng/input/proximity + desktop smoke verified. |
| PO-01.E–F | Status skipped/completed riêng; replay chỉ reset dữ liệu tutorial. | QA PASS skip khác completed/replay giữ progress. |
| PO-01.G | Checkpoint save tức thì khi step/status đổi; không ghi file mỗi frame tích lũy. | QA PASS checkpoint tức thì 0→1/1→2, restore và save cũ. |
| PO-02.A–B | Helper chọn nearest-unvisited XZ/hướng camera; HUD ghi khoảng cách trong cảnh minh họa. Root đã thấy chỉ dẫn trực tiếp. | QA PASS nearest XZ/bearing/đổi vùng + desktop smoke verified. |
| PO-02.C | Root đã tương tác và thấy mục tiêu kế tiếp. | QA PASS persistence/không nhân dấu + desktop smoke verified. |
| PO-02.D–E | Code xử lý hết mục tiêu, giữ interaction guard; không tự di chuyển/ghi dấu từ HUD. | QA PASS all-visited 3/3 và không tự ghi dấu. |
| PO-03.A–C | Root thấy settings UI áp dụng trực tiếp và giữ bóng qua cảnh đảo; preferences áp dụng cho world mới. | QA PASS live/scene/restart/độ nhạy + desktop smoke verified. |
| PO-03.D–E | Normalize trường tùy chọn, default ON/1×; modal cancel input hiện có. | QA PASS malformed optional/legacy/defaults và hồi quy input; đa chạm thiết bị còn mở. |

QA cuối đã bổ sung kiểm tra hồi quy bố cục settings sau lỗi geometry do root phát hiện và Dev sửa; integration có 38 kiểm tra. Xem [TEST_PLAN_3D.md](TEST_PLAN_3D.md) để biết phạm vi suite. Toàn bộ AC cần smoke lại trên Android thật, đặc biệt cảm ứng đa chạm, safe area, lifecycle save/restore và tương tác UI. iOS chưa được coi là verified. Không suy ra tăng FPS từ lựa chọn bóng; playtest onboarding và bằng chứng nhu cầu thị trường còn thiếu.

PO chốt thứ tự theo mục tiêu người dùng, ảnh hưởng, bằng chứng và chi phí trao đổi với SA/Dev. Khi có phản hồi thật, PO cập nhật giả thuyết và backlog; giữ decision log thay vì mô tả quyết định cũ là dữ kiện thị trường.


### Quyết định ưu tiên sau 0.3

**Quyết định trước khi người dùng duyệt vertical slice 0.4:** chọn PO-04 + PO-05 làm batch nội dung/dữ liệu kế tiếp, không mở thêm batch chỉ tiện ích UI. PO-04 là công việc nền để biết tập đảo nào thực sự còn thiếu; PO-05 chứng minh mỗi nơi có trải nghiệm riêng thay vì cảnh chung đổi tên. Hai luồng có thể song hành; PO-08 tiếp tục là cửa chất lượng phát hành.

Đầu ra nhỏ đầu tiên của PO-04: chốt dataset/version/license và quy tắc đối soát; manifest có ID ổn định, tên/alias, quan hệ đảo/quần đảo, nguồn cho từng bản ghi, tình trạng geometry và tình trạng cảnh vào được. Báo riêng tổng số bản ghi dữ liệu, bản ghi đối soát, cảnh dựng được và cảnh nội dung hoàn thiện; mẫu số “mọi đảo” chỉ được công bố khi nguồn và phạm vi được chốt. 13 vùng đảo hiện tại không tự thỏa AC này.

Đầu ra nhỏ đầu tiên của PO-05: BA/Designer đề xuất **một địa điểm đất liền và một đảo** dựa trên nguồn nội dung/tài nguyên hợp lệ; PO chốt sau rà nguồn và chi phí với SA/Dev. Mỗi mẫu cần landmark/địa hình phân biệt được, đường đi có collision, ít nhất ba POI có nội dung riêng và nguồn, vào được offline, giữ save ID ổn định. Chưa chọn địa điểm chỉ dựa tên sẵn trong registry; chưa tuyên bố số hóa đúng thực địa khi chỉ làm cảnh minh họa. Nghiệm thu hai mẫu mới mở rộng pipeline theo catalog.

Root xác minh artifact: APK không khai báo INTERNET, đóng gói 47 JSON/license, Android 7+ với armv7/arm64. Kiểm tra GUI mới sau sửa wrap dòng settings đạt và nút OK hiển thị. Các thông tin này không thay thử máy thật hoặc chứng minh mọi đảo đã được dựng.


## PO-10 — Vertical slice đèo và xe máy, iteration 0.4

**Trạng thái: Technical prototype accepted; P0 / L; art/device gates còn mở.** Người dùng đã duyệt bước khả thi của BA: chứng minh vòng **lái → dừng → tham quan** trên một đoạn đèo bằng xe máy. Quyết định này đưa PO-10 lên trước việc mở rộng PO-04/05; các yêu cầu địa lý/đảo vẫn còn trong backlog, không được ghi hoàn tất bởi slice. Hướng hình ảnh bán hiện thực theo cảm giác ảnh tham chiếu đèo Khánh Lê; đây là cảnh minh họa procedural, không phải bản sao GIS hoặc lời hứa photoreal.

### Phạm vi và AC chốt để triển khai

| AC | Điều kiện kiểm chứng |
| --- | --- |
| PO-10.A Đường và cảnh | Khu mẫu riêng, không thêm tỉnh thứ 48 hoặc đổi bounds của 47 cảnh địa lý hiện có. Một tuyến liên tục có chiều dài centerline **700–800 đơn vị scene**, mục tiêu 750, đi được từ đầu đến cuối. HUD/tài liệu gọi khoảng cách trong cảnh minh họa; không ghi chiều dài thực địa. Có khúc cua, thay đổi cao độ, mặt đường, sườn núi và mép đường/lan can có thể đọc được khi lái. Không cộng đường này vào coverage GIS hoặc toàn tỉnh. |
| PO-10.B Xe máy | Người chơi chủ động tăng ga, phanh và lái trái/phải; thả ga không làm tăng tốc, phanh từ vận tốc chạy làm giảm tốc tới dừng. Lái đổi hướng/vị trí; tốc độ hữu hạn theo cấu hình. Có reset về checkpoint an toàn gần nhất **đã đi qua theo tiến độ dọc tuyến** khi kẹt, không mất dấu tham quan. Không chọn checkpoint phía trước chưa tới chỉ vì gần hơn về khoảng cách; ví dụ checkpoint 0/230/550 và đang ở d=470 thì reset về 230, chưa qua 230 thì về 0, đã qua 550 thì về 550. Không yêu cầu mô phỏng cân bằng/ngã xe chân thực trong proof này. |
| PO-10.C Camera và input | Camera bám xe và nhìn được hướng chạy/khúc cua; có thao tác nhìn hoặc reset camera rõ. Keyboard có ga/phanh/trái/phải/tương tác; màn hình ngang có touch tương đương và hỗ trợ đồng thời ga+lái/phanh+lái. Mở modal hoặc mất focus hủy input đang giữ, không để xe tự nhận ga sau khi đóng. Giữ giới hạn camera hợp lệ và không nhìn xuyên địa hình nghiêm trọng tại các góc kiểm thử. |
| PO-10.D Traffic | Có ít nhất **2 xe traffic** vận hành trên tuyến định sẵn với seed/trạng thái ban đầu cố định; cùng seed và chuỗi bước simulation tạo cùng vị trí trong sai số kiểm thử đã nêu. Traffic không cần mạng. Collider thực khiến xe người chơi bị chặn/giảm chuyển động khi tiếp xúc xe traffic hoặc mép chắn đường; không chỉ có mesh trang trí. Không yêu cầu AI giao thông toàn thành phố. |
| PO-10.E Dừng và tham quan | Có ít nhất **2 điểm dừng** tách nhau dọc tuyến, có tên/nội dung riêng cho cảnh minh họa. Chỉ cho phép đỗ/xuống xe khi ở trong vùng dừng được định nghĩa rõ trong cấu hình và vận tốc xe **≤0,5 đơn vị scene/giây**; tương tác POI chỉ khi đang ở chế độ đi bộ và đủ gần POI theo proximity guard. Ngoài vùng hoặc đang chạy nhanh phải từ chối; HUD nói cần dừng/gần điểm. Tương tác mở nội dung và ghi dấu một lần; không tự đóng dấu chỉ vì chạy qua. |
| PO-10.F Chế độ tham quan | Sau khi đỗ đúng chỗ, người chơi có thể chuyển sang đi bộ để khám phá điểm dừng bằng điều khiển nhân vật hiện có, rồi trở lại xe để tiếp tục. Hai điểm phải cho phép hoàn thành vòng lái→dừng→đi bộ/tương tác→lái tiếp mà không đổi scene thủ công. Chuyển chế độ không phát sinh xe trùng hoặc reset dấu. |
| PO-10.G Save và offline | Toàn bộ tuyến/mesh/nội dung/traffic có sẵn offline. Save v1 thêm trường slice tùy chọn; save 0.2/0.3 không có trường này vẫn đọc được và giữ region/positions/visited/onboarding/preferences. Slice mới bắt đầu tại đầu tuyến; save mới giữ checkpoint hợp lệ gần nhất, chế độ về trạng thái an toàn khi mở lại, cùng dấu điểm dừng. Không bắt buộc khôi phục chính xác vị trí traffic. Trường slice lỗi được chuẩn hóa riêng, không xóa dữ liệu lõi. |
| PO-10.H Tài nguyên | Mesh/material procedural do team tạo hoặc tài nguyên có nguồn/license được ghi trong manifest; không dùng ảnh tham chiếu làm texture hay nhập asset chưa rõ quyền. Công bố rõ cảnh minh họa và phần nội dung chưa đối chiếu thực địa. |
| PO-10.I Desktop gate | QA kiểm chiều dài tuyến, input/ga-phanh/lái, collision traffic/mép đường, guard điểm dừng, chuyển xe/đi bộ, save legacy/restart và offline. Root chạy desktop render bằng input thật ít nhất một vòng tới điểm dừng và tiếp tục; ảnh tĩnh không thay test vòng chơi. Báo rõ logic test, render smoke và các lỗi còn mở. |
| PO-10.J Android artifact gate | APK phải build được, kiểm hash/chữ ký/alignment/package/version và tài nguyên đóng gói, không yêu cầu Internet cho vòng chơi. Giữ nhận diện ứng dụng/save tương thích cho update. Chỉ gọi Android artifact ready khi có file và kết quả kiểm; chạy được desktop hoặc có APK không đồng nghĩa đã kiểm điện thoại. iOS/device FPS/đa chạm thật/cài đè vẫn là cửa riêng PO-08, không được tự claim đạt. |

**Photo mode offline là optional/deferred:** không nằm trong cửa nghiệm thu 0.4; chỉ đưa vào nếu toàn bộ loop bắt buộc đã đạt và không trì hoãn QA. Không thêm nhiệm vụ đua xe, backend, multiplayer, download bản đồ, toàn bộ mạng đường Việt Nam hoặc cam kết 30 FPS trên mọi thiết bị vào batch này.

Thước đo proof: vòng bắt buộc hoàn thành được bằng điều khiển thật, hai điểm dừng có guard đúng, restart giữ checkpoint/dấu và save cũ không mất dữ liệu. Chưa có số liệu người dùng hoặc hiệu năng thiết bị để đặt lời hứa thương mại. BA/SA chốt chi tiết cấu hình, geometry và checkpoint trong phạm vi AC này; thay đổi bỏ khả năng đi bộ tại điểm dừng cần quay lại PO trước khi coi slice hoàn tất.

PO clarification 0.4: reset là latest-passed safe checkpoint, không phải nearest-absolute; mục đích không bỏ qua đoạn chưa lái. Đây là làm rõ hành vi hồi phục, không phép xóa dấu hoặc ghi thêm dấu. Hai POI phải có nội dung riêng phù hợp góc ngắm cảnh minh họa; tên khác nhưng cùng một đoạn mô tả không đạt PO-10.E.


### PO-10 — kết quả nghiệm thu prototype 0.4

PO chấp nhận **khả năng chơi của prototype kỹ thuật**, không chấp nhận rằng chất lượng hình ảnh tham chiếu bán hiện thực/photoreal đã đạt. QA báo **417 assertion PASS**: 160 kiểm tra mới và 257 hồi quy, gồm guard xuống xe/đi bộ/tương tác, hai mô tả điểm dừng riêng, save tương thích và reset latest-passed với ranh giới nghiêm ngặt. Root báo `PASS04_VISUAL_PASS` qua desktop GUI bằng input thật. Pilot script headless của root điều khiển xe vật lý từ s=5 đến s=738,02 qua 5.916 fixed ticks với traffic và không va chạm trong lượt đó; đây là công cụ kiểm thử, không phải tính năng tự lái hoặc benchmark hiệu năng.

| Cửa | Kết luận hiện tại |
| --- | --- |
| PO-10.A–G vòng chơi/logic/input/save | Technical prototype accepted dựa QA và desktop smoke; touch thiết bị thật vẫn chưa kiểm. |
| PO-10.H nguồn tài nguyên | Giữ yêu cầu procedural do team tạo hoặc license/provenance rõ; không dùng kết quả render để suy ra quyền tài nguyên hoặc GIS đúng thực địa. |
| PO-10.I desktop | Root báo GUI PASS; ảnh start/bend/viewpoint thể hiện prototype stylized có đường nhựa, sương, rừng và xe. Hướng hình ảnh tham chiếu chưa đạt; cần iteration mỹ thuật riêng có tiêu chí đối chiếu. |
| PO-10.J APK | Đang build; chưa gắn artifact ready cho 0.4 trước hash/signature/alignment/package kiểm xong. |
| Chất lượng thiết bị/sản phẩm | Android/iOS cài thật, đa chạm thật, FPS/nhiệt, upgrade thật và nghiên cứu người chơi chưa xác minh. Không công bố 30 FPS hoặc chất lượng bán hiện thực đã hoàn thành. |

Phần mở tiếp theo của slice: Designer xác định art gap từ ảnh tham chiếu và cảnh prototype, BA/SA/Dev đánh giá vật liệu/địa hình/thảm thực vật/ánh sáng trong ngân sách mobile, rồi PO chốt batch có bằng chứng hình ảnh và device profiling. Vẫn giữ PO-04/05 địa lý/nội dung và PO-08 device gates; nghiệm thu kỹ thuật này không đóng các yêu cầu toàn Việt Nam/đảo hoặc fidelity hình ảnh.
