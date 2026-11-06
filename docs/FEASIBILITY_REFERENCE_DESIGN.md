# Đánh giá khả thi thiết kế tham chiếu — góc nhìn BA

## Kết luận

**Team hiện tại có thể phát triển prototype gameplay lái xe máy, xuống xe đi bộ, giao thông đơn giản và chụp ảnh trong game. Chưa có cơ sở cam kết hình ảnh chân thực như ảnh tham chiếu, chạy offline trên Android/iOS, cho toàn bộ 34 tỉnh/thành và mọi đảo.** Đánh giá ban đầu không phải cam kết chất lượng tham chiếu hoặc lịch giao hàng. **Cập nhật quyết định:** người dùng đã duyệt triển khai vertical slice 0.4; phạm vi hiện hành nằm trong PO-10 và phần 0.4 của [PRODUCT.md](PRODUCT.md). Giữ Godot hiện tại để kiểm chứng; chưa duyệt đổi engine.

Nguồn tham chiếu của đánh giá này là mô tả ảnh do nhóm điều phối cung cấp: góc nhìn thứ ba, nhân vật đi xe máy có hành lý trên đèo gợi Khánh Lê/Đà Lạt; đường nhựa ướt, cây/đá chi tiết, núi xa trong sương, xe tải/ô tô trên đường cong, đồng hồ tốc độ và chế độ chụp ảnh/điện thoại. Chưa có tệp ảnh cục bộ để BA tự kiểm tra; chưa xác định ảnh là concept, render dựng sẵn hay frame gameplay trên thiết bị nào. Không suy ra địa điểm chính xác hoặc chất lượng chạy thực từ mô tả ảnh.

## So với nền hiện có

Project hiện dùng Godot 4.6.3, renderer Compatibility; có nhân vật đi bộ, camera, va chạm, POI, lưu offline, tutorial và điều hướng. Registry 47 mục gồm 34 tỉnh/thành và 13 vùng đảo; phần lớn scene là địa hình/khối minh họa sinh theo thuật toán. Có bản dựng thử Android và kiểm tra desktop/headless; chưa có benchmark điện thoại đại diện hoặc iOS thực được dùng làm cơ sở cho cam kết hình ảnh.

Ảnh tham chiếu đòi hỏi một bước thay đổi lớn về tài nguyên và sản xuất nội dung: nhân vật/xe có animation, vật liệu PBR, địa hình có bố cục, cây cỏ nhiều lớp, ánh sáng/sương và đường có chuyển tiếp bề mặt. Thêm model xe lên cảnh low-poly hiện tại sẽ chưa tạo ra chất lượng đó.

Team BA/PO/SA/Developer/Tester/Designer bằng AI có thể phân rã yêu cầu, dựng hệ thống, tạo blockout, kiểm thử và phối hợp pipeline. Điều đó không tự cung cấp thư viện asset AAA có giấy phép, nghệ sĩ môi trường/nhân vật/animation chuyên nghiệp, dữ liệu khảo sát hoặc thiết bị để đo. Các đầu vào ấy phải được bổ sung hoặc thay bằng mục tiêu hình ảnh phù hợp với tài nguyên thực tế.

## Phân biệt các mức có thể hứa

| Hạng mục | Có thể làm prototype | Chưa được cam kết |
| --- | --- | --- |
| Lái xe | Ga/phanh/lái, camera bám, va chạm, lên/xuống xe và trạng thái lưu | Mô phỏng động lực học xe máy chính xác, animation/tiếp xúc đạt chất lượng ảnh |
| Đi bộ | Tái sử dụng nền điều khiển, liên kết POI và xe | Nhân vật chân thực, animation đầy đủ trên mọi bề mặt |
| Giao thông | Vài xe AI đi theo làn/tuyến, giữ khoảng cách và xử lý trường hợp chặn cơ bản | Giao thông thế giới mở, mọi tình huống đường đèo hoặc mật độ cao trên mọi máy |
| Chụp ảnh | Camera trong game, ẩn HUD, khung hình và lưu album cục bộ | Hình ảnh photoreal hoặc chất lượng ảnh vượt khả năng render scene; quyền dùng camera/album hệ điều hành chưa được chốt |
| Hình ảnh | Một cảnh có chủ đích mỹ thuật và tài nguyên licensed, tối ưu riêng | Tương đương ảnh concept trên điện thoại khi chưa benchmark |
| Phạm vi quốc gia/đảo | Pipeline mở rộng nội dung và chỉ số coverage | Tái dựng toàn quốc chi tiết chỉ từ registry tên; 13 vùng đảo không phải mọi đảo có tên |

## Các gói công việc và rủi ro chính

| Gói | Đầu vào/đầu ra cần có | Rủi ro cần giải quyết |
| --- | --- | --- |
| Gameplay xe và đi bộ | Controller xe, lên/xuống, camera, HUD tốc độ, lưu checkpoint; định nghĩa mức arcade | Xe kẹt hoặc rơi khỏi đường, xuyên va chạm ở tốc độ cao, camera che khuất, chuyển trạng thái gây mất save |
| Đường và địa hình | Thiết kế độ cong/dốc, mặt đường, lề, lan can, vách núi, khoảng dừng chân | Ảnh đơn không cung cấp mặt sau/cao độ; dữ liệu GIS có thể thiếu hoặc không đủ độ phân giải; đường minh họa phải được ghi nhãn |
| Mỹ thuật và animation | Xe, người, hành lý, rig, animation, texture và vật liệu đồng bộ | Chất lượng asset không đồng đều; texture/mesh nặng; cần người phụ trách mỹ thuật 3D để đạt chuẩn hình ảnh và tối ưu |
| Cây, ánh sáng, thời tiết | LOD cây/đá, instancing, vật liệu đường ướt, sương và bố cục tầm nhìn | Lá alpha gây overdraw, bóng và phản xạ tốn GPU, ánh sáng không nhất quán; sương không được dùng để che lỗi nội dung mà phá trải nghiệm |
| Giao thông | Spline/làn, spawn/cull, va chạm và xử lý xe bị chặn | Kẹt xe, đối đầu, xe bật/rơi ở cua/dốc; số xe phải dựa trên đo CPU/physics |
| Camera ảnh và UI | Chế độ ngắm/chụp/album offline, input không xung đột ga/lái | Chi phí render/capture, định dạng và dung lượng album, quyền hệ điều hành nếu xuất ảnh; mặc định album trong game có thể tránh quyền không cần thiết |
| Offline và dung lượng | Nén texture, đóng gói/chunk, lưu tiến trình, ngân sách vùng đã cài | Gói toàn quốc và mọi đảo chi tiết có thể rất lớn; không được ngầm yêu cầu streaming mạng để giữ lời hứa offline |
| Nền tảng và QA | Android/iPhone đại diện, profiler, test nhiệt/pin/bộ nhớ và ký iOS | Desktop đẹp không chứng minh mobile; thiếu Xcode/thiết bị và test dài ngăn cam kết đa nền tảng |
| License/GIS | Sổ asset có nguồn, license, quyền sửa/phân phối offline; nguồn đường/địa danh | Asset preview hoặc ảnh trên mạng không cấp quyền dùng; dữ liệu thương mại/ODbL/CC có nghĩa vụ khác nhau cần rà riêng |

## Đề xuất kiểm chứng: một đoạn đèo 500 m–1 km

Đề xuất này đã được người dùng duyệt thành batch 0.4: tuyến mục tiêu **750 đơn vị scene**, cửa đo centerline **700–800**, là cảnh minh họa chứ không phải chiều dài đường thực. Áp dụng PO-10.A–J trong PRODUCT.md. Chọn một đoạn đèo ngắn có quyền dùng dữ liệu/asset và đủ tài liệu tham chiếu; có đường cong, một đoạn dốc, điểm dừng ngắm cảnh, một khu cây/đá và tầm nhìn núi xa. Chỉ gọi đúng tên địa điểm thực khi đã xác minh nội dung; nếu chưa có dữ liệu, dùng cảnh lấy cảm hứng và ghi rõ minh họa.

Scope 0.4 đã chốt gồm một xe máy điều khiển được, nhân vật lên/xuống đi bộ, ít nhất hai xe traffic, hai điểm dừng có guard và lưu offline. **Chụp ảnh/album được hoãn**, không nằm trong cửa nghiệm thu batch này. Giới hạn môi trường/ánh sáng cố định để tách chất lượng mỹ thuật khỏi chi phí hệ thống ngày đêm/thời tiết động. Không cần lập tức làm toàn tỉnh hoặc toàn tuyến đèo.

### Cửa chất lượng trước khi mở rộng

1. **Bằng chứng hình ảnh:** dựng gameplay realtime trên điện thoại mục tiêu và so sánh cùng góc máy với moodboard; PO/designer đánh giá silhouette, vật liệu, màu, chiều sâu, nhân vật và mật độ cảnh. Không dùng ảnh render ngoại tuyến làm bằng chứng đã đạt realtime.
2. **Gameplay:** thực hiện hết đoạn thử, phanh/dừng/đi tiếp, lên xuống xe, tránh xe AI, tương tác POI; photo mode được hoãn khỏi batch 0.4. Camera/đa chạm không kẹt, không xuyên lan can hoặc mất vị trí lưu. Công bố rõ arcade hay simulation.
3. **Hiệu năng:** chọn và ghi model/OS/RAM của Android và iPhone đại diện trước test. Mục tiêu đề xuất ban đầu là tối thiểu 30 FPS với khung hình ổn định; phải ghi frame-time percentile, stutter, GPU/CPU time và RAM thực đo, không chỉ FPS trung bình. Đây là target để đánh giá, chưa là số đã đạt.
4. **Phiên dài:** chạy tuyến lặp ít nhất 20 phút để quan sát nhiệt, giảm hiệu năng, pin, memory growth và crash; kiểm thử mất focus, khóa màn hình và trở lại game. Mốc thời lượng là protocol đề xuất, không khẳng định đã test.
5. **Offline/dung lượng:** cài nội dung rồi mở lạnh ở chế độ máy bay, chạy vòng lái–đỗ–đi bộ được; ghi kích thước cài đặt, tải scene, peak RAM và kích thước save (ảnh chỉ đo khi photo mode được triển khai). Chốt ngân sách nhân rộng sau khi có số đo, không lấy kích thước một scene suy tuyến tính toàn quốc.
6. **Quyền tài nguyên:** mọi asset/data đã có nguồn, license và attribution; phần chưa có quyền không tính là nội dung sẵn sàng phát hành.
7. **Quyết định go/no-go:** chỉ mở rộng khi gameplay, hình ảnh trên phone, quyền tài nguyên và ngân sách offline cùng đạt. Nếu không đạt, giảm mục tiêu hình ảnh/mật độ, thu hẹp phần tái dựng hoặc bổ sung chuyên môn và tài nguyên trước khi lên kế hoạch quốc gia.

## Đánh giá engine trước khi đổi hướng

Godot Compatibility hiện được chọn cho prototype hỗ trợ GPU mobile; không có bằng chứng rằng cấu hình hiện tại đã đáp ứng độ chân thực tham chiếu. Cũng không thể kết luận chỉ cần chuyển Unity/Unreal hoặc bật renderer khác là đạt. SA cần so sánh khả năng shader/ánh sáng/LOD/instancing, pipeline asset, công cụ profiling, Android/iOS và chi phí bảo trì bằng cùng một scene nhỏ, cùng asset và thiết bị nếu việc đánh giá được giao tiếp.

Đổi engine hoặc renderer có thể ảnh hưởng input, save, export, license, shader và toàn bộ test đã có. Không thực hiện migration trong batch kiểm chứng 0.4. Lựa chọn được đưa ra sau bằng chứng slice, không dựa vào ảnh quảng bá của engine.

## Cam kết hợp lý ở thời điểm này

Có thể cam kết phân rã và kiểm chứng prototype; chưa thể cam kết chất lượng ảnh, thời gian, ngân sách hoặc dung lượng toàn quốc khi chưa chốt asset, thiết bị, mức tái dựng và nguồn đảo. Người dùng hiện đã duyệt triển khai slice. Team thực hiện theo PO-10/PRODUCT.md và kiểm thử trước khi báo hoàn thành; việc duyệt slice không tự xác nhận đạt chất lượng hình ảnh, FPS, Android/iOS thực hoặc phạm vi toàn quốc.
