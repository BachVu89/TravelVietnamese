# Kế hoạch kiểm thử — Dọc miền Việt

Mục tiêu: xác minh vòng chơi khám phá → chọn phương tiện → câu đố → nhận dấu hộ chiếu và lưu tiến trình, kết hợp cốt truyện, nhiệm vụ và quản lý ngân sách. Đây là kế hoạch cho MVP, không phải chứng nhận đã kiểm thử trên thiết bị.

## Kiểm thử tự động

Suite `tests/game.test.ts` tập trung vào quy tắc domain độc lập giao diện:

- Chi phí phương tiện được trừ đúng; không cho phép số dư âm hoặc chi tiêu khi chưa đủ tiền.
- Chặng bị khóa không thể đi trước điều kiện mở khóa; lựa chọn không hợp lệ không làm hỏng tiến trình.
- Trả lời đúng/sai thay đổi phần thưởng đúng quy tắc; không nhận tiền hoặc dấu nhiều lần từ cùng câu hỏi.
- Dữ liệu lưu hợp lệ được khôi phục; dữ liệu thiếu, sai kiểu hoặc không hợp lệ được xử lý an toàn.

Kết quả đã chạy: `npm test` — **15 test đạt, 0 lỗi, 0 bỏ qua**. Suite thực sự thực thi từng test (không chỉ tải file). Lệnh cần quyền tạo IPC socket cục bộ của `tsx` trong sandbox hiện tại; đã chạy thành công với quyền phù hợp. Có thể chạy trực tiếp `node tests/game.test.ts` bằng Node 24, cũng thực thi đủ 15 test.

Phạm vi bản chơi thử hiện tại: **một câu hỏi cho mỗi điểm đến**, trả lời đúng nhận một dấu và thưởng một lần; trả lời sai có thể thử lại. Chưa có bộ ba câu, ngưỡng điểm hoặc hệ thống điểm tốt nhất. Các trường hợp tự động kiểm tra trên đúng quy tắc một câu này, không xác nhận những tính năng chưa triển khai.

Đã kiểm chứng đủ tám điểm đến với từng chiến lược phương tiện cố định, bao gồm chọn máy bay cho toàn bộ bảy chặng; ngân sách không âm. Kiểm tra khôi phục gồm JSON round-trip, bản sao độc lập, sai phiên bản, dấu lặp/sai thứ tự, số dư giả mạo và chuyến đi có dữ liệu sai hoặc `null`.

## Ma trận kiểm thử thủ công bắt buộc trước phát hành

Chạy trên ít nhất một thiết bị Android và một thiết bị iOS thực; thêm một màn hình nhỏ và một màn hình lớn. Các mục dưới đây **chưa chạy** cho tới khi có bằng chứng thiết bị/build tương ứng.

| Trường hợp | Các bước | Kết quả mong đợi |
| --- | --- | --- |
| Khởi chạy offline | Cài bản native; bật chế độ máy bay; đóng và mở app | Giao diện, dữ liệu, câu đố và minh họa hoạt động mà không tải mạng |
| Vòng chơi đầu tiên | Đọc nhiệm vụ; chọn điểm đến/phương tiện; trả lời câu hỏi | Nội dung rõ ràng; tiền, vị trí, nhiệm vụ và dấu nhất quán |
| Xuyên Việt | Hoàn thành tất cả chặng theo tuyến Bắc → Nam | Không có chặng bị kẹt do kinh tế; trạng thái hoàn thành được hiển thị |
| Trả lời sai | Chọn đáp án sai rồi thực hiện hành động mà UI cho phép | Phản hồi rõ; không nhân thưởng; luôn có đường tiếp tục hợp lệ |
| Ngân sách | Thử phương tiện đắt hơn số dư và nhấn nhanh nhiều lần | Không tiền âm; không di chuyển hoặc nhận thưởng trùng |
| Lưu và khôi phục | Hoàn thành một chặng; force-stop app; mở lại khi offline | Tiền, điểm đến, dấu và nhiệm vụ khớp trạng thái trước đó |
| Khởi động chậm/lỗi lưu | Mô phỏng storage chậm hoặc lỗi | Không ghi đè save bằng trạng thái mới trước khi tải xong; có phản hồi lỗi |
| Xóa tiến trình | Chọn đặt lại; hủy; rồi xác nhận đặt lại | Hủy giữ nguyên dữ liệu; xác nhận đưa về trạng thái ban đầu và lưu được |
| Trợ năng | VoiceOver/TalkBack; chữ lớn; tương phản; vùng chạm | Nhãn đọc được, thông tin không chỉ dựa vào màu, chữ không che hành động |
| Gián đoạn | Chuyển nền/tiền cảnh, đổi tab, xoay màn hình nếu được hỗ trợ | Không crash; không mất trạng thái hoặc áp dụng giao dịch hai lần |

## Ranh giới xác minh

Typecheck và kiểm thử domain không thay thế kiểm thử giao diện/native. Bản web chỉ giúp kiểm tra smoke test; không chứng minh AsyncStorage, đóng gói offline, Android hoặc iOS đã hoạt động trên thiết bị. Chỉ báo cáo số test thực sự chạy và kết quả riêng cho từng nền tảng.

## Rà soát cấu hình APK Android

Đã kiểm tra tĩnh cấu hình nguồn Android và hướng dẫn build/cài: application ID `com.travelvietnamese.docmienviet`, version `0.1.0`, release variant ký bằng debug key để cài thử nội bộ. `bundleCommand=export:embed` cấu hình nhúng mã game; Expo Updates tắt trong cả app config và manifest. Giao diện/nội dung game không gọi tải tài nguyên mạng; tiến trình dùng AsyncStorage. Quyền `INTERNET` vẫn có trong manifest nhưng không tự tạo yêu cầu mạng cho vòng chơi.

Các cấu hình này thống nhất với `docs/APK_INSTALL.md` và `docs/ANDROID_BUILD.md`. SDK tối thiểu là API 24 (Android 7); target/compile SDK 36. Đây là kết quả rà soát cấu hình, **chưa thay thế xác minh APK thực tế, chữ ký, cài đặt hoặc khởi chạy native**. Những kiểm tra artifact và thiết bị chỉ được ghi đạt sau khi thực thi riêng.

## Xác minh artifact APK ngày 05/11/2026

`assembleRelease` đã thành công. File `artifacts/doc-mien-viet-0.1.0.apk` được kiểm tra bằng `scripts/verify-apk.py`: chữ ký v2, tính toàn vẹn ZIP, manifest release không debuggable, mã game nhúng và bốn ABI đều đạt. `sha256sum -c` đạt; minSdk24/targetSdk36 và app ID/version đúng. Manifest thực không chứa bốn quyền không dùng đã chặn. Kết quả này xác minh file APK; toàn bộ ma trận cài đặt/khởi chạy trên điện thoại vẫn **chưa chạy**.
