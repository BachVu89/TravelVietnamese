# Dọc miền Việt — Unity 6 / C#

Source project mới: `TravelVietnamese/`.

- Editor mục tiêu: **Unity 6.0 LTS `6000.0.32f1`**.
- Pipeline mobile: **URP `17.0.3`**, package version được ghim trong manifest.
- Input runtime: legacy `UnityEngine.Input`; bootstrap cần Active Input Handling phù hợp.
- **Chưa có Unity Editor tại đây:** chưa resolve package, import/compile project, tạo scene/material, chạy physics/render, build APK/IPA hoặc thử thiết bị. Cặp Editor/package vẫn cần xác minh trong Editor thực.

HDRP không hỗ trợ Android/iOS cho mục tiêu game mobile này. Yêu cầu HDRP được triển khai dưới dạng companion source desktop riêng qua `scripts/create-unity-hdrp-reference.py`; project mobile không cài HDRP song song URP. Chưa có asset/plugin Asset Store/Quixel được mua hoặc tải, và chưa xác minh compatibility/license hiện hành của các lựa chọn đó.

## Mở và kiểm tra khi có Editor

1. Cài Unity Hub/Editor phiên bản ghim từ nguồn chính thức với license phù hợp.
2. Chọn **Add project from disk** tới `unity/TravelVietnamese`, mở và kiểm tra Package Manager/Console.
3. Resolve URP đúng version, chạy bước bootstrap Editor của repository để tạo scene/material và gán pipeline asset; kiểm tra Graphics/Quality và Active Input Handling. Mã bootstrap chưa phải scene đã được tạo.
4. Chạy vòng chơi đoạn đèo mẫu trong Editor rồi kiểm tra collision/input/save bằng test phù hợp.
5. Thêm Android/iOS Build Support và toolchain Unity yêu cầu. Build standalone, cài thiết bị và thử mở lạnh offline. iOS còn cần macOS/Xcode và signing phù hợp.

Godot APK trước đây giữ nguyên và không phải APK Unity. UE scaffold trước đây là lịch sử phương án, không được port tự động. Mục tiêu đầu là một đoạn đèo kiểm chứng được trước khi mở rộng tỉnh/đảo; chưa cam kết chất lượng 95% ảnh hoặc hiệu năng trên máy 8 GB.

Xem [UNITY_MIGRATION.md](../docs/UNITY_MIGRATION.md) về kiến trúc, HDRP/URP, cổng nghiệm thu, asset/license và save/import.

## Hai project, hai mục tiêu

- **URP mobile:** `TravelVietnamese/`, URP `17.0.3`, Android/iOS offline.
- **HDRP desktop companion:** `TravelVietnamese-HDRP/`; generator `scripts/create-unity-hdrp-reference.py` sao chép shared runtime và ba FBX nguyên gốc, ghim Unity `6000.0.32f1` + HDRP `17.0.3`, không sao chép URP Editor bootstrap. Shared runtime không phụ thuộc HDRP API. Companion chưa import/compile/render trong Unity.

Trước chạy bootstrap desktop, mở companion trong Editor và hoàn tất **HDRP Wizard**, tạo/gán pipeline asset HDRP. Bootstrap có guard yêu cầu pipeline đã cấu hình; manifest/package không thay bước này. Đừng dùng companion để build mobile hoặc coi HDRP tự đem lại 95% chất lượng ảnh.

Từ gốc repository, các lệnh mobile có sẵn:

```bash
python scripts/build-unity.py --editor /path/to/Unity --target scene --check-only
python scripts/build-unity.py --editor /path/to/Unity --target scene
python scripts/build-unity.py --editor /path/to/Unity --target android
```

Thiếu Editor trả exit code 2 và không build. `--check-only` không xác minh version/license/modules/packages. 60 checks domain C# đã chạy đạt bằng .NET, không phải Unity/physics/render/device tests. Tải Unity chính thức đang bị proxy CONNECT 403; thiếu Editor và activation hợp lệ vẫn chặn compile/build. Chưa có APK/IPA Unity hoặc screenshot HDRP.

Tham khảo [yêu cầu hệ thống HDRP chính thức](https://raw.githubusercontent.com/Unity-Technologies/Graphics/master/Packages/com.unity.render-pipelines.high-definition/Documentation~/System-Requirements.md): nguồn ở `master`, không phải chứng nhận compatibility package ghim `17.0.3`.

Companion thực tế ở `unity/TravelVietnamese-HDRP/`. Generator từ chối ghi đè project đã tồn tại; muốn cập nhật shared runtime/FBX, tạo snapshot ở thư mục tạm rồi review diff để giữ công việc artist desktop. Chạy `python scripts/create-unity-hdrp-reference.py --verify` chỉ kiểm tra parity source, không compile/render.

Sau khi đã mở Editor và hoàn tất HDRP Wizard:

```bash
python scripts/build-unity.py --editor /path/to/Unity --profile hdrp --target scene
```

Lệnh gọi `TravelVietnamese.Editor.DesktopPassSetup.CreateDesktopPass`; chưa có entrypoint build player desktop. `--profile hdrp --target android` bị chặn rõ ràng. HDRP sky/fog/clouds cần global Volume được cấu hình trong Editor; legacy `RenderSettings.fog` không tạo volumetric fog HDRP. Source scene generator không đồng nghĩa pipeline/scene/material `.asset` đã tồn tại.

## Package Manager báo dependency không tìm thấy

Đóng Editor/nhấn **Quit**, cập nhật `codex-work`, rồi mở đúng thư mục `unity/TravelVietnamese`. Đã bỏ khai báo sai `com.unity.modules.inputlegacy`; legacy Input là cài đặt Editor, không phải package cần tải. Sau khi cập nhật manifest, nếu lock/cache vẫn giữ dependency lỗi, đóng Editor rồi đổi tên `Packages/packages-lock.json` và thư mục `Library` để Unity tạo lại. Không xóa `Assets` hoặc `ProjectSettings`.

Ảnh lỗi của người dùng còn có `com.unity.modules.adaptiveperformance`, `com.unity.modules.physicscore2d`, `com.unity.modules.textgen`; các mục này không có trong manifest source team. Nếu bản local có chúng, dùng manifest đã cập nhật của đúng project, sau khi lưu lại bản local để giữ các dependency riêng. Không đổi tên chúng sang package khác một cách máy móc. Nếu vẫn lỗi với manifest đúng, cần Editor.log/UPM log để phân biệt package registry, bản cài Editor hoặc cache; chưa xác nhận chỉ đổi manifest sẽ giải quyết mọi lỗi.

## Scene cũ còn vật liệu phẳng hoặc camera chớp khi chạy

Đã bổ sung source camera và menu **TravelVietnamese → Update Scene Graphics** để gán map PBR vào scene hiện có. Stop Play, cập nhật source, chạy menu và Ctrl+S trước khi thử lại. [Hướng dẫn và giới hạn bản sửa](../docs/UNITY_CAMERA_GRAPHICS_FIX.md). Chưa có Unity runtime validation trong môi trường team.
