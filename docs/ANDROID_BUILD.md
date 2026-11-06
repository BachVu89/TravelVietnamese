# Build APK Android để thử nghiệm

APK dùng release variant có JavaScript/Hermes bundle nhúng, không cần Metro hoặc Expo Go sau khi cài. Expo Updates đã tắt trong `app.json`. Bản này ký bằng **debug key của template Android**, chỉ để cài thử; không phải bản phát hành Google Play. Không dùng khóa này để phát hành sản phẩm.

## Công cụ

- Node/npm và dependencies từ `npm ci`.
- JDK 17 đầy đủ `javac` để chạy Gradle và biên dịch plugin React Native. JRE 21 có sẵn trong máy không đủ compiler cho Android build. Temurin 17.0.17+10 được cài tại `/workspace/java/jdk-17.0.17+10`, kiểm tra SHA256 từ GitHub release chính thức. Đặt `TRAVEL_JDK17_HOME` nếu dùng vị trí khác. Không cần Foojay tự tải toolchain.
- Gradle 8.14.3 từ wrapper; SHA256 chính thức được ghim trong `android/gradle/wrapper/gradle-wrapper.properties`.
- Android SDK tại `/workspace/android-sdk`: platform 36, build-tools 35.0.0 và 36.0.0, platform-tools, NDK 27.1.12297006, CMake 3.22.1.

Android command-line tools được tải từ `https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip`; checksum được đối chiếu với metadata chính thức `repository2-1.xml` trước khi giải nén. SDK Manager cài các package bằng proxy HTTP được cung cấp, giữ TLS và checksum mặc định.

## Mạng cần cho build

Ngoài các preset package manager (Google Android SDK, Gradle và Maven Central), Maven Central hiện redirect các AAR React Native/Hermes 0.81.5 sang `repo.reactnative.dev`. Domain này cần được cho phép trong cấu hình mạng môi trường. HTTP 403 từ proxy tại redirect đó là lỗi quyền truy cập mạng; không tắt TLS hoặc dùng đường kết nối trực tiếp để vượt qua.

## Tạo lại APK

```bash
cd /workspace/TravelVietnamese
ANDROID_HOME=/workspace/android-sdk ./scripts/build-android-apk.sh
```

Script sử dụng project `android/` đã sinh từ Expo, build `assembleRelease` với tối đa 3 worker và heap 4 GiB. Gradle lấy dependency qua proxy từ `HTTPS_PROXY` nếu biến này được cung cấp. CA trust của môi trường phải được giữ nguyên. Không đặt credential vào script.

Nếu phải cài SDK trên máy mới, cài Android command-line tools từ nguồn chính thức và dùng SDK Manager:

```bash
sdkmanager --sdk_root="$ANDROID_HOME" \
  'platform-tools' 'platforms;android-36' 'build-tools;35.0.0' 'build-tools;36.0.0' \
  'ndk;27.1.12297006' 'cmake;3.22.1'
```

Đọc và chấp nhận license SDK khi được yêu cầu. Trong môi trường cloud dùng proxy, thêm `--proxy=http --proxy_host=proxy --proxy_port=8080` cho SDK Manager. Không tắt xác minh TLS.

Đầu ra: `artifacts/doc-mien-viet-0.1.0.apk` và checksum `.apk.sha256`. Universal APK chứa arm64-v8a, armeabi-v7a, x86, x86_64. Android tối thiểu do React Native xác định (API 24 / Android 7 trở lên).

## Kiểm tra và cài

```bash
python scripts/verify-apk.py artifacts/doc-mien-viet-0.1.0.apk
adb install -r artifacts/doc-mien-viet-0.1.0.apk
```

Khi cài thủ công, tải APK xuống điện thoại và cho phép ứng dụng tải tệp cài từ nguồn đó. Sau cài đặt, tắt mạng, mở ứng dụng, trả lời câu hỏi đầu tiên, đóng/mở lại để kiểm tra lưu tiến trình. Xác minh chữ ký/bundle trên máy build không thay cho kiểm thử trên điện thoại thực.
