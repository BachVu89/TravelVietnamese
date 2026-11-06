# Dọc miền Việt — Đặc tả prototype

## Mục tiêu và quyết định sản phẩm

Game mobile kết hợp ba hướng chơi do chủ sản phẩm lựa chọn: khám phá bản đồ và câu đố văn hóa; theo chân nhân vật qua cốt truyện và nhiệm vụ; quản lý tiền cùng lựa chọn phương tiện cho chuyến đi. Nền tảng đích là Android và iOS, chơi hoàn toàn offline: không cần tài khoản, GPS, máy chủ hay kết nối mạng cho vòng chơi cốt lõi.

Prototype là một lát cắt chơi được của cả ba hướng, chưa phải game phát hành hoàn chỉnh. Nhân vật **An** mang cuốn hộ chiếu của bà đi tìm hiểu những miền đất và con người Việt Nam. Các giả định còn lại: giao diện dọc, nội dung tiếng Việt, phù hợp người chơi từ khoảng 10 tuổi trở lên; đây chưa phải phân loại độ tuổi của cửa hàng ứng dụng. Tiền trong game là tiền ảo, không mua bằng tiền thật.

Tuyến hành trình là hình minh họa du lịch, không phải bản đồ hành chính hoặc công cụ chỉ đường. Giá vé là thông số cân bằng game; phương tiện là lựa chọn tượng trưng cho phong cách di chuyển, không mô phỏng tuyến vận tải thực tế.

## Người chơi và nhu cầu

| Nhóm | Nhu cầu |
| --- | --- |
| Người thích du lịch | Khám phá địa danh, di sản và văn hóa Việt Nam |
| Học sinh và gia đình | Học kiến thức ngắn, dễ hiểu qua việc chơi |
| Người dùng khi không có mạng | Tiếp tục chơi và giữ tiến trình trên thiết bị |

## Vòng lặp chơi

1. Đọc lời dẫn và nhiệm vụ của An tại điểm hiện tại.
2. Trả lời câu hỏi văn hóa; trả lời sai được thử lại, không mất tiền.
3. Trả lời đúng để nhận dấu hộ chiếu và thưởng lần đầu.
4. Chọn phương tiện, trả chi phí và đến chặng kế tiếp.
5. Theo dõi hộ chiếu, ngân sách và nhật ký di chuyển; tiếp tục cho đến Cần Thơ.

## Phạm vi prototype đã chốt

- Tám điểm theo thứ tự: **Hà Nội → Hạ Long → Ninh Bình → Huế → Hội An → Đà Lạt → TP. Hồ Chí Minh → Cần Thơ**. Khởi đầu tại Hà Nội, không mất phí đến điểm đầu.
- Mỗi điểm có tên, lời dẫn cốt truyện/nhiệm vụ, một câu hỏi văn hóa với ba lựa chọn và đúng một đáp án, lời giải thích và một dấu hộ chiếu. Nhiệm vụ trong prototype chính là tìm hiểu và trả lời đúng câu hỏi tại điểm đó; chưa có hệ thống nhiệm vụ riêng.
- Chỉ trả lời câu hỏi tại điểm hiện tại. Trả lời sai không thay đổi tiến trình hoặc tiền và có thể thử lại. Trả lời đúng nhận dấu ngay; không tính điểm số, không có ngưỡng đạt hoặc điểm tốt nhất.
- Mỗi dấu chỉ nhận một lần và đồng thời thưởng **80** tiền ảo. Trả lời lại sau khi đã có dấu không sinh thêm dấu hoặc tiền.
- Chỉ đi tới điểm kế tiếp sau khi có dấu ở điểm hiện tại. Không nhảy cóc hoặc quay về điểm cũ trong prototype. Các điểm đã đi qua vẫn được ghi nhận trong hộ chiếu và lịch sử.
- Ví khởi đầu có **1.600**. Ba phương tiện: **xe khách 90**, **tàu hỏa 140**, **máy bay 210** cho mỗi chặng. Trước khi đi hiển thị giá và số dư; chỉ giao dịch hợp lệ mới trừ tiền, ghi chuyến đi và cập nhật vị trí.
- Cân bằng không cần cơ chế kiếm tiền bổ sung: kể cả chọn phương tiện đắt nhất cho cả bảy chặng, người chơi vẫn hoàn thành được tuyến. Tổng chi tối đa là 1.470; tám dấu thưởng tổng cộng 640; số dư cuối tối thiểu là 770. Logic vẫn phải từ chối giao dịch vượt ngân sách.
- Lưu tại thiết bị: phiên bản dữ liệu, tiền, điểm hiện tại, dấu và lịch sử chuyến đi gồm điểm đến/phương tiện/chi phí. Không lưu đáp án đang chọn hoặc bộ đếm điểm. Mở lại khôi phục tiến trình đã lưu, không thu lại phí di chuyển.
- Thu thập đủ tám dấu là hoàn thành hành trình. Dữ liệu nội dung được đóng gói cùng ứng dụng; không tải nội dung khi chơi.

## User stories và điều kiện nghiệm thu prototype

| Mã | User story | Điều kiện nghiệm thu |
| --- | --- | --- |
| US-01 | Là người chơi mới, tôi muốn bắt đầu ngay mà không đăng ký. | Mở game với tiến trình mới tại Hà Nội và 1.600 tiền; đọc lời dẫn và hoàn thành câu hỏi mà không cần mạng hoặc tài khoản. |
| US-02 | Tôi muốn biết mình đang ở đâu. | Hành trình thể hiện tám điểm theo thứ tự, vị trí hiện tại và dấu đã nhận; không thể đến điểm xa hơn điểm kế tiếp hoặc đi tiếp trước khi nhận dấu hiện tại. |
| US-03 | Tôi muốn hiểu câu chuyện và đặc trưng điểm đến. | Mỗi điểm có tên, lời dẫn tiếng Việt và nhiệm vụ gắn với câu hỏi địa phương; nhân vật An cùng cuốn hộ chiếu kết nối hành trình từ Hà Nội đến Cần Thơ. |
| US-04 | Tôi muốn học từ câu hỏi mà không bị phạt khi sai. | Mỗi điểm có một câu hỏi, ba lựa chọn và một đáp án đúng; trả lời sai có phản hồi và được thử lại, tiền và dấu giữ nguyên; trả lời đúng có lời giải thích. |
| US-05 | Tôi muốn nhận phần thưởng khi hoàn thành nhiệm vụ. | Lần đầu trả lời đúng tại điểm hiện tại thêm một dấu và 80 tiền; gọi lại thao tác hoàn thành không tạo dấu hoặc thưởng trùng. |
| US-06 | Tôi muốn sưu tập hộ chiếu. | Hộ chiếu phản ánh đúng các dấu đã nhận, tối đa tám; đủ tám dấu hiển thị trạng thái hoàn thành hành trình. |
| US-07 | Tôi muốn tiếp tục sau khi đóng ứng dụng. | Đóng và mở lại giữ đúng tiền, vị trí, dấu và lịch sử chuyến đi; có thể tiếp tục chơi offline và không bị thu phí chặng đã đi. |
| US-08 | Tôi muốn chọn phương tiện theo ngân sách. | Thấy ba phương tiện với giá 90/140/210; đi hợp lệ trừ đúng giá một lần, chuyển tới điểm kế tiếp và thêm đúng một chuyến; thao tác sai tuyến, thiếu dấu hoặc thiếu tiền không thay đổi tiến trình. |
| US-09 | Tôi muốn hoàn thành game dù chọn phương tiện đắt. | Bắt đầu từ dữ liệu mới, trả lời đúng và chọn máy bay cho cả bảy chặng vẫn nhận đủ tám dấu, không cần hồi phục tiền hoặc mạng; số dư cuối là 770. |
| US-10 | Tôi muốn nhìn lại hành trình. | Nhật ký/lịch sử thể hiện các chặng đã di chuyển cùng phương tiện và chi phí; số chuyến bằng số chặng đã đi và vẫn đúng sau khi mở lại. |
| US-11 | Tôi muốn thao tác thoải mái trên điện thoại. | Nội dung không bị che bởi vùng an toàn; lựa chọn có nhãn dễ đọc; phản hồi có chữ/ký hiệu, không chỉ màu; màn hình dài cuộn được. |

## Quy tắc nội dung

- Câu hỏi ngắn, một nghĩa, có đáp án và lời giải thích; tránh yêu cầu tra cứu mạng.
- Trước phát hành công khai, kiểm chứng kiến thức lịch sử/địa lý và tên địa danh bằng nguồn đáng tin cậy; không mặc định prototype đã qua biên tập chuyên môn.
- Không thu thập vị trí thực hoặc dữ liệu cá nhân trong vòng chơi prototype.
- Hình ảnh, âm thanh và phông chữ cần quyền sử dụng phù hợp; không phụ thuộc tài nguyên tải mạng để chơi.

## Kiểm chứng và giới hạn nghiệm thu

Các kiểm tra logic bắt buộc: đáp án đúng/sai; dấu và thưởng không trùng; không nhảy chặng; phí phương tiện và giao dịch không hợp lệ; hoàn thành tám điểm với phương tiện đắt nhất; lưu và đọc lại tiến trình; từ chối dữ liệu lưu không hợp lệ. Kiểm tra chức năng bắt buộc: hoàn thành một chặng không có mạng và khôi phục tiến trình sau khi mở lại.

Android và iOS là nền tảng đích; cần build và kiểm thử riêng trên môi trường hỗ trợ từng nền tảng trước khi tuyên bố đã chạy trên thiết bị. Bản web hoặc kiểm thử logic không thay thế kiểm thử thiết bị. Báo cáo kiểm thử phải phân biệt đã chạy, chưa chạy và lỗi còn tồn tại.

Lần chơi thử đầu đánh giá việc người chơi hiểu cách nhận dấu, chọn phương tiện và thấy tiến trình sau khi mở lại. Không tích hợp analytics mạng trong prototype.

## Hướng mở rộng sau prototype

- Bộ ba câu trở lên mỗi điểm, ngưỡng đạt hai phần ba và điểm tốt nhất; khi triển khai mới bổ sung tiêu chí nghiệm thu tương ứng. Đây không phải yêu cầu của prototype hiện tại.
- Quay lại điểm cũ, nhiệm vụ độc lập, nhiều nhân vật, hội thoại phân nhánh và trò chơi nhỏ về ẩm thực/di sản.
- Cân bằng kinh tế sâu hơn với thời gian, năng lượng và phương tiện theo tuyến thực tế; nếu có nguy cơ hết tiền phải thiết kế cơ chế hồi phục offline.
- Âm thanh, lồng tiếng offline, nhiều ngôn ngữ và khả năng tiếp cận mở rộng.

Chưa thuộc phạm vi: thế giới 3D di chuyển tự do, GPS, tài khoản, đồng bộ đám mây, quảng cáo, mua hàng, bảng xếp hạng, nhiều người chơi hoặc nội dung tải thêm. Ưu tiên phát triển tiếp được xác định sau khi chủ sản phẩm chơi thử bản cốt lõi.
