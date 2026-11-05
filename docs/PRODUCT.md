# Dọc miền Việt — Game khám phá Việt Nam 3D

## Mục tiêu sản phẩm đã điều chỉnh

Người chơi điều khiển nhân vật di chuyển, nhìn ngắm và tương tác tại các địa điểm trên bản đồ **3D** của Việt Nam. Game mobile hướng tới **Android và iOS**, chơi **offline** sau khi cài đặt gói nội dung được công bố. Mục tiêu phạm vi toàn sản phẩm là bao phủ tất cả tỉnh/thành hiện hành và các đảo trong bộ dữ liệu được thống nhất, không dừng ở tám điểm du lịch.

Điều khiển nhân vật trong không gian 3D là trải nghiệm chính. Bản chọn đáp án theo tuyến tám chặng trước đây không đáp ứng mục tiêu này; đặc tả cũ được lưu tại [legacy/PRODUCT_QUIZ_PROTOTYPE.md](legacy/PRODUCT_QUIZ_PROTOTYPE.md) để tham khảo lịch sử. Các quy tắc cũ về phí 90/140/210, tiền 1.600 và thưởng 80 không tự động trở thành điều kiện nghiệm thu game 3D.

## Trải nghiệm cốt lõi

1. Chọn tỉnh/thành hoặc điểm đến trên bản đồ tổng quan, xem trạng thái nội dung đã có.
2. Vào một cảnh 3D, điều khiển nhân vật đi quanh khu vực tham quan, xoay camera và quan sát cảnh vật.
3. Đến gần địa danh hoặc nhân vật địa phương để tương tác, đọc thông tin, thực hiện nhiệm vụ khám phá và nhận dấu hộ chiếu.
4. Ghi nhật ký chuyến đi, lưu tiến trình và tiếp tục tại điểm khác khi muốn.

Nhân vật An và cuốn hộ chiếu có thể tiếp tục được dùng làm khung cốt truyện, nhưng lời dẫn không thay thế hoạt động di chuyển thực. Câu đố văn hóa là hoạt động phụ tùy chọn, không phải cổng bắt buộc để đi lại. Quản lý ngân sách và phương tiện là lớp gameplay sau khi vòng khám phá 3D đã được kiểm chứng; không khóa việc tham quan bản mẫu vì hết tiền.

## Phạm vi địa lý và ý nghĩa của “đủ”

Registry hiện tại có **34 tỉnh/thành và 13 vùng đảo/đặc khu**, tổng 47 entry, lấy từ dataset cộng đồng MIT đã pin commit trong `game3d/data/geography/sources.json`. Con số 34 khớp snapshot nguồn; tên/mã và hiệu lực pháp lý chưa được đối soát trực tiếp đầy đủ với văn bản nhà nước. 13 vùng đảo không phải toàn bộ đảo có tên, không phải 13 đảo đơn. Xem [GEOGRAPHIC_SCOPE.md](GEOGRAPHIC_SCOPE.md) để biết provenance, khoảng trống và lộ trình bổ sung.

Phải theo dõi riêng ba lớp:

| Lớp | Ý nghĩa | Điều không được suy ra |
| --- | --- | --- |
| Danh mục địa lý | Bản ghi tỉnh/thành, địa danh, đảo; mã và nguồn dữ liệu | Có đủ bản ghi không có nghĩa mọi nơi đã có cảnh chơi được |
| Nội dung bản đồ tổng quan | Marker, nhãn và quan hệ địa lý đã kiểm chứng | Marker không phải địa hình hoặc mô hình 3D hoàn chỉnh |
| Cảnh tham quan 3D | Khu vực có nhân vật điều khiển, mặt đất/va chạm và POI tương tác đã kiểm thử | Một cảnh đại diện không tái hiện toàn bộ lãnh thổ của tỉnh |

Tên du lịch như Hạ Long, Hội An, Đà Lạt hoặc Cần Thơ có thể là điểm đến/địa danh; chúng phải liên kết với đơn vị quản lý hiện hành bằng dữ liệu được xác minh. Không tự suy ra đơn vị hành chính chỉ từ tên du lịch hoặc mô hình trước sắp xếp.

**Phạm vi đảo đã được bổ sung:** mọi đảo thuộc bộ dữ liệu thống nhất đều phải vào được cảnh địa hình 3D có điều khiển và tương tác; chỉ có marker là chưa đạt yêu cầu. Đảo tiêu biểu có cảnh được thiết kế thủ công với chi tiết riêng. Những đảo khác có thể dùng địa hình sinh bằng thuật toán, nhưng phải ghi rõ là minh họa, không phải bản số hóa địa hình thực địa. Mỗi cảnh phải liên kết đúng ID đảo, có bề mặt đi lại, điểm tương tác và trạng thái nội dung; không mô tả cảnh thuật toán là mô phỏng chính xác hòn đảo.

Phải xác định dataset, giấy phép, phiên bản, tiêu chí loại trừ và tổng số bản ghi trước khi kiểm đếm. Snapshot hiện chỉ có 13 vùng đảo/đặc khu; chưa có danh mục mọi đảo thành phần có tên, tọa độ, đường bờ hoặc cao độ thực. Chưa có cơ sở để tuyên bố “đầy đủ mọi đảo Việt Nam”; báo cáo khoảng trống giữa dataset và mục tiêu đầy đủ là bắt buộc. Việc xây dựng điều khiển và cảnh 3D không phụ thuộc vào việc đã tìm được dataset đầy đủ.

Bản đồ và cảnh là mô phỏng du lịch có chọn lọc, không phải công cụ dẫn đường hoặc bản đồ ranh giới pháp lý. Địa danh liên quan khu vực có tranh chấp cần nguồn và chú thích phù hợp; không đưa khẳng định chủ quyền đang tranh chấp thành dữ kiện không điều kiện.

## Các mốc phát triển và nghiệm thu

| Mốc | Đầu ra | Cửa nghiệm thu |
| --- | --- | --- |
| M0 — Nền dữ liệu và thiết kế | Danh mục tỉnh/thành có nguồn; định nghĩa dataset đảo; schema trạng thái nội dung và quy tắc bản đồ | Báo cáo rõ dữ liệu đã/chưa xác minh, số bản ghi và số cảnh; không coi registry là coverage 3D |
| M1 — Bản mẫu 3D chơi được | Ít nhất một cảnh đại diện, nhân vật điều khiển, camera, va chạm và ít nhất hai POI; tài nguyên nội bộ; lưu vị trí/tiến trình | Chơi thử hoàn chỉnh offline trên Android; iOS được kiểm thử riêng khi có môi trường phù hợp; minh bạch trạng thái từng nền tảng |
| M2 — Mẫu mở rộng có đảo | Một cảnh đất liền bổ sung và một cảnh đảo có nguồn nội dung được xác minh; cùng pipeline dữ liệu và tương tác | Kiểm tra chuyển cảnh, lưu tiến trình, bộ nhớ và hiệu năng; kiểm chứng cảnh đảo thủ công và cảnh thuật toán trước khi nhân rộng |
| M3 — Phủ các tỉnh/thành | Mỗi tỉnh/thành trong registry được xác minh có ít nhất một cảnh đại diện đã nghiệm thu | Báo cáo coverage từng mã tỉnh, cảnh/POI và kết quả kiểm thử Android/iOS; không chỉ đếm marker |
| M4 — Phủ đảo theo phạm vi được chốt | Mỗi đảo trong dataset đã chốt vào được cảnh 3D tương tác; đảo tiêu biểu có chi tiết thủ công | Đối soát từng ID với dataset chốt, kiểm tra trùng/thiếu, tài nguyên offline và trạng thái cảnh; ghi rõ ngoại lệ và khoảng trống dataset; marker không tính là cảnh |

M1 là mốc để chủ sản phẩm đánh giá đúng hướng chơi trước khi nhân rộng toàn quốc. M1 không được mô tả là bản đã có đủ mọi tỉnh/thành hoặc đảo. Một địa hình chung thay tên không tự đạt nghiệm thu nội dung địa danh đặc trưng. Cảnh đảo sinh thuật toán có thể đạt tiêu chí vào khám phá của lớp minh họa nếu đủ điều khiển, tương tác và nhãn minh họa; phải báo cáo riêng, không tính thành cảnh thủ công hoặc tái hiện thực địa.

## User stories và điều kiện nghiệm thu M1

| Mã | Nhu cầu | Điều kiện nghiệm thu |
| --- | --- | --- |
| 3D-01 | Tôi muốn thực sự điều khiển một nhân vật tham quan. | Trong cảnh 3D, input di chuyển thay đổi vị trí nhân vật liên tục; dừng input nhân vật dừng; không chỉ chuyển marker hoặc đổi màn hình tĩnh. |
| 3D-02 | Tôi muốn quan sát cảnh vật. | Có điều khiển camera độc lập với di chuyển; có thể xem xung quanh nhân vật và đọc trạng thái tương tác; thao tác cảm ứng không làm kẹt input khi thả ngón tay. |
| 3D-03 | Tôi muốn đi lại an toàn trong cảnh. | Nhân vật đứng trên bề mặt hợp lệ, không xuyên chướng ngại được đánh dấu; có biên khu vực hoặc cơ chế đưa về điểm an toàn khi ra ngoài; vị trí hồi phục hợp lệ. |
| 3D-04 | Tôi muốn khám phá các địa danh. | Có ít nhất hai POI trong cảnh mẫu; chỉ hiện hành động tương tác khi ở phạm vi phù hợp; thông tin/hoạt động mở và đóng được, không khóa điều khiển sau khi đóng. |
| 3D-05 | Tôi muốn giữ kỷ niệm chuyến đi. | Khám phá POI cập nhật nhật ký hoặc dấu; lặp tương tác không sinh bản ghi trùng; đóng/mở lại khôi phục đúng cảnh, vị trí an toàn và tiến trình đã lưu. |
| 3D-06 | Tôi muốn chơi khi không có mạng. | Từ bản cài chứa nội dung, bật chế độ máy bay rồi mở game, vào cảnh, di chuyển và tương tác được; không cần tải mô hình, texture, font hoặc nội dung từ Internet. |
| 3D-07 | Tôi muốn biết nơi nào đã chơi được. | Bản đồ/danh sách ghi rõ cảnh sẵn sàng, đang phát triển hoặc chỉ có trong danh mục; chọn nơi chưa có cảnh không hiển thị nhầm thành cảnh đại diện đã hoàn chỉnh. |
| 3D-08 | Tôi muốn chơi trên điện thoại. | Vùng điều khiển không bị safe area che, có thể vừa di chuyển vừa xoay camera; không có crash trong kịch bản thử đã thống nhất; đo FPS/bộ nhớ trên cấu hình thiết bị được ghi cụ thể. Mục tiêu ban đầu là 30 FPS, chưa là kết quả đã đạt. |
| 3D-09 | Tôi muốn thoát và quay lại dễ dàng. | Có thể rời cảnh về bản đồ rồi vào lại; chuyển cảnh và nạp dữ liệu có trạng thái rõ; dữ liệu lưu hỏng có thông báo và hướng phục hồi, không treo game. |
| 3D-10 | Tôi muốn vào tham quan đảo khi có trong bản mẫu. | Đảo đã công bố là chơi được mở được cảnh terrain 3D có nhân vật điều khiển và POI tương tác; cảnh thuật toán ghi rõ minh họa. Phủ mọi đảo trong dataset là cửa nghiệm thu M4, không phải điều kiện hoàn thành một cảnh mẫu M1. |

## Quy tắc offline và tài nguyên

Tài nguyên của phạm vi được công bố phải nằm trong gói cài/nội dung offline trước khi bắt đầu chơi. Nếu phân phối theo gói vùng về sau, phải nói rõ vùng nào đã cài và vùng nào cần tải trước; không coi toàn quốc là offline khi người dùng chỉ có một vùng. Mọi mô hình, texture, font, âm thanh và dữ liệu bản đồ cần giấy phép sử dụng/phân phối phù hợp, không nhúng dịch vụ bản đồ trực tuyến vào đường chạy bắt buộc.

Nội dung địa lý, văn hóa và biển đảo cần nguồn, phiên bản và người kiểm duyệt. Tối ưu kích thước gói, số cảnh giữ trong bộ nhớ và thời gian nạp phải dựa trên đo đạc; lựa chọn phong cách đơn giản không đồng nghĩa phải tái hiện địa hình tùy tiện.

## Báo cáo mức sẵn sàng

Phân biệt rõ kiểm thử logic, chạy web, Android build, Android trên thiết bị và iOS trên thiết bị. Có APK hoặc chạy cảnh web không chứng minh iOS hoạt động. Báo cáo mỗi mốc phải có số tỉnh trong registry đã xác minh, số cảnh đất liền chơi được, số đảo trong dataset, số đảo có scene thủ công/scene thuật toán/marker, khoảng trống dữ liệu, nền tảng đã kiểm thử và giới hạn còn lại.

Không đặt tài khoản, multiplayer, đồng bộ đám mây, quảng cáo hoặc mua hàng làm phụ thuộc của vòng chơi offline. Các tính năng này chưa thuộc mốc M1.
