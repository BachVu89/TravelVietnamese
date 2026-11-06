# Cài thử Dọc miền Việt trên Android

Yêu cầu Android 7.0 (API 24) trở lên. Hướng dẫn này áp dụng khi build đã tạo thành công file APK; xem trạng thái thực tế trong [VALIDATION.md](VALIDATION.md).

1. Chép hoặc tải `artifacts/doc-mien-viet-0.1.0.apk` vào điện thoại.
2. Mở file APK trong trình quản lý tệp hoặc mục Tải xuống.
3. Nếu Android yêu cầu, cho phép ứng dụng đang mở file cài ứng dụng từ nguồn này, rồi chọn **Cài đặt**.
4. Mở **Dọc miền Việt** từ danh sách ứng dụng.

Bản APK thử nghiệm được build ở chế độ release, chứa mã game và dữ liệu ngay trong gói cài, nhưng dùng khóa ký debug để cài thử nội bộ. Không cần Expo Go, Metro, tài khoản hoặc máy chủ để chơi. Đây chưa phải bản phân phối Google Play.

## Kiểm tra nhanh trên điện thoại

- Bật chế độ máy bay, tắt hẳn game và mở lại.
- Ở Hà Nội, thử một đáp án sai rồi chọn **Hồ Hoàn Kiếm**. Nhận dấu và 80 xu.
- Chọn chặng Hạ Long, chọn phương tiện và kiểm tra ngân sách giảm đúng giá hiển thị.
- Mở Hộ chiếu và Nhật ký để kiểm tra dấu cùng chi tiêu.
- Tắt hẳn game, mở lại và kiểm tra tiến trình còn nguyên.
- Trong Nhật ký, thử hủy thao tác bắt đầu lại; chỉ khi xác nhận thì hành trình mới được xóa.

Nếu điện thoại báo không cài được, hãy ghi lại thông báo, phiên bản Android và model máy để kiểm tra tương thích. Nếu đã cài một bản cùng application ID nhưng khác khóa ký, Android có thể yêu cầu gỡ bản cũ trước; gỡ ứng dụng sẽ xóa tiến trình đã lưu.
