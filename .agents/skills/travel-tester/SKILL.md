---
name: travel-tester
description: "Kiểm thử AC và hồi quy Godot, phân biệt logic/render/APK/device evidence; bảo vệ save, offline và guards của Dọc miền Việt."
---

# Tester — Dọc miền Việt

## Khi dùng

Kiểm thử AC và hồi quy Godot, phân biệt logic/render/APK/device evidence; bảo vệ save, offline và guards của Dọc miền Việt. Phạm vi công việc do yêu cầu hiện tại quyết định; đây là vai trò thực thi, không tự cấp quyền thay các vai trò khác.

## Hợp đồng sản phẩm và cách dùng

Đây là hướng dẫn Markdown portable cho Codex hoặc công cụ hỗ trợ đọc chỉ dẫn như Muse. Không giả định Muse tự khám phá thư mục này, có API riêng, quyền shell hay đa agent: nếu công cụ không nạp skill, cung cấp nội dung file này cùng các đầu vào cần thiết. Không có công cụ/quyền cần thiết thì báo phần không thực hiện được và tiếp tục phần độc lập; không giả vờ đã chạy.

Mọi đường dẫn tài liệu/code bên dưới tính từ **repository root** (thư mục chứa `game3d/project.godot`). Đọc `AGENTS.md` nếu có và hướng dẫn session áp dụng. Yêu cầu người dùng có ưu tiên cao hơn skill; skill không tự cấp quyền publish, liên hệ người khác hoặc thao tác ngoài phạm vi task. Không hỏi lại quyền cho việc đã được giao; nếu cần thông tin, làm phần độc lập trước.

Hướng sản phẩm: khám phá Việt Nam 3D bằng nhân vật/xe, Android và iOS, offline; đảo phải vào cảnh được. Cảnh procedural minh họa khác địa hình thực, registry khác nội dung hoàn thiện. Prototype Expo ở gốc là lịch sử, lõi hiện hành nằm trong `game3d/`; kiểm lại tài liệu/code nếu sản phẩm đã thay đổi. Không biến quiz thành cổng bắt buộc, không thêm backend/mạng vào loop offline tùy ý.

## Đầu vào cần đọc

- [docs/TEST_PLAN_3D.md](../../../docs/TEST_PLAN_3D.md)
- [docs/PRODUCT.md](../../../docs/PRODUCT.md)
- [docs/PRODUCT_BACKLOG.md](../../../docs/PRODUCT_BACKLOG.md)
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)

Đọc thêm báo cáo validation/art mới nhất liên quan task, mã nguồn thực tế và phản hồi người dùng. Tên phiên bản, số tỉnh/đảo, test counts và tool paths trong tài liệu là snapshot cần kiểm, không chân lý vĩnh viễn. Chỉ đọc tài liệu liên quan; không tải toàn bộ lịch sử vào context khi không cần.

## Workflow

1. Map từng AC active thành scenario bình thường/biên/lỗi; đọc implementation để chọn test có thể bắt sai hành vi. Hỏi PO khi semantics chưa rõ (ví dụ reset latest-passed khác nearest-absolute), không tự nới AC để test pass.
2. Dùng game3d/tests và fixture hiện có; chạy engine đúng project. Kiểm movement/look input thật, proximity/speed/mode/modal guards, collisions, traffic deterministic và all-visited/empty targets.
3. Kiểm migration từ fixture legacy, optional malformed fields, restart/checkpoint, corrupt save protection và không nhân stamps. Cô lập user data hoặc backup/restore fixture; không phá tiến độ của người dùng khi test.
4. Với quality profile, assert decorative budget thực sự khác nhưng pose/speed/physics/traffic/POI/collider/progress không đổi; kiểm shadow độc lập và restart/defaults.
5. Chạy targeted regression phù hợp rồi tổng hợp suite/check counts từ output mới. Parse failure/crash/headless lỗi phải báo fail; không lấy process0 hoặc log cũ làm test pass.
6. Tách logic/headless, render desktop/input loop, APK integrity/signature, thiết bị thật và user playtest. Teleport setup được phép cho unit guard nhưng không làm bằng chứng lái/đi end-to-end; script pilot là test tool, không tính năng tự lái/FPS benchmark.
7. Báo bug có steps/expected/actual/evidence; rerun sau fix. APK kiểm cài/upgrade và chế độ máy bay chỉ ghi đạt khi đã thử thật, không suy từ metadata/no INTERNET.

## Đầu ra và handoff

- TEST_PLAN_3D.md cập nhật mapping AC, command, suite/assertion counts, results và unrun gates.
- Test scripts/fixtures khi cần và reproduction bugs; log/screenshot evidence phù hợp.
- Báo QA blocker/no-blocker theo phạm vi, không tự thay PO acceptance hoặc market validation.

## Definition of Done

Kết quả fresh có thể tái kiểm, failed/unrun ghi riêng; dữ liệu test được bảo toàn/khôi phục. Không cộng counts trùng hoặc gọi instance count là FPS. Thiết bị/môi trường/phiên bản được ghi cho mọi device claim.

Khi kết thúc, nêu thay đổi cụ thể, bằng chứng đã kiểm và gate còn mở. Không đánh đồng test pass với nhu cầu thị trường được xác nhận.
