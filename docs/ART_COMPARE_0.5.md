# Đối chiếu hình ảnh 0.4 và 0.5

Ngày ghi nhận: 07/11/2026, UTC+7. Ảnh được render bằng Godot 4.6.3 Compatibility trên Xorg/Mesa llvmpipe (software renderer), không phải ảnh tạo bằng AI và không phải capture trên điện thoại.

## Điều kiện đối chiếu

- Baseline là snapshot `game3d/` từ commit `197432a196e1b58ca1fb2a8431677caca87eb412` của 0.4, trích bằng `git archive` sang `/tmp`, không sửa workspace hoặc tạo Git worktree.
- Cùng script `qa/paired_art_capture.gd`, UI ẩn, bóng đổ Bật, độ nhạy 1×, góc nhìn 69°, khung 1280×720.
- Ba camera tại station/lane: đầu tuyến 5/1,7; khúc cua 350/1,7; vịnh dừng 230/8. Camera origin và basis khớp chính xác giữa chín ảnh, sai số lớn nhất đo được 0.
- Far clip có chủ đích khác theo ngân sách cảnh: 0.4 là 420, Tiết kiệm 0.5 là 440, Chi tiết là 650. Không dùng thay đổi này để giả định hiệu năng tốt hơn.
- Manifest camera/statistics đi kèm PNG trong `screenshots05/`. Các vị trí là đơn vị cảnh minh họa, không phải tọa độ thực địa.

| Góc nhìn | Baseline 0.4 | 0.5 Tiết kiệm | 0.5 Chi tiết |
| --- | --- | --- | --- |
| Đầu tuyến | [Ảnh](screenshots05/travel05-pair-04-legacy-start.png) | [Ảnh](screenshots05/travel05-pair-05-economy-start.png) | [Ảnh](screenshots05/travel05-pair-05-detail-start.png) |
| Khúc cua | [Ảnh](screenshots05/travel05-pair-04-legacy-bend.png) | [Ảnh](screenshots05/travel05-pair-05-economy-bend.png) | [Ảnh](screenshots05/travel05-pair-05-detail-bend.png) |
| Vịnh dừng | [Ảnh](screenshots05/travel05-pair-04-legacy-stop.png) | [Ảnh](screenshots05/travel05-pair-05-economy-stop.png) | [Ảnh](screenshots05/travel05-pair-05-detail-stop.png) |

## Thay đổi nhìn thấy

Designer và root đã xem ảnh đối chiếu: asphalt có hạt nhỏ thay lớp noise lớn/mờ; lan can tối hơn; cây có dạng thông, cây tán nhiều cụm và cây thân mảnh, thêm tầng bụi thấp; mỏm đá là khối 3D; nền núi liền khối hơn, giảm lớp fog phủ bạc ở gần. Hai profile hiển thị lần lượt 1.398 và 2.724 instance trang trí trong cùng 48 nhóm; đây không phải số cây hoặc số FPS.

Chất lượng vẫn là **prototype stylized**. Núi xa còn trắng-cyan, một số mặt dốc vẫn phẳng, chân đá/bụi đặt thô và điểm dừng còn trống. Không kết luận đã đạt ảnh tham chiếu bán hiện thực/photoreal. Các ảnh cũng không xác minh mọi góc nhìn, mọi điểm dừng hoặc hiệu năng Oppo Find X7 Ultra/iPhone 13.

Ảnh bổ sung tại vịnh station 550, profile Chi tiết: [xem ảnh](screenshots05/stop-550-detail.png), [manifest](screenshots05/extra-stop-detail.json). Root đã xem: điểm dừng, cột mốc và đường hiện diện; nền núi nhạt và khoảng đất trống vẫn rõ. Ảnh này không thuộc bộ chín ảnh đối chiếu baseline.
