---
name: travel-team-delivery
description: "Điều phối giao việc và giao bản game Dọc miền Việt có bằng chứng source, artifact và giới hạn xác minh; dùng cho tích hợp, báo cáo hoặc phát hành đã được giao."
---

# Team Delivery — Dọc miền Việt

## Khi dùng

Điều phối giao việc và giao bản game Dọc miền Việt có bằng chứng source, artifact và giới hạn xác minh; dùng cho tích hợp, báo cáo hoặc phát hành đã được giao. Phạm vi công việc do yêu cầu hiện tại quyết định; đây là vai trò thực thi, không tự cấp quyền thay các vai trò khác.

## Hợp đồng sản phẩm và cách dùng

Đây là hướng dẫn Markdown portable cho Codex hoặc công cụ hỗ trợ đọc chỉ dẫn như Muse. Không giả định Muse tự khám phá thư mục này, có API riêng, quyền shell hay đa agent: nếu công cụ không nạp skill, cung cấp nội dung file này cùng các đầu vào cần thiết. Không có công cụ/quyền cần thiết thì báo phần không thực hiện được và tiếp tục phần độc lập; không giả vờ đã chạy.

Mọi đường dẫn tài liệu/code bên dưới tính từ **repository root** (thư mục chứa `game3d/project.godot`). Đọc `AGENTS.md` nếu có và hướng dẫn session áp dụng. Yêu cầu người dùng có ưu tiên cao hơn skill; skill không tự cấp quyền publish, liên hệ người khác hoặc thao tác ngoài phạm vi task. Không hỏi lại quyền cho việc đã được giao; nếu cần thông tin, làm phần độc lập trước.

Hướng sản phẩm: khám phá Việt Nam 3D bằng nhân vật/xe, Android và iOS, offline; đảo phải vào cảnh được. Cảnh procedural minh họa khác địa hình thực, registry khác nội dung hoàn thiện. Prototype Expo ở gốc là lịch sử; `game3d/` là bản Godot chơi được đã giao. Lựa chọn engine mới nhất là Unity 6/C# trong `unity/`, URP cho mobile và HDRP companion riêng cho desktop; đọc [Unity migration](../../../docs/UNITY_MIGRATION.md). `unreal/` giữ lịch sử UE. Source Unity/UE chưa phải game đã build/render; xác minh trạng thái hiện tại. Không biến quiz thành cổng bắt buộc, không thêm backend/mạng vào loop offline tùy ý.

## Đầu vào cần đọc

- [docs/TEAM.md](../../../docs/TEAM.md)
- [docs/STATUS_REPORT.md](../../../docs/STATUS_REPORT.md)
- [docs/PRODUCT_BACKLOG.md](../../../docs/PRODUCT_BACKLOG.md)
- [docs/APK_INSTALL.md](../../../docs/APK_INSTALL.md)

Đọc thêm báo cáo validation/art mới nhất liên quan task, mã nguồn thực tế và phản hồi người dùng. Tên phiên bản, số tỉnh/đảo, test counts và tool paths trong tài liệu là snapshot cần kiểm, không chân lý vĩnh viễn. Chỉ đọc tài liệu liên quan; không tải toàn bộ lịch sử vào context khi không cần.

## Workflow

1. Đọc yêu cầu hiện tại và git status/branch/remotes; xác định scope/source-of-truth từ code và tài liệu mới nhất. Khi tài liệu mâu thuẫn (local-ready vs published), xác minh artifact/remote trước sửa trạng thái.
2. Phối hợp vai trò PO→BA/SA/Designer→Dev→Tester→root tích hợp theo quyền công cụ/session. Chỉ spawn agent khi người dùng hoặc hướng dẫn áp dụng cho phép; có thể thực hiện tuần tự các vai trò nếu không có đa agent. Skill không tạo thành viên thường trực ngoài session.
3. Chốt file ownership/handoff, ưu tiên AC và blockers, không chỉ thu báo “done”. PO quyết định phạm vi/giá trị; QA báo chất lượng; delivery không tự mở scope hoặc nghiệm thu art/device thay bằng build pass.
4. Trước giao: tổng hợp QA fresh, desktop real-input/render, paired art khi liên quan, save/offline/license và limitations. Dùng docs/VALIDATION_*.md làm mẫu nhưng chọn phiên bản từ code/build hiện tại, không copy hash/count cũ.
5. Artifact: dùng build/verify scripts Godot hiện có; ghi tên/size/SHA256/package/versionCode/certificate/alignment/resources. Cùng certificate/versionCode tăng chỉ hỗ trợ update về metadata, chưa chứng minh cài đè giữ save trên máy.
6. Commit/push/publish chỉ trong phạm vi user/session đã giao. Rà staged diff, không đưa secrets/private keys hoặc thay đổi người khác ngoài scope. Source và artifact branches có thể khác; kiểm cấu hình thực tế, không hardcode branch trong lệnh phá hủy.
7. Khi publish được giao, xác minh remote commit/file/download URL; local-ready không phải published. Báo link tải đúng artifact, code commit và giới hạn. Không gửi email/chat bên ngoài khi chưa có chỉ thị rõ.

## Đầu ra và handoff

- TEAM/STATUS_REPORT và validation cho batch với trạng thái nhất quán, evidence và gates chưa chạy.
- Nếu được giao commit/publish: commit IDs/remote URLs đã xác minh, checksum và hướng dẫn tải/cài.
- Báo cáo ngắn: đã đổi gì, kiểm tới đâu, artifact ở đâu, việc còn mở (đảo/art/device) cụ thể.

## Definition of Done

Source và artifact trace được; không claim remote khi chưa kiểm. Phân biệt QA/PO accepted/local artifact/published/device verified. Android/iOS signing/device/FPS/market claims chỉ theo bằng chứng thật; milestone catalog đảo không bị lãng quên sau tiện ích đèo.

Khi kết thúc, nêu thay đổi cụ thể, bằng chứng đã kiểm và gate còn mở. Không đánh đồng test pass với nhu cầu thị trường được xác nhận.
