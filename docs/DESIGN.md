# Thiết kế trải nghiệm — Dọc miền Việt 3D

## Hướng sản phẩm hiện tại

Game khám phá Việt Nam 3D, chơi offline trên Android và iOS. Người chơi tự điều khiển nhân vật đi trong không gian, quan sát địa danh và tương tác tại điểm tham quan. Câu đố, thẻ thông tin và hộ chiếu có thể bổ trợ trải nghiệm; chúng không thay thế việc di chuyển và khám phá 3D.

Phạm vi nội dung người dùng chọn: registry đủ 34 tỉnh/thành cùng các đảo, quần đảo có tên trong bộ dữ liệu; mọi mục trong bộ dữ liệu phải vào được không gian 3D, bao gồm đảo; điểm tiêu biểu được dựng thủ công chi tiết hơn, các mục còn lại dùng địa hình tạo theo quy tắc và POI phù hợp. Chỉ coi một mục là playable sau khi đường vào cảnh và điều khiển thực sự được kiểm chứng. Không gọi vài khối nhà là mô phỏng hoàn chỉnh một tỉnh.

Tài liệu này là đặc tả trải nghiệm, không phải báo cáo tính năng đã hoàn thành. Engine Godot 4.6.3 Compatibility theo xác nhận kiến trúc. Ngân sách tiền và lựa chọn phương tiện có thể trở lại sau khi vòng khám phá 3D hoạt động tốt; không để các hệ thống phụ chặn việc tham quan.

## Vòng khám phá

1. Chọn điểm đến từ danh mục hoặc tiếp tục cảnh đang chơi.
2. Xem tên cảnh và nhãn mức độ tái hiện; tải toàn bộ từ thiết bị.
3. Tự đi bộ, xoay camera và quan sát địa hình, kiến trúc.
4. Khi đến gần POI, chọn “Khám phá” để mở mô tả ngắn, đánh dấu đã đến.
5. Tiếp tục đi trong cảnh, hoặc mở bản đồ/danh mục để chuyển đến bất kỳ mục nào trong bộ dữ liệu đã đóng gói.

Không yêu cầu đăng nhập, Internet, GPS hoặc bản đồ trực tuyến. Không tự dịch chuyển người chơi đến POI chỉ vì chạm tên POI. Hỗ trợ trở về điểm xuất phát nếu bị kẹt; không đặt hình phạt tiền hoặc mất dữ liệu cho thao tác này.

## Bố cục chơi landscape

- Góc trái trên: tên cảnh và nhãn phạm vi, ví dụ “Khu tham quan mẫu · tái hiện cách điệu”. Không hiển thị “Đã hoàn thành Hà Nội” sau một POI.
- Góc phải trên: nút “Bản đồ” và “Tạm dừng”, nền đặc đủ tương phản với cảnh.
- Góc trái dưới: joystick ảo cố định; vùng chạm lớn và có phản hồi hướng.
- Nửa phải vùng trống: kéo để xoay camera; không lấy gesture bắt đầu trên nút UI.
- Góc phải dưới: nút “Khám phá” hiện khi ở đủ gần POI. Khi chưa gần, không chiếm chỗ bằng nhiều nút vô dụng.
- Gợi ý đầu tiên: “Kéo cần trái để đi · Vuốt bên phải để nhìn”; biến mất khi người chơi đã thực hiện, có thể xem lại trong trợ giúp. Có nút “Đặt lại camera” dễ tìm để quay camera về sau lưng nhân vật.

Hai ngón tay phải hoạt động đồng thời: giữ joystick và xoay camera. Gán touch index riêng cho mỗi thao tác; nhấc một tay không hủy thao tác của tay còn lại. Các nút UI không xuyên chạm xuống camera. Khi mở menu hoặc mất focus, xóa trạng thái di chuyển để nhân vật không tự chạy.

## Chuyển động và camera

Các thông số dưới đây là điểm bắt đầu để playtest, không phải tuyên bố hiệu năng hoặc giá trị bắt buộc trong code.

| Thành phần | Đề xuất ban đầu |
| --- | --- |
| Góc nhìn | Third-person, thấy nhân vật và môi trường phía trước |
| Tốc độ đi | Khoảng 3,5–4,5 m/s; không cần sprint trong slice đầu |
| Joystick | Đường kính 132–160 logical px, deadzone 0,12–0,18 |
| Camera | Khoảng cách 4–6 m; cao hơn đầu nhân vật, FOV 60–70° |
| Pitch | Giới hạn khoảng −15° đến 65° để tránh lật camera |
| Tương tác | Bán kính khoảng 2–3 m; tên POI và nút rõ ràng |
| Vật cản | Nhân vật có collision; camera tránh xuyên tường nếu hỗ trợ |

Di chuyển theo hướng camera trên mặt phẳng đất. Không bắt buộc nhảy, leo trèo, thao tác chính xác hoặc chiến đấu để xem điểm tham quan. Cảnh có ranh giới mềm hoặc rào hợp lý; không để nhân vật rơi vô hạn khỏi địa hình. Lối chính đủ rộng cho nhân vật và camera.

## Danh mục Việt Nam và chọn cảnh

Danh mục tách dữ liệu hành chính với điểm tham quan và nhóm đảo. Dùng bộ dữ liệu đã kiểm tra tên, mã và nguồn; không hard-code tổng số đảo như một tuyên bố bao phủ tuyệt đối. Bộ lọc đề xuất: Tất cả / Tỉnh & thành phố / Đảo & quần đảo; có ô tìm kiếm tiếng Việt, trạng thái không có kết quả và nút xóa tìm kiếm. Không giấu đảo ở cuối một danh sách quá dài không có công cụ tìm.

Mỗi thẻ có tên, loại mục, tỉnh/thành liên quan nếu biết, nút **Vào khám phá** và nhãn mức tái hiện bằng chữ:

- **Cảnh dựng thủ công**: landmark, đường đi và POI được bố trí riêng; có thể ghi thêm “tái hiện cách điệu”.
- **Địa hình tạo theo quy tắc · minh họa**: cảnh procedural theo vùng/biome, không khẳng định là địa hình thật. Mỗi entry vẫn phải vào được, đi được, có ranh giới/collision và nội dung tương tác.
- **Lỗi tải cảnh**: chỉ là trạng thái lỗi cần sửa, không đổi thành khóa nội dung hay tính là hoàn thành. Có Thử lại và Quay về danh mục.

Đảo cũng có cảnh đi bộ/quan sát và nội dung chi tiết; không thay bằng thẻ văn bản. Mục tiêu sản phẩm là tăng dần độ chi tiết riêng cho từng đảo, còn các bản dựng procedural phải mang nhãn trung thực. Không giới hạn quyền vào 3D ở hai scene mẫu rồi khóa phần registry còn lại.

Đếm riêng số mục đã tương tác và số cảnh dựng thủ công; không dùng tổng số tên để tuyên bố đã tái hiện chính xác toàn quốc. Hình bản đồ nếu có phải ghi rõ sơ đồ minh họa; không dùng vị trí trang trí như tọa độ địa lý chính xác. Khi rời cảnh, nút Bản đồ quay về danh mục và giữ bộ lọc/từ khóa/vị trí cuộn trước đó.

## POI, thông tin và hộ chiếu

Tên POI xuất hiện khi gần, không phủ cả cảnh bằng hàng loạt nhãn. Bảng thông tin có tên, mô tả ngắn, nhãn “tái hiện cách điệu” nếu cần và nút “Tiếp tục tham quan”. Dừng di chuyển khi bảng mở. Hộ chiếu tùy chọn ghi POI đã tương tác; dấu không đại diện việc đã tham quan đầy đủ một tỉnh hoặc quần đảo.

Nội dung có nguồn và mức độ tin cậy được ghi trong dữ liệu/tài liệu. Tên đảo, quần đảo và ranh giới không được suy diễn từ mesh mô phỏng. Mô tả không nên khẳng định kích thước, vị trí hoặc độ chính xác lịch sử khi chưa kiểm chứng.

## Trạng thái và lưu trữ

- Khởi động: “Đang mở hành trình…”; không ghi đè save trước khi đọc xong.
- Tiếp tục: khôi phục scene và vị trí an toàn, hoặc về điểm spawn khi save không hợp lệ.
- Chuyển cảnh: có thông báo tải và tên điểm đến; tránh nhân đôi đầu vào hoặc ghi thưởng hai lần.
- Tạm dừng: Tiếp tục / Danh mục / Trợ giúp điều khiển / Về điểm xuất phát.
- Save lỗi: thông báo “Chưa lưu được tiến trình” và cho thử lại; không giả vờ đã lưu.
- Xóa tiến trình: xác nhận riêng, mô tả rõ dữ liệu sẽ xóa.

## Khả năng tiếp cận

Vùng chạm nút tối thiểu 48 logical px, cách mép và safe area hợp lý. Cỡ chữ cơ sở tối thiểu 18 logical px ở viewport tham chiếu 1280×720, tăng được nếu triển khai. Tiếng Việt phải đầy đủ dấu và không bị cắt. Hỗ trợ đổi độ nhạy camera, tắt rung/hiệu ứng lắc nếu có; không bật camera shake mặc định. Chỉ dùng màu kèm chữ/icon để chỉ trạng thái. Không cần nghe âm thanh để biết có POI.

Không tuyên bố hỗ trợ screen reader toàn phần cho gameplay 3D khi chưa kiểm thử; menu và trạng thái tương tác cần nhãn rõ. Không đặt thông tin quan trọng chỉ trong texture khó đọc. Cho phép chạm “Đặt lại camera” trong trợ giúp nếu camera lạc hướng.

## Tiêu chí duyệt slice

- Chạm giữ trái và kéo phải cùng lúc: nhân vật di chuyển, camera xoay độc lập.
- Người chơi thật sự đi được trên địa hình; không chỉ xem ảnh hoặc thẻ quiz.
- Nhà/công trình có collision phù hợp; không xuyên tường vào vùng bị chặn.
- Tới POI, tương tác và đóng bảng xong tiếp tục đi được.
- Menu không để nhân vật trôi; thoát/mở lại khôi phục tiến trình đã xác minh.
- Chơi được trong chế độ máy bay sau khi cài; không phụ thuộc URL asset/font.
- Tất cả mục trong dataset có đường vào cảnh 3D hoạt động; danh mục phân biệt mức thủ công/procedural và có tìm kiếm. Mỗi cảnh có thể quay về danh mục, đặt lại camera và tương tác POI.
- Android và iOS phải được kiểm chứng trên thiết bị riêng trước khi tuyên bố hỗ trợ vận hành; PC/editor không thay thế kiểm thử cảm ứng.

Ngôn ngữ hình ảnh, tier nội dung và ngân sách dựng cảnh được mô tả trong `ART_DIRECTION.md`.

## UX 0.3 — Hướng dẫn, định hướng POI và cấu hình thiết bị

Phần này đặc tả batch PO-01–PO-03 đã được Product Owner chốt để Dev/QA triển khai và nghiệm thu; không đồng nghĩa các hành vi dưới đây đã có trong APK hiện tại.

### PO-01: Học bằng thao tác thật

Luồng lần đầu vào cảnh: **Di chuyển → Xoay góc nhìn → Khám phá POI → Tự do tham quan**. Mỗi lần chỉ hiện một hướng dẫn ngắn, không bật chuỗi hộp thoại bắt đọc trước khi chơi.

| Bước | Nội dung hiển thị | Điều kiện hoàn tất |
| --- | --- | --- |
| 1/3 | “Kéo cần trái để đi” | Nhân vật thực sự di chuyển ít nhất 2 m trong mô hình theo mặt phẳng XZ; chỉ chạm joystick chưa tính |
| 2/3 | “Vuốt bên phải để nhìn” | Camera đổi góc ít nhất 0,25 rad từ thao tác nhìn sau bước đi; tự đặt lại camera chưa tính |
| 3/3 | “Đến điểm tham quan và chạm Khám phá” | Tương tác POI trong phạm vi hợp lệ; tới gần hoặc mở menu chưa tính |
| Xong | “Bạn đã sẵn sàng khám phá” | Thu gọn hướng dẫn, giữ chỉ dẫn mục tiêu và điều khiển |

Thứ tự là bắt buộc: đi đủ ngưỡng rồi mới tính xoay, rồi mới tính tương tác. Không suy hoàn tất từ số frame hoặc thời gian đã trôi. Hướng dẫn phải chạy với cả cảm ứng và phím/chuột dành cho dev test. Có **Bỏ qua** ở mọi bước; không khóa di chuyển hoặc quyền chuyển cảnh. Lưu trạng thái đã hoàn tất/đã bỏ qua offline để lần mở sau không tự ép học lại; bỏ qua không đồng nghĩa hoàn thành. Người nâng cấp từ save cũ chưa có trường hướng dẫn được xem một lần, đồng thời giữ nguyên tiến trình. Trong menu có **Xem lại hướng dẫn**, bắt đầu lại từ bước 1 bằng chủ ý người chơi và không xóa dấu đã ghé. Người đã có tiến trình cũ không bị mất dữ liệu khi thêm trường lưu hướng dẫn.

Thẻ hướng dẫn nằm ngay dưới thanh tên cảnh, ưu tiên vùng trái trên. Bản thân dòng chữ không bắt gesture; chỉ nút Bỏ qua có vùng chạm riêng. Không dùng lớp nền toàn màn chặn joystick/camera. Khi mở danh mục, giấy phép hoặc bảng POI, ẩn/tạm dừng hướng dẫn cho tới khi trở lại gameplay. Sau bước 3, thông báo hoàn tất không che nút đóng bảng thông tin.

### PO-02: Biết đi đâu tiếp theo

Trong cảnh, hiển thị mục tiêu là POI **chưa tương tác gần nhất** tính khoảng cách phẳng XZ từ vị trí người chơi. Mỗi nhãn có tên POI, hướng tương đối camera và khoảng cách trong mô hình: ví dụ **“Tháp mẫu · bên trái · ≈ 24 m trong cảnh”**. Không gọi khoảng cách này là quãng đường thực tế ngoài đời, lộ trình đường bộ hoặc số đo GPS. Khoảng cách thẳng không hứa có lối đi trực tiếp xuyên vật cản.

Hướng dùng chữ “phía trước / bên trái / bên phải / phía sau” và có thể kèm mũi tên. Không chỉ dùng mũi tên hoặc chữ Bắc/Nam khi scene chưa có tọa độ thực. Cập nhật khi đi hoặc xoay camera; xử lý khoảng cách gần bằng “Đã tới gần · chạm Khám phá”, không để mũi tên quay loạn khi gần trùng vị trí. Nếu có hai POI cách bằng nhau, giữ lựa chọn ổn định thay vì nhấp nháy qua lại.

Sau tương tác hợp lệ, chuyển mục tiêu sang POI chưa ghé tiếp theo. Dấu đã ghé không được tăng khi chỉ xem hướng dẫn hoặc đổi cấu hình. Tiến độ ghi **“Đã ghé x/y điểm trong cảnh”**; khi đủ ghi **“Đã ghé mọi điểm trong cảnh này”**, kèm tùy chọn tiếp tục đi hoặc đổi địa điểm. Không gọi đó là hoàn thành toàn tỉnh/đảo. Không có POI thì ghi “Cảnh chưa có điểm tương tác”, không hiển thị 0/0 như một thành tích hoàn tất. Cảnh lỗi không được tính là hoàn thành.

HUD mục tiêu cùng cụm trên trái với hướng dẫn; khi hướng dẫn hiện, gộp thành hai dòng ngắn hoặc ưu tiên hướng dẫn để tránh chồng nhiều thẻ. Chừa nửa phải và vùng dưới cho camera/nút Khám phá, chừa vùng trái dưới cho joystick. Bảng thông tin, danh mục và menu có độ ưu tiên cao hơn HUD. Không có tự đi hoặc tự dịch chuyển tới mục tiêu trong batch này.

### PO-03: Cấu hình điều khiển và hình ảnh

Trong menu, thêm nhóm **Điều khiển & hình ảnh**. Khi mở menu, hủy trạng thái chạm đang giữ và dừng nhân vật. Các điều khiển đều có nhãn, giá trị hiện tại và vùng chạm tối thiểu 48 logical px:

- **Bóng đổ: Bật / Tắt**: mặc định Bật; một lựa chọn bật/tắt bóng đổ động, ghi chú “Tắt bóng có thể giúp máy chạy nhẹ hơn”. Không gọi đây là chế độ bảo đảm 30/60 fps, không tự thay đổi collision, POI hoặc dấu khám phá. Nếu là cùng một setting, không trình bày thành hai công tắc đối nghịch gây mâu thuẫn.
- **Độ nhạy camera**: ba mức **Thấp (0,6×) / Chuẩn (1×) / Cao (1,4×)**, mặc định Chuẩn; áp dụng cho thao tác nhìn, không đổi tốc độ đi. Chọn **Chuẩn (1×)** để khôi phục độ nhạy mặc định. Xác định rõ áp dụng cảm ứng/chuột trong implementation.
- Lưu cấu hình trên thiết bị ngay khi đổi; áp dụng trong cảnh hiện tại và cảnh kế tiếp. Đóng/mở app giữ cấu hình. Save cũ thiếu trường dùng mặc định, không xóa vị trí hoặc dấu đã ghé.

Không thêm tùy chọn không hoạt động. Tắt bóng vẫn phải đủ tương phản để thấy nhân vật, địa hình và landmark; hướng di chuyển không được dựa vào bóng. Khi giảm độ nhạy, thao tác camera vẫn phản hồi; nút “Đặt lại camera” là phục hồi góc nhìn, không đặt lại toàn bộ setting.

### Bố cục và kiểm thử cảm ứng 0.3

Viewport tham chiếu 1280×720: giữ thanh chính ở trên, cụm hướng dẫn/mục tiêu khoảng vùng x18–600 dưới thanh chính; đây là hướng bố cục, không phải vị trí pixel bắt buộc trên mọi máy. Không đặt một panel bắt chạm phủ toàn chiều ngang vùng camera. Dòng chữ tự xuống hàng khi tên dài, không đè nút Bỏ qua. Menu cài đặt cuộn được ở màn hình hẹp; luôn thấy cách Trở lại.

Nghiệm thu trực tiếp: vừa giữ joystick vừa kéo camera; nhấn Bỏ qua không làm xoay camera; đóng menu không khiến nhân vật chạy tiếp vì touch cũ; mở bảng POI không bị HUD che nút; đổi độ nhạy và bóng rồi chuyển cảnh/mở lại app vẫn giữ setting. Kiểm thử màn hình điện thoại thật là bắt buộc để kết luận ergonomics, không thay bằng assertion hoặc ảnh desktop.
