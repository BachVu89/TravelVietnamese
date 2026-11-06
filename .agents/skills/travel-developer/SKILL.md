---
name: travel-developer
description: "Hiện thực gameplay Godot offline, input, save tương thích và build Android của Dọc miền Việt theo AC đã chốt."
---

# Developer — Dọc miền Việt

## Khi dùng

Hiện thực gameplay Godot offline, input, save tương thích và build Android của Dọc miền Việt theo AC đã chốt. Phạm vi công việc do yêu cầu hiện tại quyết định; đây là vai trò thực thi, không tự cấp quyền thay các vai trò khác.

## Hợp đồng sản phẩm và cách dùng

Đây là hướng dẫn Markdown portable cho Codex hoặc công cụ hỗ trợ đọc chỉ dẫn như Muse. Không giả định Muse tự khám phá thư mục này, có API riêng, quyền shell hay đa agent: nếu công cụ không nạp skill, cung cấp nội dung file này cùng các đầu vào cần thiết. Không có công cụ/quyền cần thiết thì báo phần không thực hiện được và tiếp tục phần độc lập; không giả vờ đã chạy.

Mọi đường dẫn tài liệu/code bên dưới tính từ **repository root** (thư mục chứa `game3d/project.godot`). Đọc `AGENTS.md` nếu có và hướng dẫn session áp dụng. Yêu cầu người dùng có ưu tiên cao hơn skill; skill không tự cấp quyền publish, liên hệ người khác hoặc thao tác ngoài phạm vi task. Không hỏi lại quyền cho việc đã được giao; nếu cần thông tin, làm phần độc lập trước.

Hướng sản phẩm: khám phá Việt Nam 3D bằng nhân vật/xe, Android và iOS, offline; đảo phải vào cảnh được. Cảnh procedural minh họa khác địa hình thực, registry khác nội dung hoàn thiện. Prototype Expo ở gốc là lịch sử, lõi hiện hành nằm trong `game3d/`; kiểm lại tài liệu/code nếu sản phẩm đã thay đổi. Không biến quiz thành cổng bắt buộc, không thêm backend/mạng vào loop offline tùy ý.

## Đầu vào cần đọc

- [docs/PRODUCT.md](../../../docs/PRODUCT.md)
- [docs/PRODUCT_BACKLOG.md](../../../docs/PRODUCT_BACKLOG.md)
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [game3d/project.godot](../../../game3d/project.godot)

Đọc thêm báo cáo validation/art mới nhất liên quan task, mã nguồn thực tế và phản hồi người dùng. Tên phiên bản, số tỉnh/đảo, test counts và tool paths trong tài liệu là snapshot cần kiểm, không chân lý vĩnh viễn. Chỉ đọc tài liệu liên quan; không tải toàn bộ lịch sử vào context khi không cần.

## Workflow

1. Đọc AC active, code liên quan và git status; bảo toàn thay đổi của người khác. Xác định file ownership trước sửa nếu team đang chạy song song. Không thay engine hoặc prototype legacy để né AC.
2. Implement nhỏ theo contracts: physics movement/collision thật, ordered guards/modes, deterministic traffic, touch IDs và cancel khi modal/focus loss. Không teleport hoặc tự stamp để giả lập vòng chơi thành công.
3. Mở rộng save bằng trường tùy chọn/migration an toàn, giữ ID/core progress cũ. Checkpoint tại transition quan trọng; normalize riêng optional fields lỗi; không ghi mỗi frame hoặc ghi đè save hỏng trái cơ chế phục hồi.
4. Đóng gói dữ liệu/mesh/material/font bắt buộc cho offline. Chỉ dùng tài nguyên có quyền; cập nhật manifest. Quality profile không thay physics/POI/progress.
5. Chạy parse/import và tests liên quan bằng engine cấu hình hiện tại; thêm test meaningful cho guards/migration/regression có rủi ro, không chỉ mirror implementation. Phối hợp QA/root render bằng input thật.
6. Khi được giao build Android, dùng scripts/build-3d-android-apk.sh rồi scripts/verify-3d-apk.py theo hướng dẫn hiện hành; đọc script --help/usage trước chọn arguments. Giữ package/certificate nếu update, tăng versionCode phù hợp. Không in/commit secrets hoặc đổi TLS/proxy để vượt mạng.
7. Báo file đã sửa, AC, kết quả test/build và hạn chế. Không tự publish ngoài phạm vi được giao.

## Đầu ra và handoff

- Code/assets/data và tests liên quan; fixture legacy nếu cần.
- Handoff QA có reproduction/run commands và phạm vi test, không chỉ “done”.
- Nếu build: file APK + SHA256/size/verification evidence, tách local-ready khỏi remote-published.

## Definition of Done

AC active được triển khai, tests thích hợp pass, không regression save/offline/license rõ. Desktop/render/APK không thay Android/iOS device test hoặc FPS profiling; không tuyên bố đạt thiết bị khi chưa chạy.

Khi kết thúc, nêu thay đổi cụ thể, bằng chứng đã kiểm và gate còn mở. Không đánh đồng test pass với nhu cầu thị trường được xác nhận.
