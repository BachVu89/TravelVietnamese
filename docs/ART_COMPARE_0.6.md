# Đối chiếu hình ảnh 0.5 và 0.6

Ngày ghi nhận: 07/11/2026, UTC+7. Ảnh được render bằng Godot 4.6.3 Compatibility trên Xvfb/Mesa llvmpipe (software renderer), không phải ảnh tạo bằng AI và không phải capture trên điện thoại. Batch thực hiện trên nhánh `muse-work` theo yêu cầu trực tiếp của người dùng kèm ảnh design tham chiếu đèo Khánh Lê.

## Điều kiện đối chiếu

- Baseline là code 0.5 tại commit `39885ab` của `codex-work` (điểm rẽ nhánh `muse-work`), chụp lại bằng chính working tree đã stash thay đổi 0.6, không dùng ảnh 0.5 cũ.
- Cùng script `qa/paired_art_capture.gd`, UI ẩn, bóng đổ Bật, độ nhạy 1×, góc nhìn 69°, khung 1280×720.
- Ba camera tại station/lane: đầu tuyến 5/1,7; khúc cua 350/1,7; vịnh dừng 230/8. Camera origin và basis khớp giữa các ảnh cùng bộ (manifest JSON đi kèm trong `screenshots06/`).
- Far clip khác theo preset như 0.5: Tiết kiệm 440, Chi tiết 650. Fog density có chủ đích tăng ở 0.6 (Chi tiết 0,0021; Tiết kiệm 0,0028) để tạo lớp sương; đây là thay đổi mỹ thuật của batch, đã công bố trong PO-13.A.

| Góc nhìn | Baseline 0.5 (Chi tiết) | 0.6 Tiết kiệm | 0.6 Chi tiết |
| --- | --- | --- | --- |
| Đầu tuyến | [Ảnh](screenshots06/travel06-pair-05-legacy-start.png) | [Ảnh](screenshots06/travel06-pair-06-economy-start.png) | [Ảnh](screenshots06/travel06-pair-06-detail-start.png) |
| Khúc cua | [Ảnh](screenshots06/travel06-pair-05-legacy-bend.png) | [Ảnh](screenshots06/travel06-pair-06-economy-bend.png) | [Ảnh](screenshots06/travel06-pair-06-detail-bend.png) |
| Vịnh dừng | [Ảnh](screenshots06/travel06-pair-05-legacy-stop.png) | [Ảnh](screenshots06/travel06-pair-06-economy-stop.png) | [Ảnh](screenshots06/travel06-pair-06-detail-stop.png) |

## Thay đổi nhìn thấy

Root đã xem render đối chiếu và xác nhận các thay đổi sau hiện diện trong scene, không chỉ trong code:

- **Núi xa:** ba lớp ridge nay có ở cả hai phía tuyến, đỉnh răng cưa thay cho khối trơn, tông xanh lam–lục đậm hơn ở lớp gần và nhạt dần ra xa; lỗi "trắng-cyan" của 0.5 giảm rõ, lớp xa vẫn nhạt vì sương — đúng ý đồ phân lớp không khí. Dải sương thấp alpha nhẹ nằm trên thung lũng, không che mặt đường ở cả ba góc.
- **Trời và ánh sáng:** đỉnh trời xanh xám sâu hơn, chân trời sáng sương; nắng dịu (0,9) và ambient mát hơn cho cảm giác u ám sau mưa gần với ảnh tham chiếu hơn bầu trời phẳng của 0.5.
- **Mặt đường:** vũng nước tối bóng thấp xuất hiện rải rác trên asphalt (nhìn rõ ở khúc cua); lan can có đoạn gỉ nâu xen kẽ; vách đá và sườn cỏ tối màu hơn, bớt cảm giác rửa sáng.
- **Đạo cụ:** dãy blốc bê tông ở mép ngoài hai vịnh dừng (nhìn rõ ở ảnh vịnh dừng); cột mốc trắng–đỏ "ĐÀ LẠT / KHÁNH LÊ" tại station 60/245/565 (nhỏ trong khung kiểm chứng, đọc rõ khi tới gần trong game); thác bậc thang kèm vệt đá ướt trên vách tại station 372 (nhìn thấy ở ảnh khúc cua, phía vách trái) và 470.
- **Xe và người:** xe chuyển silhouette Cub — chắn chân trước trắng bạc phếch, baga sau với cuộn hành lý có dây chằng; người lái có ba lô và mũ xám đậm thay cho mũ kem sáng trước đây, gần silhouette ảnh tham chiếu hơn.
- **Thực vật:** tán cây/bụi đậm và bão hòa hơn; thêm dải dương xỉ sát mép đường; cây phía thung lũng vươn tới lateral 100 nên sườn xa bớt trống. Instance trang trí hiển thị: Tiết kiệm 1.682 / Chi tiết 3.323 (0.5: 1.398 / 2.724); đây không phải số cây hoặc số FPS.

## Phần còn xa ảnh tham chiếu

Chất lượng vẫn là **prototype stylized**. Núi xa còn trơn, không có texture rừng chi tiết; vách đá và sườn vẫn là mặt lớn ít chi tiết; thác là khối bậc thang tối giản; vịnh dừng còn trống trải; xe/người vẫn là khối low-poly không animation. Không kết luận đã đạt ảnh tham chiếu bán hiện thực/photoreal, và các ảnh này không xác minh hiệu năng hay cảm ứng trên Oppo Find X7 Ultra / iPhone 13.
