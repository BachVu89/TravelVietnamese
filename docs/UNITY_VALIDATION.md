# Unity — kết quả xác minh và giới hạn

Đối tượng: `unity/TravelVietnamese/`, Unity 6 `6000.0.32f1`/URP `17.0.3`. Kết quả Godot/Unreal không chứng minh Unity chạy được. Chưa có Unity Editor trong môi trường này; chưa có scene Unity được sinh/lưu hoặc APK/IPA Unity.

## Đã thực thi

- `scripts/test-unity-domain.sh`: **92 assertions PASS**, exit 0. .NET SDK 8.0.427 compile và chạy **source `PassRules.cs` và `CameraOcclusionRules.cs` thực** cùng console harness `Tests/DomainHarness.cs`; không mock UnityEngine, không compile Unity assembly. Project `net8.0` không có package phụ thuộc ngoài SDK.
- `python3 scripts/validate-unity-source.py`: **110 static checks PASS**, exit 0. Kiểm Editor/URP pin, mobile không có HDRP dependency, Domain không tham chiếu Unity, Editor references nằm trong Editor folder, tên MonoBehaviour khớp file, compile inputs của harness, local documentation links, SHA256 ba FBX copy vào Unity khớp report nguồn, isolation URP/HDRP, manifest parity và exact shared Runtime/Art file-set/byte parity, provenance SHA256 và PNG IHDR 512×512 của đủ 9 surface maps.
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

Sau review runtime, dev đã đổi vị trí xuống xe/reset sang helper chọn hướng vào trong bay và clamp safe lane để tránh mép guardrail bên phải. Domain rules không đổi nên giữ kết quả 60 assertions đã chạy ở vòng trước; helper dùng Unity vectors chỉ được đọc source, chưa xác minh collider/clearance thật. Không nâng kết quả đó thành physics PASS.

## Chưa chạy / cửa nghiệm thu

- Import project/packages; compile toàn bộ C# bằng Unity 6/URP đã ghim; chạy Editor bootstrap, lưu scene và kiểm build settings.
- Play Mode: floor/edge/winding, steering/brake/collision, camera self-collision/clipping, hai stop, đi bộ/lên xe, reset giữ progress và input focus/modal/touch.
- JsonUtility roundtrip, malformed-file preservation, autosave/restart và file replace trên filesystem đích.
- Unity render/shader/lighting/material scale/two-sided foliage và chất lượng hình ảnh.
- Android/iOS build, artifact permissions/signature, cài và mở lạnh offline. iOS cần macOS/Xcode/signing.
- FPS/frame time/RAM/nhiệt trên Oppo Find X7 Ultra và iPhone 13. Chưa có số đo hoặc screenshot gameplay Unity do QA chạy; người dùng đã cung cấp screenshot thực tế và báo lỗi đường nhấp nháy, đó là đầu vào chẩn đoán, chưa phải lỗi đã tái hiện trong môi trường QA.

Không có kết quả Unity gameplay/device PASS hoặc APK Unity mới trong báo cáo này.

## Camera và road flashing — regression bổ sung

Người dùng báo đường phủ/nhấp nháy toàn màn hình khi lái. QA chưa tái hiện bằng Unity. Camera source cũ có cast từ pivot gần collider người/xe; source mới dùng `PassCameraRig`, lọc cả hai hierarchy ownership và triggers, chọn hit world gần nhất, fallback khi buffer 64 hit bão hòa, sphere bao near-plane corner, retract ngay và hồi arm từ từ. Đây là hướng sửa có cơ sở source, chưa chứng minh đã hết symptom trên máy người dùng.

Actual .NET harness hiện **92 assertions PASS** (60 Domain trước +32 camera geometry/decision checks): sphere chứa near-plane corner ở nhiều aspect ratio; giữ world obstacle, bỏ trigger/owned collider; wall 0.3 m cho arm 0.22 m thay vì clamp tối thiểu 0.5 m cũ; inward tức thì/outward giới hạn/snap; NaN/Infinity không tạo giá trị camera vô hạn; wall 0.03 m nhỏ hơn margin cho distance 0, zero distance hồi outward dần thay vì snap ra ngoài collider. Không giả lập Unity Physics.

Đã chạy `python3 unity/TravelVietnamese/Tests/RoadGeometryAudit.py`: transcribe độc lập công thức route/strip hiện tại, tính 5 strips ×600 = **3000 triangles**. Tất cả finite và signed XZ normal Y dương (min road 16.833631, cliff 59.927837, valley 4.317036). Không thấy local fold tại samples. Đây là numerical source-equation audit; không đọc mesh Unity đã sinh, không loại trừ global intersections, camera clipping, z-fighting hoặc lỗi renderer. Khi công thức source đổi phải review lại phần transcribe.

Play Mode regression vẫn cần chạy bằng Unity: không có obstacle thì cả riding/walking giữ arm mong muốn dù capsule của cả hai actor tồn tại; trigger không retract; wall gần/xa trên layer world khác0 được chọn đúng; ≥65 collider không bỏ lọt nearest hit; đổi aspect/near clip và đi trên dốc/đường cong không cắt near plane vào đường; dismount/remount/reset/focus không giữ arm cũ. Test đặc biệt camera pivot ban đầu overlap world vì SphereCast có giới hạn với initial overlap. Cần đối chiếu symptom người dùng tại cùng đoạn đường và quay video trước/sau; chưa đánh dấu các test physics này PASS.

Graphics V2 source được review riêng: 9 PNG gốc (Road/Rock/Soil ×BaseColor/Normal/Mask), import albedo sRGB và normal/mask linear; normal maps dùng TextureImporterType.NormalMap, mipmaps/repeat, procedural road tính tangents. `Update Scene Graphics` là đường nâng cấp scene cũ riêng, chặn Play, ghi Undo, gán material/prefab version mới dưới Generated/GraphicsV2, đánh dấu dirty và yêu cầu Ctrl+S scene; không trông chờ `Surface()` cũ trả asset hiện hữu để áp defaults mới. Đây là review source, chưa chạy menu/Undo/import/shader trong Unity; ảnh PNG không phải screenshot gameplay.

Final static sau đồng bộ: **110 checks PASS**, exit 0; hai profile Runtime/FBX/SurfaceMaps đã khớp, HDRP bootstrap gọi graphics upgrade và HDRP normal keywords hiện gồm `_NORMALMAP` cùng `_NORMALMAP_TANGENT_SPACE`. Không rerun Domain sau lần 92 PASS vì pure C# logic không thay đổi. Chưa có Unity Editor execution bổ sung.
