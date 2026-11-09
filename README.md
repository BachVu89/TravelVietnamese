# Phượt Xuyên Việt — Painterly

Bản viết lại hoàn toàn mới trên Unity 6 URP, chơi offline, hướng tới Android và iOS. Source và asset của các bản trước đã được gỡ khỏi cây làm việc; vẫn có thể tra cứu lịch sử Git trước commit viết lại.

## Mở bản mới

1. Đóng project Unity cũ rồi cập nhật nhánh `codex-work`.
2. Trong Unity Hub chọn **Add → Add project from disk**, chọn **thư mục gốc TravelVietnamese**, nơi có `Assets`, `Packages`, `ProjectSettings`. Không mở đường dẫn `unity/TravelVietnamese` của bản cũ.
3. Dùng Unity **6000.0.32f1** và chờ Package Manager tải URP lần đầu. Sau đó game không cần mạng để chơi.
4. Mở scene `Assets/VietTrail/Scenes/Entry.unity`, hoặc menu **VietTrail → Open journey** để mở scene; nhấn Play.

Không cần mua plugin hay nhập các file Meshy cũ. Unity Editor có thể cần tải gói khi mở lần đầu; điều này tách biệt với gameplay offline.

## Phạm vi hiện tại

- Cảnh đèo miền Bắc minh họa: đường uốn cong, ruộng bậc thang, cây, núi, bãi dừng, xe và người dựng mới bằng mesh dùng palette màu chung.
- Shader stylized có ánh sáng, màu theo độ cao, sương mù và bầu trời ấm; không dùng vật liệu PBR của bản cũ.
- Lái xe, đi bộ ở bãi dừng, khám phá ba điểm, lưu tiến trình cục bộ và tải cảnh theo phân đoạn.
- Bản đồ tổng phục vụ chọn hành trình; danh mục 34 tỉnh/thành không đồng nghĩa đã có 34 màn chơi. Các điểm đảo còn trong kế hoạch. Địa hình minh họa chưa sử dụng DEM, không phải bản đồ địa lý chính xác.

Xem [yêu cầu và tiêu chí nghiệm thu](Docs/PRODUCT.md), [định hướng hình ảnh](Docs/ART_STYLE.md), [lộ trình](Docs/ROADMAP.md) và [kết quả kiểm tra](Docs/VALIDATION.md).

## Điều khiển

Trong cảnh lái xe: W ga, S phanh, A/D rẽ; F lên/xuống xe tại bãi nghỉ, E ghi dấu, R về điểm nghỉ đã qua. Khi đi bộ dùng WASD. Chuột phải để nhìn; điện thoại có nút cảm ứng. Bản đồ chọn chương hỗ trợ kéo để xoay, cuộn chuột hoặc hai ngón để zoom; các nút +/− và xoay là lựa chọn thay thế.

Bản đồ được dùng để chọn hành trình trước khi vào cảnh lái xe riêng, không phải thế giới mở toàn quốc thu nhỏ. Mây và xe trên bản đồ là chuyển động minh họa.

## Kiểm tra và build

`python3 Tools/VerifyProject.py` kiểm tra cấu trúc và tham chiếu asset. `Tests/run-core.sh` kiểm tra quy tắc thuần C#; `Tests/run-syntax.sh` kiểm tra cú pháp source. Các kiểm tra này **không thay thế compile, chạy và xem hình trong Unity**.

Máy đám mây hiện không có Unity Editor; chưa có APK/iOS build được xác nhận từ bản viết lại. Để build Android trên máy cá nhân, cài Android Build Support (SDK/NDK/OpenJDK) trong Unity Hub và dùng menu **VietTrail → Build Android APK**. iOS cần máy macOS với Xcode để đóng gói và ký ứng dụng.
