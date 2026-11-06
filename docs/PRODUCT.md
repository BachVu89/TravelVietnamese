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

## Phạm vi 0.3 — yêu cầu PO đã được chốt

Phần này chuyển ba ưu tiên **PO-01, PO-02, PO-03** thành điều kiện nghiệm thu cụ thể; nghiên cứu thị trường và thứ tự backlog do PO quản lý riêng. Không thay đổi mục tiêu game 3D, offline, tỉnh/thành và đảo ở trên. Các trạng thái dưới đây là yêu cầu phải kiểm chứng, không phải tuyên bố đã hoàn thành triển khai.

### PO-01 — Hướng dẫn bằng thao tác thật

Người chơi mới được hướng dẫn ba bước theo thứ tự: **di chuyển → xoay camera → tương tác tại POI**. Có thể bỏ qua để tiếp tục tự khám phá; không dùng tutorial làm cổng khóa toàn bộ game.

| Mã nghiệm thu | Điều kiện và kết quả mong đợi |
| --- | --- |
| PO-01.A | Với bản lưu mới hoặc bản lưu 0.2 chưa có trường onboarding, hiển thị hướng dẫn từ bước 0. Giữ nguyên `region_id`, `positions` và `visited` khi mở bản lưu 0.2; không tạo lại hành trình để thêm tutorial. |
| PO-01.B | Bước di chuyển chỉ hoàn tất sau khi nhân vật tích lũy ít nhất **2 đơn vị khoảng cách mặt phẳng XZ trong cảnh** do input di chuyển thực của người chơi. Teleport, khôi phục vị trí đã lưu, chuyển cảnh hoặc nút về lối vào không được tự tính hoàn tất bước này. UI có thể gọi là khoảng 2 m trong cảnh minh họa, không phải khoảng cách thực địa. |
| PO-01.C | Bước nhìn chỉ được chấm khi đang ở bước này; tích lũy độ lớn góc xoay do input nhìn thật trên yaw/pitch đạt ít nhất **0,25 radian**. Xoay qua lại vẫn là thao tác nhìn; đặt lại camera hoặc khôi phục góc từ bản lưu không thay thế input. |
| PO-01.D | Bước tương tác chỉ hoàn tất khi người chơi thực hiện hành động tương tác thành công qua kiểm tra khoảng cách tới POI hiện tại. Đứng gần, bấm khi ngoài tầm hoặc chỉ gọi cập nhật `visited` không đủ. Tương tác thành công tại POI đã thăm vẫn là bằng chứng thao tác; không tạo dấu trùng. |
| PO-01.E | Chỉ hoàn thành đủ ba bước mới có trạng thái `completed`. Nút **Bỏ qua** dừng hướng dẫn với trạng thái `skipped`, không giả làm hoàn thành; vẫn di chuyển, nhìn và tương tác bình thường. |
| PO-01.F | Có thao tác **Xem lại hướng dẫn**: bắt đầu lại bước 0 và bộ đếm bài hướng dẫn, không xóa tỉnh đang chọn, vị trí, dấu đã thăm hoặc cài đặt. Các thao tác trước khi bắt đầu lại không tự vượt qua các bước mới. |
| PO-01.G | Trạng thái hướng dẫn được lưu bền qua đóng/mở lại. `skipped` và `completed` không tự mở lại tutorial khi khởi động; người chơi vẫn chủ động xem lại được. Các trường onboarding là phần mở rộng tùy chọn của save version 1, không làm mất tương thích bản lưu 0.2. |

### PO-02 — Dẫn tới POI chưa khám phá gần nhất

Định hướng giúp người chơi tự đi bộ tới mục tiêu; không tự dịch chuyển hoặc nhận dấu thay người chơi.

| Mã nghiệm thu | Điều kiện và kết quả mong đợi |
| --- | --- |
| PO-02.A | Trong cảnh hiện tại, chọn POI **chưa có trong `visited`** gần nhân vật nhất theo khoảng cách mặt phẳng XZ. Không chọn POI ở tỉnh/đảo khác; thay đổi vị trí phải cập nhật mục tiêu gần nhất. |
| PO-02.B | Hiển thị tên mục tiêu, khoảng cách xấp xỉ bằng đơn vị trong cảnh và hướng tương đối với camera, để phân biệt phía trước/trái/phải/phía sau. Xoay camera làm cập nhật hướng tương đối mà không buộc nhân vật di chuyển. Không trình bày khoảng cách minh họa như số đo địa lý thực. |
| PO-02.C | Khi tương tác thành công, dấu được ghi đúng một lần và chỉ dẫn tự chuyển tới POI chưa thăm gần nhất còn lại. Đóng bảng thông tin hoặc quay lại cảnh vẫn nhất quán với tiến trình đã lưu. |
| PO-02.D | Nếu không còn POI chưa thăm, hiển thị đã khám phá **N/N tại cảnh này**; với cảnh ba POI là **3/3**. Không giữ mục tiêu cũ, chỉ tới vị trí không tồn tại hoặc tuyên bố hoàn thành toàn quốc. |
| PO-02.E | Chỉ dẫn chỉ cung cấp thông tin: bật/cập nhật mục tiêu không thay đổi vị trí, không tăng `visited` và không tự chấm POI đã khám phá. Tương tác vẫn dùng phạm vi tiếp cận thực tế của scene. |

### PO-03 — Tùy chỉnh hiệu năng và cảm giác camera

Cài đặt hoạt động offline, có tác dụng ngay và được giữ khi chuyển địa điểm hoặc khởi động lại.

| Mã nghiệm thu | Điều kiện và kết quả mong đợi |
| --- | --- |
| PO-03.A | Có lựa chọn **Bóng đổ: Bật/Tắt**, mặc định Bật. Tắt thực sự vô hiệu bóng đổ của nguồn sáng đang dùng trong cảnh; bật lại khôi phục. Chuyển sang tỉnh/đảo khác giữ lựa chọn, không chỉ đổi nhãn UI. |
| PO-03.B | Có ba mức độ nhạy camera **0,6× / 1× / 1,4×**, mặc định 1×. Cùng một input nhìn, góc thay đổi tương ứng hệ số ở vùng chưa chạm giới hạn pitch; lựa chọn áp dụng ngay cho điều khiển camera đang được hỗ trợ. |
| PO-03.C | Đổi cài đặt rồi chuyển cảnh, lưu và đóng/mở lại vẫn giữ bóng đổ/độ nhạy; không cần mạng. UI phản ánh đúng giá trị đang có hiệu lực. |
| PO-03.D | Bản lưu version 1 cũ thiếu cài đặt dùng mặc định **Bật / 1×**, bảo toàn địa điểm, vị trí và dấu. Trường settings mới là phần mở rộng tùy chọn; không nâng phiên bản bằng cách làm bản lưu 0.2 không thể đọc. |
| PO-03.E | Mở/đóng bảng cài đặt không để input cảm ứng bị kẹt, không tự di chuyển nhân vật hoặc tự đóng dấu POI. Chưa tuyên bố cải thiện FPS cụ thể khi chưa đo cùng thiết bị và cùng cảnh. |

**Kiểm chứng 0.3:** kiểm thử ngưỡng và nguồn input tutorial, trạng thái bỏ qua/xem lại, chọn POI theo XZ và hướng camera, hoàn thành N/N, tác dụng thật của bóng đổ/độ nhạy, lưu sau chuyển cảnh và đọc bản lưu 0.2. Chạy thử UI trên nền tảng có bằng chứng hiện tại; Android/iOS chưa chạy phải ghi rõ chưa xác minh. Các thay đổi này không bổ sung đảo có tên, địa hình thực hoặc POI đặc trưng mới; báo cáo coverage địa lý vẫn giữ các khoảng trống đã nêu.

## Phạm vi 0.4 — PO-10: đoạn đèo, xe máy và điểm dừng

Người dùng đã duyệt triển khai một vertical slice để kiểm chứng trải nghiệm **lái xe → đỗ → xuống xe đi bộ tham quan → trở lại xe**. Đây là bước kiểm chứng trước khi cân nhắc đổi engine; giữ Godot hiện tại. Chi tiết ưu tiên và trạng thái do PO quản lý tại [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md), yêu cầu **PO-10.A–J**. Hướng hình ảnh là bán hiện thực theo cảm giác ảnh tham chiếu, không cam kết tương đương ảnh hoặc coi ảnh là bằng chứng engine chạy realtime.

Slice là một **mẫu riêng**, không phải tỉnh thứ 48 trong registry 47 mục. Đường mục tiêu 750 đơn vị scene có cảm hứng đường đèo, không tái dựng GIS hoặc tuyên bố là đúng tuyến Khánh Lê/Đà Lạt. Không thay thế hoặc đánh dấu hoàn thành backlog mọi tỉnh/đảo.

| AC PO | Điều kiện nghiệm thu cụ thể của BA |
| --- | --- |
| PO-10.A — Tuyến minh họa | Đo tổng chiều dài centerline 3D được cấu hình trong khoảng **700–800 đơn vị scene**, mục tiêu **750**; không đo bằng khoảng cách thẳng giữa hai đầu. Đi liên tục từ đầu tới cuối được, có cua, thay đổi cao độ, mặt đường, sườn núi và mép chắn/lan can nhìn rõ. HUD/biển thông tin gọi là khoảng cách trong cảnh minh họa. Bản báo cáo phải ghi giá trị thực đo, không gán thành chiều dài thực địa. |
| PO-10.B — Lái xe arcade | Ga làm tăng vận tốc từ đứng yên; thả ga không tự tăng tốc; phanh khi đang chạy làm giảm tốc tới dừng. Lái trái/phải đổi hướng và vị trí, tốc độ bị chặn bởi cấu hình hữu hạn. Reset đưa người/xe về checkpoint an toàn, vận tốc an toàn và không xóa dấu. Không bắt buộc cân bằng/ngã xe như mô phỏng thực tế. |
| PO-10.C — Điều khiển và camera | Keyboard và touch landscape đều có ga, phanh, trái/phải, hành động lên/xuống xe/tương tác; có thể kết hợp ga+lái và phanh+lái trên touch. Camera bám và thấy hướng cua; có thao tác nhìn hoặc reset camera rõ. Menu/modal/background hủy input đang giữ; trở lại không tự ga. Kiểm góc camera tại đoạn thẳng, cua và điểm dừng để tránh xuyên địa hình nghiêm trọng. |
| PO-10.D — Giao thông và va chạm | Ít nhất **hai xe traffic** chạy tuyến định sẵn, không cần mạng. Cùng seed, trạng thái ban đầu và chuỗi fixed-step cho vị trí tương đương trong sai số mà suite ghi rõ. Xe traffic và lan can/mép chắn có collider thực: xe người chơi bị chặn hoặc giảm chuyển động khi tiếp xúc, không xuyên qua như vật trang trí. Kiểm ít nhất một va chạm với traffic và một va chạm mép chắn bằng simulation và trong vòng chơi render. |
| PO-10.E — Hai điểm dừng có guard | Có ít nhất **hai điểm dừng tách nhau dọc tuyến**, mỗi điểm có ID, tên/nội dung minh họa riêng và vùng dừng xác định bằng cấu hình. Chỉ cho đỗ/xuống xe ở vùng hợp lệ khi tốc độ xe **≤0,5 đơn vị scene/giây**. Tại mỗi điểm thử dưới, bằng và trên ngưỡng; ngoài vùng hoặc quá nhanh bị từ chối với gợi ý rõ. Chạy qua không ghi dấu. **Mở nội dung/nhận dấu POI chỉ khi đã đỗ, chuyển sang đi bộ và đủ gần POI**; đang lái hoặc ở xa không được hoàn thành. |
| PO-10.F — Vòng xe/đi bộ | Tại cả hai điểm, lái tới, dừng, xuống xe, đi bộ tới POI/tương tác, đi về xe và lên xe để tiếp tục mà không cần đổi scene thủ công. Lên xe chỉ khi đủ gần chiếc xe đã đỗ; không teleport từ xa tới xe. Chuyển mode giữ một xe, không mất dấu hoặc nhân đôi nhân vật/xe; điều khiển đi bộ không đồng thời nhận ga. |
| PO-10.G — Offline và save tương thích | Slice mesh/material/nội dung/traffic đều đóng gói local. Save version 1 thêm nhánh slice tùy chọn; thiếu/hỏng nhánh này chỉ dùng mặc định slice, không xóa `region_id`, `positions`, `visited`, `onboarding`, `preferences` hợp lệ. Fixture 0.2/0.3 giữ dữ liệu lõi, fixture mới giữ checkpoint và dấu điểm dừng qua restart. Không tái sử dụng clamp vị trí ±41 của scene cũ làm mất tiến trình tuyến dài: dùng vị trí/checkpoint slice được xác thực riêng. Khi mở lại đặt người/xe ở checkpoint hợp lệ trong mode an toàn; không bắt buộc khôi phục vị trí traffic. Rời mẫu quay lại hành trình cũ không mất tiến trình. |
| PO-10.H — Tài nguyên và công bố | Chỉ dùng mesh/material do team tạo hoặc asset có manifest nguồn/license cho phép phân phối offline. Không nhúng ảnh tham chiếu làm texture hoặc coi nó cấp quyền dùng asset. Thông tin scene ghi rõ minh họa, chưa đối chiếu địa hình/công trình thực địa; asset generic không được gọi là số hóa địa danh. |
| PO-10.I — Cửa desktop | QA chạy kiểm geometry/input/traffic/collision/guard/mode/checkpoint/save legacy. Root thực hiện vòng render bằng input thật tới ít nhất một điểm dừng rồi tiếp tục lái; bộ test phải bao phủ guard và vòng tham quan ở cả hai điểm. Báo riêng assertion logic, render smoke, nội dung chưa đạt và lỗi còn mở. Ảnh đứng yên hoặc đặt trực tiếp state đích không thay cho vòng chơi thực. |
| PO-10.J — Cửa artifact Android | Có APK 0.4 và kết quả hash, chữ ký, alignment, application ID/version và tài nguyên đóng gói; giữ khả năng update/save ứng dụng cũ. Vòng chơi không yêu cầu Internet. Artifact ready chỉ khi file và kiểm tra thực có mặt; APK không chứng minh đa chạm/hiệu năng/cài đè thật hoặc iOS đã chạy. Cửa thiết bị PO-08 vẫn mở đến khi có bằng chứng riêng. |

**Kịch bản nghiệm thu tối thiểu:** đọc save cũ → mở mẫu → ga/phanh/cua bằng input thật → tới điểm dừng thứ nhất → từ chối tương tác khi chạy/ngoài vùng → đỗ và xuống xe → đi bộ/tương tác → về xe/lái tiếp → lặp ở điểm thứ hai → lưu/đóng/mở lại → xác nhận checkpoint/dấu → quay lại scene cũ, giữ nguyên tiến trình. Kiểm thêm repeat interaction không nhân dấu, modal/background không kẹt input và checkpoint không đưa xe vào collider.

**Không thuộc cửa 0.4:** photo mode/album (deferred), mạng đường toàn quốc, bản sao GIS, photoreal như ảnh, mô phỏng xe chuyên sâu, multiplayer/backend hoặc tuyên bố đã phủ đủ đảo. **30 FPS là mục tiêu đánh giá thiết bị, chưa là số thực đo hoặc cam kết mọi máy.** Bán hiện thực cần được review bằng hình ảnh gameplay của build cụ thể; nếu tài nguyên hiện chỉ đạt blockout thì báo rõ, không tự đánh đồng gameplay PASS với chất lượng mỹ thuật đạt tham chiếu.

## Quy tắc offline và tài nguyên

Tài nguyên của phạm vi được công bố phải nằm trong gói cài/nội dung offline trước khi bắt đầu chơi. Nếu phân phối theo gói vùng về sau, phải nói rõ vùng nào đã cài và vùng nào cần tải trước; không coi toàn quốc là offline khi người dùng chỉ có một vùng. Mọi mô hình, texture, font, âm thanh và dữ liệu bản đồ cần giấy phép sử dụng/phân phối phù hợp, không nhúng dịch vụ bản đồ trực tuyến vào đường chạy bắt buộc.

Nội dung địa lý, văn hóa và biển đảo cần nguồn, phiên bản và người kiểm duyệt. Tối ưu kích thước gói, số cảnh giữ trong bộ nhớ và thời gian nạp phải dựa trên đo đạc; lựa chọn phong cách đơn giản không đồng nghĩa phải tái hiện địa hình tùy tiện.

## Báo cáo mức sẵn sàng

Phân biệt rõ kiểm thử logic, chạy web, Android build, Android trên thiết bị và iOS trên thiết bị. Có APK hoặc chạy cảnh web không chứng minh iOS hoạt động. Báo cáo mỗi mốc phải có số tỉnh trong registry đã xác minh, số cảnh đất liền chơi được, số đảo trong dataset, số đảo có scene thủ công/scene thuật toán/marker, khoảng trống dữ liệu, nền tảng đã kiểm thử và giới hạn còn lại.

Không đặt tài khoản, multiplayer, đồng bộ đám mây, quảng cáo hoặc mua hàng làm phụ thuộc của vòng chơi offline. Các tính năng này chưa thuộc mốc M1.
