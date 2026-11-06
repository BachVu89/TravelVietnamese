# Bộ Skill team Dọc miền Việt

Bản đầu: 07/11/2026 (UTC+7). Bộ hướng dẫn Markdown cho các vai trò AI trong repo TravelVietnamese; không cài plugin, không tạo một đội người thật và không tự cấp quyền cho agent.

## Danh mục

| Skill | Khi dùng | Đầu ra chính |
| --- | --- | --- |
| [travel-product-owner](../../.agents/skills/travel-product-owner/SKILL.md) | Nghiên cứu, ưu tiên, nghiệm thu giá trị | Nguồn nghiên cứu, backlog, quyết định PO |
| [travel-business-analyst](../../.agents/skills/travel-business-analyst/SKILL.md) | Làm rõ yêu cầu, phạm vi và tiến độ | Story, AC, gap, báo cáo BA |
| [travel-solution-architect](../../.agents/skills/travel-solution-architect/SKILL.md) | Thiết kế dữ liệu, save, offline và nền tảng | Phương án kỹ thuật, migration, rủi ro |
| [travel-designer](../../.agents/skills/travel-designer/SKILL.md) | Thiết kế trải nghiệm và mỹ thuật | Luồng chơi, input, art review |
| [travel-developer](../../.agents/skills/travel-developer/SKILL.md) | Hiện thực, sửa lỗi, build | Code, artifact và kết quả kiểm |
| [travel-tester](../../.agents/skills/travel-tester/SKILL.md) | Kiểm AC, hồi quy, đánh giá bằng chứng | Test matrix, bug, kết quả có giới hạn |
| [travel-team-delivery](../../.agents/skills/travel-team-delivery/SKILL.md) | Điều phối một yêu cầu xuyên vai trò | Batch tích hợp có thể review và báo cáo giao bản |

Nguồn chuẩn nằm ở `.agents/skills/<name>/SKILL.md`. Mỗi file có YAML `name`, `description`, quy trình và liên kết về tài liệu dự án. Các vai trò phải đọc trạng thái hiện hành thay vì coi phiên bản ghi trong lịch sử là mới nhất.

## Dùng trong Codex

1. Checkout nhánh `codex-work` và mở thư mục repo làm workspace.
2. Codex có hỗ trợ repository skills sẽ tìm `.agents/skills/`. Nếu phiên đang mở chưa nhận skill mới, mở phiên mới hoặc dùng cách đọc file trực tiếp bên dưới.
3. Gọi tên skill bằng `$travel-product-owner` hoặc `$travel-team-delivery`, kèm mục tiêu cụ thể. Không cần chép vào thư mục cấu hình cá nhân.

Ví dụ:

```text
Sử dụng $travel-product-owner để đề xuất catalog đảo v0:
đọc trạng thái hiện tại, lập bảng nguồn/license/version và khoảng thiếu,
chọn batch nhỏ có AC; không tuyên bố đã có đủ mọi đảo.
```

```text
Sử dụng $travel-team-delivery để thực hiện batch đã được duyệt.
Đọc backlog hiện tại, giao rõ file ownership nếu có sub-agent,
kiểm bằng chứng rồi cập nhật báo cáo; chỉ push khi đã được yêu cầu.
```

Nếu client không tự liệt kê Skill:

```text
Đọc .agents/skills/travel-product-owner/SKILL.md trong repository,
và áp dụng quy trình đó cho yêu cầu catalog đảo v0.
Đọc các tài liệu được liên kết khi cần để xác minh trạng thái hiện tại.
```

## Dùng trong Muse

Chưa xác định phiên bản/sản phẩm Muse hoặc cơ chế cài Skill native mà người dùng đang dùng. Bộ này cung cấp **hướng dẫn portable qua Markdown**, chưa tuyên bố Muse tự discover `.agents/skills`, hỗ trợ cú pháp `$`, hoặc đã được chạy kiểm trên Muse.

- Nếu Muse truy cập được repository: mở nhánh `codex-work`, yêu cầu đọc file Skill theo đường dẫn rồi thực hiện nhiệm vụ. Dùng prompt đọc file ở trên, không phụ thuộc cú pháp `$`.
- Nếu Muse chỉ nhận file/context: đính kèm `SKILL.md` của vai trò, tài liệu đầu vào liên quan được liệt kê trong Skill, và yêu cầu cụ thể. Ghi đường dẫn repo gốc để Muse trả về patch/tài liệu đúng chỗ. Không chỉ dán URL và giả định Muse đã đọc được nội dung.
- Nếu Muse không có shell/Git/build/sub-agent: thực hiện phần phân tích/tạo patch trong khả năng; báo rõ phần chưa thực thi. Chuyển patch về Codex để kiểm tra/build/commit khi cần. Không ghi “đã test”, “đã commit” hoặc “đã push” khi chỉ tạo hướng dẫn.
- Giữ nguyên cấu trúc repo để các link tương đối hoạt động. Nếu tách một Skill sang nơi khác, cung cấp lại nội dung các tài liệu liên quan.

Prompt khởi đầu:

```text
Bạn đảm nhiệm Product Owner cho Dọc miền Việt.
Đọc file .agents/skills/travel-product-owner/SKILL.md được cung cấp,
STATUS_REPORT.md và PRODUCT_BACKLOG.md hiện tại.
Áp dụng quy trình để đề xuất một batch cải thiện game offline Android/iOS.
Phân biệt nguồn kiểm chứng, giả thuyết và phần chưa biết.
Nếu không truy cập được một file/công cụ, nêu rõ thay vì tự suy đoán.
Trả về đề xuất có AC và đường dẫn file cần cập nhật.
```

## Quy tắc chung

- Mệnh lệnh người dùng và quy định của runtime có ưu tiên cao hơn Skill. Skill không cấp thêm quyền mạng, ký/phát hành, nhắn tin bên ngoài hoặc ghi đè thay đổi có sẵn.
- Core game 3D nằm ở `game3d/`; code Expo cũ là nhánh trải nghiệm trước, không mặc nhiên là gameplay 3D đang phát triển.
- Đọc Git và tài liệu hiện hành trước khi báo phiên bản/nhánh. Phân biệt source commit, local artifact và remote delivery.
- Phạm vi tỉnh/đảo phải có nguồn, ID, phiên bản, license và gap. Không suy ra đầy đủ từ số record hoặc số scene.
- Headless pass không xác nhận chất lượng hình ảnh; desktop render không xác nhận điện thoại; build Android không tạo IPA iOS; benchmark công khai không thay nghiên cứu người chơi.
- Các máy mục tiêu đã được người dùng nêu là Oppo Find X7 Ultra và iPhone 13. Chỉ ghi kết quả chạy thực khi có bằng chứng và OS/version cụ thể.
- Không đưa khóa ký, token, save riêng hoặc secret vào Skill/artifact/source. Không tự thêm đăng nhập, backend hoặc bắt buộc Internet vào vòng chơi offline.

## Kiểm tra bộ Skill

Từ thư mục repo, chạy:

```sh
python3 scripts/validate-team-skills.py
```

Lệnh kiểm cấu trúc, tên/description và link file nội bộ. Đây là kiểm tra gói tài liệu, không phải kiểm thử runtime Codex/Muse hoặc gameplay. Không cần build APK cho thay đổi tài liệu này.
