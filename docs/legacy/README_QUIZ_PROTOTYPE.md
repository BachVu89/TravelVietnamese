# Dọc miền Việt

Game khám phá Việt Nam một người chơi dành cho Android và iOS, xây bằng Expo, React Native và TypeScript. Bản MVP kết hợp hành trình Bắc–Trung–Nam, câu chuyện của nhân vật An, lựa chọn phương tiện theo ngân sách, câu đố văn hóa và sưu tập dấu hộ chiếu.

## Chạy để phát triển

Yêu cầu Node.js 22 LTS trở lên và npm. Trong repository:

```sh
cd /workspace/TravelVietnamese
npm ci
npm start
```

`npm start` khởi động Metro ở chế độ offline. Expo Go trên điện thoại phải có phiên bản tương thích Expo SDK 54 và kết nối được với máy chạy Metro. Trong môi trường cloud, có thể kiểm tra bản web bằng `npm run web`; việc kết nối điện thoại tới Metro cần cấu hình mạng riêng. Chế độ offline của CLI không thay thế bản cài độc lập.

```sh
npm run typecheck
npm test
npm run export:web
```

## Android và iOS

Quy trình APK thử nghiệm: [build Android](docs/ANDROID_BUILD.md), [cài trên điện thoại và kiểm tra offline](docs/APK_INSTALL.md). File đầu ra nằm tại `artifacts/doc-mien-viet-0.1.0.apk` khi build thành công.

Chung một mã nguồn cho hai nền tảng. Máy đã có Android SDK/emulator có thể dùng `npx expo run:android`; macOS có Xcode có thể dùng `npx expo run:ios`. Các lệnh này tạo thư mục native và cần tải công cụ/phụ thuộc trong lần build đầu.

Để phát hành, tạo bản release có JavaScript và tài nguyên đóng gói bằng quy trình Expo/EAS hoặc native. iOS cần macOS/Xcode hoặc dịch vụ build macOS; phân phối lên thiết bị/App Store cần tài khoản và chứng chỉ Apple. Repository chưa chứa khóa ký hay cấu hình tài khoản cửa hàng.

Yêu cầu chơi offline áp dụng cho bản cài độc lập: không backend, không đăng nhập, không GPS, không tải nội dung/font khi chơi. Tiến trình lưu trên thiết bị bằng AsyncStorage; gỡ ứng dụng hoặc xóa dữ liệu có thể mất tiến trình. Kiểm thử bản native ở chế độ máy bay vẫn cần thực hiện trước phát hành.

## Nhóm và tài liệu

- BA: [Yêu cầu sản phẩm](docs/PRODUCT.md).
- SA: [Kiến trúc và lưu trữ offline](docs/ARCHITECTURE.md).
- Designer: [Thiết kế trải nghiệm và giao diện](docs/DESIGN.md).
- Developer: `App.tsx` và `src/`.
- Tester: [Kế hoạch kiểm thử](docs/TEST_PLAN.md) và `tests/`.

Xem [kết quả kiểm tra thực tế và ảnh giao diện](docs/VALIDATION.md) để biết phần đã xác minh và những bước còn cần chạy trên thiết bị.

Đây là bản chơi thử, chưa phải bản phát hành trên Google Play/App Store. Sơ đồ hành trình chỉ minh họa các điểm du lịch, không phải bản đồ hành chính hay công cụ chỉ đường. Nội dung văn hóa cần được biên tập, kiểm chứng trước khi phát hành công khai.
