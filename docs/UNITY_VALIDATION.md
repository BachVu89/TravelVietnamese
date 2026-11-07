# Unity — kết quả xác minh và giới hạn

Đối tượng: `unity/TravelVietnamese/`, Unity 6 `6000.0.32f1`/URP `17.0.3`. Kết quả Godot/Unreal không chứng minh Unity chạy được. Chưa có Unity Editor trong môi trường này; chưa có scene Unity được sinh/lưu hoặc APK/IPA Unity.

## Đã thực thi

- `scripts/test-unity-domain.sh`: **60 assertions PASS**, exit 0. .NET SDK 8.0.427 compile và chạy **source `PassRules.cs` thực** cùng console harness `Tests/DomainHarness.cs`; không mock UnityEngine, không compile Unity assembly. Project `net8.0` không có package phụ thuộc ngoài SDK.
- `python3 scripts/validate-unity-source.py`: **63 static checks PASS**, exit 0. Kiểm Editor/URP pin, không có HDRP dependency, Domain không tham chiếu Unity, Editor references nằm trong Editor folder, tên MonoBehaviour khớp file, compile inputs của harness, local documentation links SHA256 ba FBX copy vào Unity khớp report nguồn, isolation URP/HDRP, manifest parity và exact shared Runtime/Art file-set/byte parity.
- `python3 scripts/build-unity.py --editor /opt/Unity/Editor/Unity --check-only`: **BLOCKED**, exit 2, executable không tồn tại; không gọi Unity compile/build. `Unity`/`unity-editor` không tìm thấy trên PATH.

Lần đầu chạy .NET trong sandbox gặp home read-only, đã đặt `DOTNET_CLI_HOME` ở `/tmp` trong wrapper. Sandbox tiếp tục chặn named mutex `NuGet-Migrations`; chạy đúng harness qua execution được automatic approval cho phép đã thành công. Wrapper tắt .NET CLI telemetry. Kết quả test không dựa trên hai lần khởi tạo SDK thất bại.

Domain tests kiểm inclusive/exclusive boundaries của stop/speed/lane/proximity; NaN/Infinity/negative input; không đóng dấu khi đang lái, ngoài tầm, sai thứ tự hoặc lặp; checkpoint không nhảy tới stop chưa qua; null/unknown-version/invalid-pose normalization; giữ stamps hợp lệ khi pose hỏng, loại orphan/duplicate stamps, không mutate collection nguồn và normalize idempotent. Không có API replay trong Domain hiện tại; reset runtime giữ stamps mới được đọc source, chưa chạy bằng Unity.

Ba FBX là cùng binary đã được QA nhập độc lập bằng Blender 4.3.2 ở vòng art: cliff 192, fern 1224, banana 960 triangles; geometry/UV/material count/dimensions/finite coordinates khớp report. Checksum lần này chứng minh Unity copy đúng binary đó; **không chứng minh Unity importer, scale, shader hoặc render**. Không đoán tương thích engine từ Blender readback.

## Review source

QA phát hiện `PassRoute.At(s)` thiếu đối số/default và nhiều MonoBehaviour không khớp tên file; dev đã sửa default lateral và tách `PassBike`, `PassWalker`, `PassRoad` vào file riêng. Chỉ xác nhận sửa source; chưa có compiler Unity kiểm toàn project.

Runtime source kết nối procedural road, bike/walker CharacterController, camera, hai stop có text riêng và rules đóng dấu, GUI, local journal. Focus/pause clear input và dừng xe; input có brake priority và release finger IDs; camera có sphere cast. Journal dùng `Application.persistentDataPath`, temp/replace/backup, giữ file lỗi/unknown-version cho tới explicit save theo nhánh source. Chưa chạy JsonUtility/file replacement trên Unity/Android/iOS; không gọi đó là persistence đã được kiểm engine.

Bootstrap Editor tạo URP material/pipeline, scene identity-root, bind FBX prefab và build scene list; giữ scene/prefab/material đã có. Android source đặt ARM64, min SDK26, application ID riêng và `forceInternetPermission=false`. Không thấy runtime auth/HTTP/analytics dependency trong code/package đã review. Quyền manifest, offline cold launch và signing vẫn cần APK thật. URP API, legacy input configuration, material-slot import và scene serialization chưa được Editor xác minh.

## Companion HDRP desktop

`unity/TravelVietnamese-HDRP/` là project source riêng, HDRP `17.0.3`, không cài URP. Validator so sánh độc lập cả file set và từng byte Runtime/Art giữa hai project; editor pin khớp, dependencies chỉ khác pipeline, imports Editor/pipeline nằm đúng phạm vi. `python3 scripts/create-unity-hdrp-reference.py --verify` cũng trả `SHARED SOURCE MATCH`, exit 0. Đây là source parity, không phải compile/render.

`python3 scripts/build-unity.py --editor /opt/Unity/Editor/Unity --profile hdrp --target android --check-only` trả **BLOCKED**, exit 2 đúng ý định desktop-only; không thử build Android. Desktop bootstrap có guard yêu cầu HDRenderPipelineAsset/HDRP Wizard và không có Android builder. Chưa có pipeline asset, Volume hoặc scene HDRP thực; legacy RenderSettings fog không tạo HDRP volumetric fog. Cần Editor resolve package/configure pipeline và kiểm shader/lighting trước khi đánh giá ảnh desktop.

Sau review runtime, dev đã đổi vị trí xuống xe/reset sang helper chọn hướng vào trong bay và clamp safe lane để tránh mép guardrail bên phải. Domain rules không đổi nên giữ kết quả 60 assertions đã chạy; helper dùng Unity vectors chỉ được đọc source, chưa xác minh collider/clearance thật. Không nâng kết quả đó thành physics PASS.

## Chưa chạy / cửa nghiệm thu

- Import project/packages; compile toàn bộ C# bằng Unity 6/URP đã ghim; chạy Editor bootstrap, lưu scene và kiểm build settings.
- Play Mode: floor/edge/winding, steering/brake/collision, camera self-collision/clipping, hai stop, đi bộ/lên xe, reset giữ progress và input focus/modal/touch.
- JsonUtility roundtrip, malformed-file preservation, autosave/restart và file replace trên filesystem đích.
- Unity render/shader/lighting/material scale/two-sided foliage và chất lượng hình ảnh.
- Android/iOS build, artifact permissions/signature, cài và mở lạnh offline. iOS cần macOS/Xcode/signing.
- FPS/frame time/RAM/nhiệt trên Oppo Find X7 Ultra và iPhone 13. Không có số đo hoặc screenshot gameplay Unity thật.

Không có kết quả Unity gameplay/device PASS hoặc APK Unity mới trong báo cáo này.
