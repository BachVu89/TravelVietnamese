# Nghiên cứu sản phẩm — vòng PO đầu tiên

Ngày đọc nguồn: **05/11/2026**. Phạm vi: tìm pattern giúp người chơi mới hiểu và điều khiển game khám phá 3D offline; đối chiếu với khoảng trống của Dọc miền Việt 3D 0.2.0. Kết quả này là **desk research định tính và benchmark sản phẩm**, chưa phải xác nhận nhu cầu thị trường hoặc product–market fit.

## Điều đã và chưa nghiên cứu

Đã đọc sáu tài liệu/source chính thức của ba dự án công khai. Mỗi nguồn có URL bất biến theo commit, ngày đọc và SHA256 trong [source_manifest.json](source_manifest.json). Đã rà code hiện tại `main.gd`, `player.gd`, `save_store.gd` và tài liệu sản phẩm/thiết kế/phạm vi địa lý.

Chưa đọc được một tập đánh giá App Store/Google Play đại diện; chưa phỏng vấn người chơi, đo retention, doanh thu, lượt cài, thị phần hoặc mức sẵn sàng trả tiền. Các dự án dưới đây là **sản phẩm thay thế/lân cận** về thế giới 3D và khám phá, không phải bộ đối thủ trực tiếp của game du lịch Việt Nam trên mobile. Không suy ra mức phổ biến hoặc hiệu quả UX chỉ từ việc một tính năng tồn tại. Không thu thập tài khoản hay liên hệ người chơi trong vòng nghiên cứu này.

## Bằng chứng đã đọc

| Nguồn | Quan sát có thể kiểm chứng | Bài học có thể chuyển giao | Giới hạn |
| --- | --- | --- | --- |
| Luanti — [README, S1](https://github.com/luanti-org/luanti/blob/b4c73357a6159e48810dea24428f3ebaa24dd345/README.md) | Dự án tự mô tả là engine game voxel mã nguồn mở. README có điều khiển di chuyển/nhìn, pause singleplayer, minimap và cấu hình lại điều khiển. | Điều khiển và định hướng cần được đưa thành trải nghiệm dễ hiểu, có cách điều chỉnh. | Không chứng minh game du lịch cần voxel, xây dựng hoặc multiplayer. |
| Luanti — [settingtypes, S2](https://github.com/luanti-org/luanti/blob/b4c73357a6159e48810dea24428f3ebaa24dd345/builtin/settingtypes.txt) | Có `touch_controls`, `touchscreen_sensitivity`, ngưỡng di chuyển cảm ứng và `enable_dynamic_shadows`; mô tả shadow texture lớn tốn chi phí hơn. | Độ nhạy cảm ứng và lựa chọn bóng là các tùy chỉnh thực dụng. | Sự tồn tại của tùy chọn không chứng minh FPS của Dọc miền Việt sẽ tăng bao nhiêu. |
| Veloren — [README, S3](https://github.com/veloren/veloren/blob/cd75076cf157d47c97bdf21c5bd7012cc4959dfc/README.md) | Game tự mô tả action-adventure RPG trong thế giới fantasy lớn; README nêu các bản Windows/macOS/Linux. | Có thể tham khảo cách tạo động lực khám phá trong thế giới 3D. | Không dùng làm bằng chứng hỗ trợ mobile, offline hoặc du lịch thực địa. |
| Veloren — [HUD localization, S4](https://github.com/veloren/veloren/blob/cd75076cf157d47c97bdf21c5bd7012cc4959dfc/assets/voxygen/i18n/en/hud/misc.ftl) | Có nhãn tutorial, quest, waypoint, diary; lời dẫn đầu hành trình chỉ người chơi hành động trong làng và dùng bản đồ. | Sau khi vào cảnh, người mới cần một việc cụ thể để làm và một mục tiêu để đi tới. | Đây là chuỗi giao diện trong source, không phải nghiên cứu người dùng hoặc xác minh end-to-end mọi tính năng. |
| Veloren — [settings localization, S5](https://github.com/veloren/veloren/blob/cd75076cf157d47c97bdf21c5bd7012cc4959dfc/assets/voxygen/i18n/en/hud/settings.ftl) | Có pan/zoom sensitivity, camera smoothing, shadow rendering None/Cheap/Map và nhiều mức graphics. | Tách sở thích điều khiển với độ phức tạp đồ họa; bắt đầu bằng vài lựa chọn rõ ràng. | Không sao chép toàn bộ menu hoặc gán các mức chất lượng tương đương giữa hai engine. |
| Terasology — [README, S6](https://github.com/MovingBlocks/Terasology/blob/f1da4d47f84e6343bb74ff8e62ae2f6dbe72b485/README.md) | Dự án bắt đầu từ tech demo lấy cảm hứng Minecraft và phát triển thành nền tảng các kiểu gameplay trong thế giới voxel; hướng dẫn cài đặt nêu desktop 64-bit. | Một tech demo cần vòng chơi và nội dung riêng để thành sản phẩm rõ mục đích. | Không chứng minh nhu cầu du lịch Việt Nam; không dùng để suy ra Android/iOS đã khả thi. |

Các URL 404 thử trong quá trình tìm file không được tính là nguồn bằng chứng. Không nhập source/art/tài nguyên của các dự án tham chiếu vào game; chỉ tổng hợp quan sát tính năng và dẫn nguồn.

## Khoảng trống quan sát trực tiếp ở 0.2.0

| Code/tài liệu đã rà | Quan sát | Kết luận được phép |
| --- | --- | --- |
| `main.gd::_ready`, `_build_ui` | Mở thẳng vào scene, có dòng hướng dẫn tĩnh; chưa có chuỗi hành động lần đầu được xác nhận. | Có khoảng trống onboarding trong implementation, chưa biết bao nhiêu người chơi thực gặp khó. |
| `main.gd::_process`, `world.gd::nearest_poi` | Nút khám phá chỉ hiện khi gần POI; hint là đi gần cột vàng và đếm dấu. | Chưa có mục tiêu chưa thăm + khoảng cách/hướng để hỗ trợ tìm đường trong scene. |
| `player.gd::look`, `world.gd::build` | Độ nhạy cố định, bóng bật khi dựng world. | Người chơi chưa tự điều chỉnh hai tham số này trong game. |
| `sources.json`, `GEOGRAPHIC_SCOPE.md` | Registry 34 tỉnh/thành + 13 vùng đảo; không đầy đủ mọi đảo có tên, chưa có geometry/địa danh thực đầy đủ. | Đây là khoảng trống chiến lược cốt lõi; các cải tiến UX không thay thế việc hoàn thiện dữ liệu và nội dung Việt Nam. |

## Quyết định PO cho iteration 0.3

Chọn **PO-01 onboarding tương tác**, **PO-02 chỉ dẫn POI chưa thăm**, **PO-03 tùy chọn bóng/độ nhạy** để biến bản đi bộ hiện tại thành vòng trải nghiệm dễ hiểu và dễ kiểm thử hơn. Đây là giả thuyết giải pháp, đã được root chấp thuận trong phạm vi phát triển; chưa phải nhu cầu được người chơi xác nhận. Acceptance criteria nằm trong [PRODUCT_BACKLOG.md](../PRODUCT_BACKLOG.md) và đặc tả BA.

Giữ hai ưu tiên chiến lược ngay sau batch này: **PO-04 dữ liệu đảo có tên/nguồn/coverage** và **PO-05 cảnh, landmark, nội dung riêng từng địa danh**. Không dùng nhiều scene chung đổi tên để tuyên bố hoàn thành du lịch xuyên Việt.

## Kế hoạch kiểm chứng tiếp theo

1. Playtest nhỏ, có sự đồng ý của người tham gia, trên điện thoại thật: người mới tự đi, xoay camera và khám phá POI đầu tiên. Mục tiêu giả thuyết: ít nhất 4/5 người làm được trong 2 phút mà không cần người hướng dẫn nói thay UI. Chưa thực hiện hoặc đạt mục tiêu này.
2. Cho người chơi tìm POI thứ hai bằng HUD; ghi thời gian, lần đi nhầm và nhận xét bằng quan sát thủ công. So sánh bản 0.2/0.3 trong cùng cảnh; chưa định nghĩa hay tuyên bố uplift retention.
3. Thử độ nhạy ba mức và shadows ON/OFF trên ít nhất hai cấu hình Android thực. Đo frame time/nhiệt và chất lượng nhìn; chưa cam kết mức tăng FPS.
4. Mở rộng nghiên cứu đối thủ trực tiếp/ứng dụng du lịch tương tác bằng trang cửa hàng chính thức và mẫu review có ngày/phiên bản, trong giới hạn quyền mạng. Không coi nguồn GitHub hiện tại là đủ đại diện thị trường mobile.
5. Kiểm duyệt dữ liệu địa lý với nguồn thích hợp và người am hiểu nội dung; xác lập bộ đảo có tên, alias/ID và geometry trước khi công bố coverage đầy đủ.

Không thêm analytics mạng vào game offline để làm các bước trên. Nếu cần telemetry trong tương lai phải là yêu cầu sản phẩm riêng, có lựa chọn/đồng ý phù hợp; hiện dùng test và quan sát thủ công.


## Cập nhật triển khai — 06/11/2026

Batch PO-01/02/03 đã được hiện thực hóa và root báo smoke trực quan desktop đạt ở các hành động chính; Tester báo 257 kiểm tra logic/integration/hồi quy PASS qua sáu suite; PO đã accepted phạm vi prototype desktop. Điều này xác minh khả năng triển khai của giải pháp ở mức hiện tại, **không xác minh giả thuyết 4/5 người tự học trong 2 phút, retention, nhu cầu thị trường hoặc hiệu năng điện thoại**. Không có nguồn thị trường mới được thêm trong cập nhật này; ngày đọc và provenance của sáu nguồn giữ nguyên 05/11/2026. Ưu tiên nghiên cứu/nội dung tiếp theo là PO-04 danh mục đảo có nguồn và PO-05 cảnh đặc trưng, đồng thời tiến hành playtest/profiling thiết bị khi có bằng chứng thực tế.
