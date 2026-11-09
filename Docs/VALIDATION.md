# VietTrail — kiểm chứng bản viết mới

Project được kiểm ở root `Assets/VietTrail`, không dùng source/harness cũ. Chưa có Unity Editor trên PATH; kết quả dưới đây không chứng minh project đã compile bằng Unity, render đẹp hoặc chạy tốt trên điện thoại.

## Đã chạy

- `Tests/run-core.sh`: **262 assertions PASS**, exit0. .NET8 compile/chạy các file Core C# thực, không mock UnityEngine. Kiểm ordered discovery/duplicate/invalid action, finite bounds, mount/dismount, checkpoint không nhảy trước, invalid saves/settings normalization, collection independence và idempotence trên route. .NET dùng writable CLI home ở `/tmp`, telemetry opt-out; execution ngoài sandbox được automatic review cho phép vì named-mutex SDK bị sandbox chặn ở môi trường này.
- `python3 Tests/RouteNumerics.py`: **800 road triangles** finite/upward, bay footprint chứa lane hợp lệ cộng0.3m clearance; **1601 chunk windows** đều chứa current chunk và không quá5 chunks. Đây là model phương trình/bounds đọc và transcribe từ source, không chạy Unity physics hoặc SegmentHost thật.
- `Tests/run-syntax.sh`: **11 source files, 0 parse errors**, exit0. Roslyn C#9 syntax parsing trên source Assets, không có UnityEngine stubs. Chỉ syntax, không resolution của Unity API/URP shader hoặc compile assembly Unity.

QA phát hiện rule dừng ban đầu cho phép±16m trong khi sân nghỉ đầy đủ chỉ±12m; ở station+16/lane6.5 có thể ở ngoài mặt đường. Dev đã đổi guard sang±12, test thực hai biên và hai điểm ngoài biên của cả3stops đều PASS. Điều này không thay kiểm floor/controller/dismount clearance trong engine.

## Kiểm tra cấu trúc trước khi mở Editor

`python3 Tools/VerifyProject.py` kiểm package pin/IDs, không còn cây source cũ, không có FBX/Blender/heavy imports, offline source, tên MonoBehaviour/Editor isolation, GUID/local references, scene/material, shader pass declarations và PNG512×512. Package/engine GUID nào không resolve từ file local phải được báo riêng; không coi GUID package là đã được Unity resolve. Final check: **166 structural/reference checks PASS**, exit0; không có GUID local unresolved. Entry scene tham chiếu đúng TrailApp; PainterlyWorld material bind đúng shader và PNG palette512×512, metadata cho mọi file asset hiện hữu. Chart minh họa PainterlySwatches800×480 không bị nhầm với runtime atlas512×512. README menu/scene paths khớp source. `python3 Tools/PrepareMetadata.py --check` PASS, exit0: stable GUIDs, Entry, theme materials và BuildSettings đã kiểm file; chưa import bằng Unity.

## Chưa chạy — acceptance trong Unity/thiết bị

1. Import project, resolve URP17.0.3, compile scripts và shader, mở Entry scene không missing script/material/texture.
2. Home/settings/save/load/help/back flow; panel pause chặn move/look, focus loss và touch cancellation không kẹt input; gameplay/new run/replay đúng semantics, không âm thầm mất progress.
3. Physics: spawn/floor, slope/edges, ga/phanh/rẽ, đỗ cả3bay, xuống xe/đi bộ/khám phá/lên xe; checkpoint và save/restart; near-plane/self-collider/world occlusion camera.
4. Chunk chuyển qua mốc96m, teleport checkpoint, route ends: live chunks≤5, collider cũ tắt ngay, mesh lifecycle không leak; không biến model giới hạn chunk thành số đo RAM thực.
5. Art review từ gameplay camera: palette/material/lighting/sky/fog, độ dễ đọc đường và nhân vật, UI khung hình mobile. Test logic PASS không phải graphic acceptance. Chưa có screenshot gameplay do QA chạy.
6. Android/iOS build/sign/install, cold launch offline, actual permissions/save persistence và frame time/RAM/nhiệt. Không có APK/IPA mới hoặc đo FPS/device trong báo cáo này.

Final freeze: chạy lại VerifyProject166 PASS, metadata `--check` PASS và Roslyn11files/0parseerrors sau pause/reset fixes. Không rerun Core không đổi; giữ kết quả actual262 assertions trước đó. Không có Unity API compilation hoặc visual/device acceptance mới.

## Bổ sung đồng bộ hình ảnh và cỏ

Source bổ sung global SharedPainterlyLook/profile dùng chung, tán cây tròn trên overworld, GrassPatch instancing theo chunk và shader gió có neo gốc. Kiểm tra cấu trúc hiện tại:180 PASS; kiểm tra cú pháp cập nhật13 file C# không lỗi parse. Chưa có Unity Editor để compile API/shader, xác nhận post-processing, batching/instancing, bounds culling, gió hoặc FPS trên thiết bị. Các kết quả Core trước đó giữ nguyên vì không sửa quy tắc chơi.

## Sửa setup sau Safe Mode

Ảnh Console từ máy người dùng báo palette không tải được dù PNG nằm trong source. Setup trước đây chạy từ InitializeOnLoad, thời điểm non-script assets có thể chưa import xong. Đổi lịch chạy sang OnPostprocessAllAssets sau domain reload; chờ Editor hết compiling/updating, kiểm tra file nguồn rồi import palette đồng bộ trước khi LoadAssetAtPath. Thông báo mới phân biệt thiếu file với lỗi importer. Kiểm tra cú pháp13 file và cấu trúc180 PASS; chưa tái hiện/kiểm chứng trong Unity Editor tại môi trường này.

## Importer metadata — sửa tiếp lỗi palette

Ảnh Console tiếp theo xác nhận đổi thời điểm setup chưa xử lý được lỗi. PNG nguồn đã decode/verify bằng Pillow,512×512 hợp lệ. Kiểm tra source phát hiện metadata ảnh/shader/material chỉ có header+GUID, không có block importer theo loại asset. Bổ sung TextureImporter/ShaderImporter/NativeFormatImporter/TextScriptImporter và DefaultImporter cho scene; giữ nguyên toàn bộ GUID. Generator mới tạo đúng các block; validator có kiểm tra hồi quy importer. Lượt kiểm tra mới:187 cấu trúc PASS, metadata --check PASS,13 file C# không lỗi parse. Đây là sửa metadata có thể kiểm tra từ source; chưa chạy Unity để khẳng định việc import đã thành công. Lỗi setup hiện báo rõ importer/main-asset type để chẩn đoán tiếp nếu cần.

## Palette không phụ thuộc PNG importer

Ảnh tiếp theo vẫn mang chuỗi exception từ trước d54a38e, vì vậy chưa xác nhận được mã mới đã chạy trên project người dùng hay Console chỉ giữ lỗi cũ. Thêm canonical PainterlyPalette64 màu: Editor tạo Texture2D `.asset` dự phòng nếu PNG không import được, sửa binding material hiện có; runtime cũng tạo texture nếu Resources không tải được. Không còn exception chặn setup do riêng palette PNG. Đối chiếu toàn bộ262144 pixel PNG với64 màu C# và thứ tự UV dưới-lên đạt; đây là đối chiếu dữ liệu, không phải chạy Texture2D trong Unity. Cú pháp14 file không lỗi parse;193 kiểm tra cấu trúc PASS. Setup hoàn tất sẽ log `VietTrail ready [palette-fallback-v1]` cùng đường dẫn project để phân biệt source/version và Console cũ. Chưa có Unity Editor tại cloud để xác nhận chạy end-to-end.
