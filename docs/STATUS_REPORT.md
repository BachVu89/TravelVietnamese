# Báo cáo tiến độ Dọc miền Việt

**Ngày cập nhật: 06/11/2026 — giờ Việt Nam (UTC+7).**

**Bản đã giao gần nhất là 3D 0.3. Bản đang làm là 0.4:** lái xe máy trên một đoạn đèo minh họa, dừng xe và xuống đi bộ tham quan. Source/tài liệu đã được commit và đẩy lên nhánh phát triển **`codex-work`**. Nhánh phân phối APK là **`apk-download`**. Hai nhánh này có vai trò và tình trạng khác nhau, xem phần Git bên dưới.

## 1. Team đã làm được gì?

| Phiên bản | Nội dung đã có | Trạng thái và giới hạn |
| --- | --- | --- |
| **0.1 — prototype cũ** | Game mobile theo tuyến du lịch, câu hỏi văn hóa, dấu hộ chiếu và lưu tiến trình; có APK thử nghiệm. | Là bản quiz/Expo để tham khảo lịch sử. Không phải hướng khám phá 3D hiện tại. |
| **0.2 — nền game 3D** | Chuyển sang Godot: điều khiển nhân vật đi bộ, camera góc nhìn thứ ba, địa hình/va chạm, POI, lưu offline và đổi địa điểm. Danh mục 47 mục gồm 34 tỉnh/thành và 13 vùng đảo, mỗi mục vào được cảnh minh họa có ba POI. Có APK và gói source. | Phần lớn nội dung sinh bằng thuật toán; Hà Nội có khu mẫu riêng. Đây không phải toàn bộ địa hình hoặc công trình của mỗi tỉnh/đảo. |
| **0.3 — cải thiện trải nghiệm** | Hướng dẫn ba thao tác thật; chỉ tới POI chưa thăm gần nhất; bật/tắt bóng và ba mức nhạy camera; giữ save 0.2. Có APK/gói source đã phân phối trên GitHub. | PO nghiệm thu phạm vi logic/desktop. Chưa xác minh cảm ứng, hiệu năng hoặc cài đè trên điện thoại thực. |
| **0.4 — đang triển khai** | Đã viết các module đường đèo, xe máy, traffic, điểm dừng, tài nguyên minh họa, lưu checkpoint và tích hợp HUD/touch. | Đang kiểm tra tích hợp và vòng chơi render; chưa nghiệm thu toàn bộ, chưa có APK 0.4 để giao tại thời điểm báo cáo. |

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

## 3. Bản 0.4 đang làm cụ thể những gì?

Phạm vi đã chốt là một **mẫu riêng khoảng 750 đơn vị scene**, cửa nghiệm thu chiều dài centerline 700–800; không phải đo đường thực hoặc tái dựng GIS đèo Khánh Lê. Giữ Godot hiện tại để kiểm chứng trước khi cân nhắc thay engine.

| Hạng mục | Hiện trạng tại thời điểm báo cáo |
| --- | --- |
| Tuyến đường đèo | Đã có module tuyến cong, cao độ, mặt đường và bố cục cảnh; cấu hình mục tiêu 750 đơn vị. Còn kiểm geometry thực và chạy hết tuyến. |
| Xe máy/nhân vật | Đã có module ga, phanh, lái, vật lý/va chạm và hình nhân vật trên xe. Còn kiểm vòng chơi tích hợp và cảm giác điều khiển. |
| Giao thông | Đã có ba xe traffic theo tuyến; còn kiểm va chạm, fixed-step và tình huống thực trong vòng render. |
| Dừng và tham quan | Đã có hai điểm dừng và logic chuyển xe/đi bộ. AC yêu cầu dừng trong vùng, tốc độ ≤0,5 đơn vị/giây, xuống xe rồi đủ gần mới tương tác. Chưa tuyên bố toàn bộ AC đạt. |
| Hình ảnh | Đã có tài nguyên/vật liệu tạo bằng thuật toán để dựng cảnh. Chưa đạt hoặc được nghiệm thu photoreal như ảnh tham chiếu. |
| HUD và input | Root đã tích hợp HUD/touch vào vòng chính, kiểm parse; đang chạy kiểm tra render/tích hợp đầy đủ. |
| Lưu checkpoint | Đã có helper save riêng cho mẫu đèo; cần QA xác nhận restart và giữ nguyên save 0.2/0.3, tutorial/settings/dấu cũ. |
| APK/thiết bị | Chưa có artifact 0.4 đã hoàn tất kiểm tra để giao; chưa benchmark điện thoại/iOS. |

Photo mode/album được **hoãn khỏi cửa nghiệm thu 0.4**. Các module đã viết không đồng nghĩa phiên bản đã QA xong hoặc sẵn sàng phát hành. Tiêu chí chi tiết ở [PRODUCT.md — phần 0.4](PRODUCT.md) và [PO-10 trong backlog](PRODUCT_BACKLOG.md).

## 4. Phạm vi Việt Nam và đảo: đã đủ chưa?

**Chưa.** Registry hiện có **34 tỉnh/thành + 13 vùng đảo/đặc khu = 47 mục**. Tên có nguồn dataset cộng đồng được pin phiên bản/giấy phép; chưa đối soát trực tiếp đầy đủ mọi thông tin hành chính với văn bản nhà nước.

13 vùng đảo không phải 13 đảo đơn và không đại diện mọi đảo có tên của Việt Nam. Hiện còn thiếu catalog đầy đủ đảo thành phần, geometry/đường bờ/cao độ thực và nội dung đặc trưng từng nơi. Cảnh minh họa vào được không đồng nghĩa đã tái dựng địa phương chi tiết. Mẫu đèo 0.4 cũng không làm tăng độ phủ địa lý đã xác minh.

Team giữ rõ khoảng trống này trong [GEOGRAPHIC_SCOPE.md](GEOGRAPHIC_SCOPE.md); PO-04/05 về dữ liệu đảo và cảnh đặc trưng vẫn còn mở. Không công bố đã hoàn thành toàn quốc, mọi đảo hoặc địa hình thực địa.

## 5. Đang làm trên nhánh nào?

**Nhánh đang làm là [`codex-work`](https://github.com/BachVu89/TravelVietnamese/tree/codex-work)**. Theo yêu cầu người dùng, root đã tạo nhánh, commit source/tài liệu và push thành công lên GitHub, có tracking `origin/codex-work`.

| Nơi | Tên/trạng thái | Ý nghĩa |
| --- | --- | --- |
| Workspace phát triển và GitHub | **`codex-work`**, đã có commit và remote xác nhận. | Chứa source/tài liệu prototype cùng các thay đổi 0.4 đang phát triển; đây là nhánh để theo dõi công việc hiện tại. |
| Nhánh phân phối | **`apk-download`**. | Chứa APK, ZIP source 0.3 và tài liệu của lần phân phối; không phải nhánh source đang phát triển. |
| Nhánh `main` | **Chưa tồn tại trên remote** tại lần kiểm tra. | Không dùng `main` để tìm source hiện tại. |

Checkpoint source đầu tiên được push: [`35e7deceeb2d9d1986dcf93ac1bac8ed172931ee`](https://github.com/BachVu89/TravelVietnamese/commit/35e7deceeb2d9d1986dcf93ac1bac8ed172931ee), nội dung commit: `Checkpoint 3D prototype and mountain-pass development`. Trước checkpoint, workspace ở tên nhánh local `work` chưa có commit; tình trạng chưa bảo vệ source bằng commit này đã được xử lý. Cache, khóa ký và artifact build không đưa vào commit source.

Mốc phân phối 0.3 đã kiểm tra trên `apk-download`: `2f0346d5d417ee6f21fe0d1c41560b71376e1cc3`. Gói source ZIP 0.3 không chứa các thay đổi 0.4 mới. **Commit source đang phát triển không phải nghiệm thu hoặc phát hành 0.4**; báo cáo này có thể được cập nhật bằng commit tài liệu tiếp theo.

## 6. Xem bản đã giao ở đâu?

- [Đọc báo cáo này trên GitHub](https://github.com/BachVu89/TravelVietnamese/blob/codex-work/docs/STATUS_REPORT.md).
- [Source đang phát triển — `codex-work`](https://github.com/BachVu89/TravelVietnamese/tree/codex-work).
- [Nhánh phân phối GitHub `apk-download`](https://github.com/BachVu89/TravelVietnamese/tree/apk-download): bản 0.3 đã giao cùng APK, ZIP source và tài liệu. Đây là nơi xem/tải bản đã phân phối; source ZIP là snapshot đóng gói, không phải lịch sử commit source đang phát triển.
- [Tải APK 0.3 đã phân phối](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-0.3.0.apk).
- [Tải source ZIP 0.3 đã phân phối](https://github.com/BachVu89/TravelVietnamese/raw/refs/heads/apk-download/doc-mien-viet-3d-source-0.3.0.zip).
- File APK local: `artifacts/doc-mien-viet-3d-0.3.0.apk`.
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

Mốc gần nhất: hoàn thành kiểm tra vòng **lái → dừng → đi bộ/tương tác → trở lại xe**, QA cả hai điểm dừng, traffic/va chạm, save cũ và checkpoint; sau đó mới build/kiểm APK 0.4 và giao bản thử. Kiểm thử điện thoại Android/iOS và hiệu năng thực vẫn là cửa riêng, chưa có ngày/chi phí được cam kết. Các trạng thái trong báo cáo là snapshot, không phải hứa hẹn đã hoàn tất những bước còn chạy.

---

**Nguồn báo cáo:** kiểm tra Git do root xác nhận; `game3d/scripts/main.gd`, `mountain_pass.gd`, `pass/`, `road_save.gd`, `pass_materials.gd`; danh sách artifact local; `VALIDATION_0.3.md`, `PRODUCT.md`, `PRODUCT_BACKLOG.md`, `TEAM.md` và `GEOGRAPHIC_SCOPE.md`. Báo cáo này không thay đổi app code hoặc tự xuất bản source.
