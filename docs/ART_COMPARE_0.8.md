# Đối chiếu hình ảnh 0.6 và 0.8

Ngày ghi nhận: 07/11/2026, UTC+7. Ảnh render bằng Godot 4.6.3 Compatibility trên Xvfb/Mesa (software renderer), không phải ảnh AI và không phải capture điện thoại. Batch 0.8 trên nhánh `muse-work` theo phản hồi trực tiếp của người dùng: bản trước vẫn "tạm bợ" về nhân vật và cảnh quan, và cho phép dùng tài nguyên miễn phí.

## Điều kiện đối chiếu

- Cùng script `qa/paired_art_capture.gd`, UI ẩn, bóng Bật, góc nhìn 69°, khung 1280×720, ba camera cố định như các batch trước (đầu tuyến 5/1,7; khúc cua 350/1,7; vịnh dừng 230/8) với manifest JSON trong `screenshots08/`.
- Phía "trước" là bộ ảnh 0.6 tại `docs/screenshots06/` (cùng camera). Phía "sau" là 0.8: Tiết kiệm và Chi tiết.
- Khác biệt nền tảng: 0.8 dùng tài nguyên CC0 thật (xem `ASSETS_CC0.md`) thay cho bề mặt/cây tự vẽ; ánh sáng môi trường vì thế cũng đổi (HDRI), đúng bản chất của batch — đây không còn là đối chiếu "chỉ đổi một biến".

| Góc nhìn | 0.6 Chi tiết | 0.8 Tiết kiệm | 0.8 Chi tiết |
| --- | --- | --- | --- |
| Đầu tuyến | [Ảnh](screenshots06/travel06-pair-06-detail-start.png) | [Ảnh](screenshots08/travel08-pair-08-economy-start.png) | [Ảnh](screenshots08/travel08-pair-08-detail-start.png) |
| Khúc cua | [Ảnh](screenshots06/travel06-pair-06-detail-bend.png) | [Ảnh](screenshots08/travel08-pair-08-economy-bend.png) | [Ảnh](screenshots08/travel08-pair-08-detail-bend.png) |
| Vịnh dừng | [Ảnh](screenshots06/travel06-pair-06-detail-stop.png) | [Ảnh](screenshots08/travel08-pair-08-economy-stop.png) | [Ảnh](screenshots08/travel08-pair-08-detail-stop.png) |

## Thay đổi nhìn thấy

Root đã xem render và xác nhận:

- **Cây và bụi:** biến mất hoàn toàn các "kẹo mút" cầu-trên-trụ của 0.6. Cây nay là model có tán lá cắt lớp, thân và cành rõ; dương xỉ thành thảm lá sát đường; cỏ túm và bụi hoa điểm xuyết. Mật độ instance hiển thị giảm (Tiết kiệm 922 / Chi tiết 1.811 so với 1.682 / 3.323) vì mỗi model giàu chi tiết hơn nhiều — đây là đánh đổi có chủ đích, đã ghi trong PO-15.C.
- **Bề mặt:** mặt đường là nhựa quét thật có vân và độ nhám ướt; sườn đồi là mặt đất lá/cỏ quét thật (nhuộm xanh về tông tham chiếu); vách đá sẫm màu đá ướt thay cho dốc nâu trơn; bầu trời là ảnh HDRI đường đèo nhiều mây, ánh sáng ambient mềm và đều hơn hẳn ánh sáng phẳng trước đây.
- **Xe và người (nhìn từ camera đuổi):** thêm gương cuống, đèn hậu đỏ, thùng hông vải hai bên, cuộn hành lý và ba lô có túi/cuộn trên; silhouette đầy đặn và "có thiết kế" hơn. Đèn pha tròn/xi-nhan/dè/ống xả chỉ rõ khi nhìn gần hoặc từ phía trước — camera đối chiếu ở phía sau nên chưa thể hiện hết.
- **Quá trình chọn lọc có bằng chứng:** vòng chụp đầu tiên lộ hai lỗi đã sửa trước khi chốt — texture vách đá đầu tiên (`cliff_side`) quá cam và hai mẫu cây lá đỏ mùa thu lẫn trong gói; đã đổi sang `dark_rock`/`aerial_grass_rock` sau khi đo màu trung bình của texture và loại hai mẫu lá đỏ khỏi danh sách rải.

## Phần còn xa ảnh tham chiếu

Vẫn chưa phải photoreal: cây là stylized (sạch, có chủ đích, nhưng không phải cây quét thật — bản quét thật quá nặng cho mobile, xem ASSETS_CC0.md); nhân vật và xe vẫn dựng theo khối dù đã nhiều chi tiết hơn; núi xa vẫn là silhouette trơn trong sương; bầu trời HDRI bị fog che phần lớn nên chủ yếu đóng góp qua ánh sáng. Kết luận trung thực: 0.8 hết "tạm bợ" ở cấp độ bề mặt và thảm thực vật, còn cấp độ model nhân vật/xe thật và địa hình quét thật là việc của hướng khác (ví dụ chuyển công cụ/engine) chứ không phải một batch nữa trong Godot Compatibility.
