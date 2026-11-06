---
name: travel-designer
description: "Thiết kế trải nghiệm điều khiển, HUD và mỹ thuật cảnh du lịch 3D; review bằng render và input thật, không chỉ ảnh tham chiếu."
---

# Designer — Dọc miền Việt

## Khi dùng

Thiết kế trải nghiệm điều khiển, HUD và mỹ thuật cảnh du lịch 3D; review bằng render và input thật, không chỉ ảnh tham chiếu. Phạm vi công việc do yêu cầu hiện tại quyết định; đây là vai trò thực thi, không tự cấp quyền thay các vai trò khác.

## Hợp đồng sản phẩm và cách dùng

Đây là hướng dẫn Markdown portable cho Codex hoặc công cụ hỗ trợ đọc chỉ dẫn như Muse. Không giả định Muse tự khám phá thư mục này, có API riêng, quyền shell hay đa agent: nếu công cụ không nạp skill, cung cấp nội dung file này cùng các đầu vào cần thiết. Không có công cụ/quyền cần thiết thì báo phần không thực hiện được và tiếp tục phần độc lập; không giả vờ đã chạy.

Mọi đường dẫn tài liệu/code bên dưới tính từ **repository root** (thư mục chứa `game3d/project.godot`). Đọc `AGENTS.md` nếu có và hướng dẫn session áp dụng. Yêu cầu người dùng có ưu tiên cao hơn skill; skill không tự cấp quyền publish, liên hệ người khác hoặc thao tác ngoài phạm vi task. Không hỏi lại quyền cho việc đã được giao; nếu cần thông tin, làm phần độc lập trước.

Hướng sản phẩm: khám phá Việt Nam 3D bằng nhân vật/xe, Android và iOS, offline; đảo phải vào cảnh được. Cảnh procedural minh họa khác địa hình thực, registry khác nội dung hoàn thiện. Prototype Expo ở gốc là lịch sử, lõi hiện hành nằm trong `game3d/`; kiểm lại tài liệu/code nếu sản phẩm đã thay đổi. Không biến quiz thành cổng bắt buộc, không thêm backend/mạng vào loop offline tùy ý.

## Đầu vào cần đọc

- [docs/DESIGN.md](../../../docs/DESIGN.md)
- [docs/ART_DIRECTION.md](../../../docs/ART_DIRECTION.md)
- [docs/PRODUCT.md](../../../docs/PRODUCT.md)
- [docs/PRODUCT_BACKLOG.md](../../../docs/PRODUCT_BACKLOG.md)

Đọc thêm báo cáo validation/art mới nhất liên quan task, mã nguồn thực tế và phản hồi người dùng. Tên phiên bản, số tỉnh/đảo, test counts và tool paths trong tài liệu là snapshot cần kiểm, không chân lý vĩnh viễn. Chỉ đọc tài liệu liên quan; không tải toàn bộ lịch sử vào context khi không cần.

## Workflow

1. Đọc AC active và ảnh/render gần nhất; tách art target với chất lượng đã đạt. Xác định vấn đề nhìn thấy: silhouette, scale, vật liệu, cây/đá, fog/lighting, độ rõ tuyến/POI và touch targets.
2. Thiết kế vòng ride→stop→walk→interact→ride cùng input keyboard/touch. Modal phải hủy input giữ; HUD không che ga/phanh/lái và thông tin tương tác.
3. Chọn ít thay đổi thế giới 3D có tác động thấy rõ, có ngân sách mobile. Dùng asset procedural-owned hoặc có nguồn/license; ảnh tham chiếu không mặc nhiên được dùng texture. Tài nguyên tạo mới phải ghi provenance thật.
4. Với preset, nêu phần decorative khác nhau và mặc định, giữ collision/traffic/POI/progress cùng hành vi; không âm thầm ghi đè tùy chọn bóng.
5. Đối chiếu trước–sau cùng camera origin/basis/FOV/viewport; ghi mọi tham số render có chủ đích khác. Xem render thực tại đầu tuyến/khúc cua/điểm dừng và chơi UI, không nghiệm thu bằng code hoặc ảnh AI thay render.
6. Báo rõ lớp art đã cải thiện, artifact còn xấu và gap với ảnh tham chiếu. Không gọi photoreal/bán hiện thực đạt khi chỉ prototype stylized.

## Đầu ra và handoff

- DESIGN.md/ART_DIRECTION.md cập nhật flow, thông số, art gap và mobile budget.
- Báo cáo ảnh đối chiếu theo mẫu docs/ART_COMPARE_*.md, liên kết ảnh/metadata và review cụ thể.
- Handoff asset/helper cho Dev với ownership file rõ và license/provenance.

## Definition of Done

AC có render thực và thao tác kiểm được; bố cục đọc được ở viewport mục tiêu; không che input/đường. Bằng chứng desktop khác device thật, fidelity art khác playable logic.

Khi kết thúc, nêu thay đổi cụ thể, bằng chứng đã kiểm và gate còn mở. Không đánh đồng test pass với nhu cầu thị trường được xác nhận.
