# Viet Trail — Đặc tả sản phẩm bản viết lại

Ngày lập: **09/11/2026 (UTC+7)**. Đây là đặc tả mới cho project **Unity 6 + URP** sau lần làm sạch mã nguồn; lịch sử Git giữ các bản cũ. Tài liệu này không kế thừa tuyên bố nghiệm thu, số test hoặc artifact của các project trước.

## Trải nghiệm và hướng mỹ thuật

Game du lịch Việt Nam góc nhìn thứ ba, chơi offline trên Android và iOS: lái xe máy, dừng ở điểm ngắm cảnh, xuống xe đi bộ, tìm hiểu và nhận dấu hộ chiếu. Hướng hình ảnh là **stylized painterly** với nắng ấm, ruộng bậc thang và đèo núi phía Bắc; ưu tiên bố cục, silhouette, sắc độ gần–xa và cảm giác khám phá. Không theo đuổi photoreal hoặc coi ảnh concept là bằng chứng engine đã chạy đạt chất lượng.

Bản hiện tại là **một vertical slice miền núi phía Bắc**, dùng tên chương du lịch Hà Giang. Theo snapshot hành chính sau sắp xếp 2025, vùng Hà Giang cũ thuộc tỉnh Tuyên Quang; chương du lịch không tạo ra một tỉnh hành chính riêng. Cảnh có cảm hứng vùng miền nhưng không tuyên bố tái dựng đúng đèo, công trình, tọa độ hoặc đường biên thực.

Một palette màu chung **512×512**, vật liệu **stylized Lit không theo pipeline PBR**, ánh sáng ấm và lớp height fog là định hướng sản xuất. Height fog không được quảng bá là volumetric fog thực. Mỗi mesh/âm thanh/font cần quyền sử dụng phù hợp; không mặc định mua asset hoặc phụ thuộc plugin trả phí để hoàn thành vòng chơi. Đánh giá mỹ thuật bằng ảnh gameplay thực và review, không dùng số lượng test như điểm chất lượng hình ảnh.

## Phạm vi địa lý: kế hoạch khác với cảnh chơi được

Dữ liệu mới tại [`Assets/VietTrail/Resources/Regions.json`](../Assets/VietTrail/Resources/Regions.json) gồm:

| Nhóm | Nội dung và trạng thái |
| --- | --- |
| Registry hành chính | **34 tỉnh/thành** theo snapshot sắp xếp 2025: 28 tỉnh, 6 thành phố. Tất cả `planned`; bản ghi không chứng minh đã có toàn tỉnh 3D. |
| Chương du lịch | Hà Giang: `demo`, là chương được chọn phát triển. Huế, Đà Lạt, Cà Mau: `planned`, chưa có cảnh chơi được được xác nhận. |
| Điểm đảo tiêu biểu | Phú Quốc, Côn Đảo, Lý Sơn, Phú Quý, Cô Tô, Cát Bà: đều `planned`, chưa có geometry hoặc scene được xác nhận. Đây không phải danh sách đầy đủ đảo đơn hoặc quần đảo. |

Snapshot tổ chức nội dung dùng mốc **01/07/2025**, tham chiếu Nghị quyết 202/2025/QH15; không tự coi file này là dữ liệu pháp lý/GIS được cập nhật realtime hoặc đã đối soát trực tiếp mọi nguồn. Đà Lạt là địa danh du lịch thuộc Lâm Đồng. Tên điểm đến, tỉnh/thành và nhóm đảo được giữ thành các khái niệm riêng.

`islandCoverageVerified` phải giữ **false**: mong muốn khám phá mọi đảo có tên vẫn thuộc phạm vi dài hạn, nhưng chưa có catalog đầy đủ/nguồn/geometry/scene. Các tên đảo tiêu biểu không dùng thay mẫu số “mọi đảo”. Không khẳng định chủ quyền tại khu vực tranh chấp như một dữ kiện không điều kiện; cần nguồn và cách trình bày được kiểm duyệt khi mở rộng.

Bản đồ tổng quan và các `mapX/mapZ` là **layout minh họa chuẩn hóa 0–1**, không phải kinh/vĩ độ. Có outline Việt Nam hoặc marker không làm tăng số cảnh đã hoàn thiện. Chỉ chương `demo` được chọn vào trải nghiệm hiện tại; `planned` phải hiển thị rõ chưa sẵn sàng, không đổi nhãn rồi vào một cảnh chung như đã làm đủ địa phương.

## Vòng chơi bản mẫu

1. Mở Start để bắt đầu/tiếp tục chương demo; xem Garage, Map hoặc Settings khi muốn.
2. Lái xe qua tuyến có cua/dốc, nhìn cảnh và theo mục tiêu điểm dừng.
3. Đỗ đúng vùng, xuống đi bộ tới POI, xem nội dung và nhận một dấu.
4. Về xe, tiếp tục tới hai điểm còn lại, lưu tiến trình/checkpoint cục bộ.
5. Hoàn thành ba dấu của **khu mẫu**; không gọi là hoàn thành tỉnh, Việt Nam hoặc toàn bộ đảo.

Cấu hình vòng chơi mới đang dùng tuyến **1.600 đơn vị scene** và ba điểm dừng ở 260/640/1.100. Đây là thông số thiết kế trong `RideRules`, không phải khoảng cách thực địa; không lấy thông số hoặc save của project cũ làm mặc định cho bản viết lại.

## Menu và điều kiện nghiệm thu

| ID | Hành vi và điều kiện nghiệm thu |
| --- | --- |
| VT-01 — Menu | Có **Start, Garage, Map, Settings, Quit** với nhãn/hành động rõ. Không gọi tính năng chưa hỗ trợ là đã có: Garage chỉ cam kết xem/chọn màu xe trong phạm vi triển khai, không có mua xe/kinh tế/asset thương mại mặc định. Quit phù hợp vòng đời nền tảng; không hứa cưỡng bức đóng iOS. |
| VT-02 — Lái và quan sát | Ga/phanh/lái thay đổi chuyển động thực của xe theo input; tốc độ hữu hạn; có camera bám và quan sát hướng chạy. Collision đường/mép chắn giữ xe trong vùng hợp lệ. Kiểm lại khi vào/ra menu hoặc app mất focus để không kẹt ga. |
| VT-03 — Đỗ và xuống xe | Theo cấu hình mới: tốc độ **≤0,35 đơn vị scene/giây**, vùng dừng cách mốc theo tuyến không quá 16, lane trong [3,6;6,5]. Ngoài điều kiện từ chối với gợi ý rõ; kiểm ở biên và hai phía của ngưỡng. Chạy ngang không nhận dấu. |
| VT-04 — Đi bộ và ba dấu | Chỉ đi bộ và cách POI **≤3 đơn vị** mới được khám phá. Ba ID `tea_hill`, `cloud_turn`, `village_gate` hoàn thành đúng thứ tự; bỏ qua thứ tự, còn ngồi xe hoặc ngoài tầm không ghi dấu. Mỗi dấu tối đa một lần; ba điểm có tên/nội dung riêng phù hợp cảnh minh họa. |
| VT-05 — Trở lại xe | Lên lại xe khi đủ gần (cấu hình **≤2,5 đơn vị**), không dịch chuyển từ xa. Chuyển mode không tạo bản sao xe/người và không tự tăng ga; thao tác đi bộ không đồng thời điều khiển xe. |
| VT-06 — Checkpoint | Reset về mốc an toàn **đã đi qua**: spawn 8 hoặc điểm 260/640/1.100; không chọn mốc tương lai chỉ vì gần hơn. Giữ dấu đã nhận. Nạp vị trí phải hợp lệ và không đưa xe vào collider/ngoài terrain. |
| VT-07 — Save mới/offline | Dùng file/schema save mới do project này quản lý; lưu tiến trình, dấu và cài đặt local. Mở lại giữ dữ liệu hợp lệ; dữ liệu sai kiểu/NaN/out-of-range xử lý an toàn. Không tuyên bố tự chuyển save project cũ nếu chưa có migration được triển khai và kiểm thử. Không đăng nhập hoặc tải mesh/palette/map để chơi. |
| VT-08 — Map | Hiển thị bốn chương với trạng thái đúng; Hà Giang `demo`, ba chương khác `planned`. Registry 34 tỉnh và sáu điểm đảo giữ trạng thái planned; chọn mục chưa có scene chỉ báo tình trạng, không quảng bá là khu 3D đã hoàn tất. Chú thích bản đồ minh họa dễ thấy. |
| VT-09 — Settings | Nhãn âm nhạc/hiệu ứng/chất lượng phản ánh chức năng đã có; thay đổi hợp lệ được lưu. Chọn chất lượng không được thay đổi POI, collision, dấu hoặc mục tiêu. Nếu audio chưa có nguồn phát, phải nói rõ chưa triển khai thay vì coi slider là âm thanh đã hoạt động. |
| VT-10 — Hình ảnh | Palette 512 và phong cách stylized nhất quán; đường, nhân vật, vùng đỗ/POI đọc rõ trong ánh sáng ấm. Dùng ảnh render thật để review bố cục, cây/cỏ, ruộng bậc thang và tầng xa; không tự gọi bán hiện thực/photoreal đã đạt hoặc dùng ảnh concept thay screenshot. |
| VT-11 — Phân đoạn thế giới | Chỉ giữ tập chunk hữu hạn quanh người chơi/điểm tham quan theo cấu hình; chạy qua tuyến không tăng vô hạn object/tài nguyên. Không tải toàn Việt Nam vào một scene. Chuyển chunk không tạo lỗ đường/va chạm hoặc mất dấu/save. |
| VT-12 — Điện thoại | Landscape, joystick/nút/camera không che nhau hoặc safe area; vừa ga/lái và thao tác nhìn được; menu/modal không để input xuyên xuống thế giới. Phải kiểm trên từng nền tảng trước khi tuyên bố native verified. |

Các ngưỡng gameplay là hợp đồng của bản mẫu mới, không là kết quả kiểm thử đã đạt. Nếu cấu hình code thay đổi, team cập nhật AC và kiểm thử cùng nhau thay vì âm thầm áp dụng quy tắc khác.

## Nền tảng, bằng chứng và giới hạn hiện tại

Máy đích người dùng đã nêu: **OPPO Find X7 Ultra** và **iPhone 13**. Chưa có phiên bản OS hoặc kết quả đo trên hai máy; không hứa FPS, RAM, nhiệt/pin hoặc IPA từ tên engine. Editor compile/play, APK build/ký/cài, iOS Xcode/ký/cài và profiling thiết bị là các cửa riêng; **tài liệu này không xác nhận đã có APK hoặc Editor pass của bản viết lại**.

Bản đầu cần kiểm loop lái–đỗ–đi bộ–nhận dấu–lên xe, ba POI theo thứ tự, reset/checkpoint, save mới, input/modal, chunk và trạng thái map. Một test logic đạt không thay thế render review hoặc test máy thật. Bằng chứng nghiệm thu ghi đúng build/commit/nền tảng; không cộng test project cũ thành thành tích bản mới.

## Sau vertical slice

Mở rộng từng chương sau khi pipeline nội dung, mỹ thuật và đo điện thoại đạt yêu cầu; không dựng lại hàng loạt scene cùng hình rồi gọi hoàn thiện mọi tỉnh. Trước khi cam kết đủ đảo: lập catalog nguồn thật với version/license/ID/tên/alias/parent/geometry, định nghĩa đảo đơn/quần đảo và đối soát gap; tiếp đó mới dựng cảnh chi tiết theo ID có thể nghiệm thu. Thời gian, dung lượng offline toàn quốc và chi phí chưa được cam kết khi chưa có dataset và ngân sách tài nguyên.

Ngoài phạm vi bản mẫu: multiplayer, backend, quảng cáo, mua hàng, GPS/dẫn đường thực, toàn mạng đường Việt Nam, photo album hệ điều hành và yêu cầu mua plugin/asset. Vòng chơi cốt lõi phải độc lập mạng và dịch vụ ngoài.

## Bổ sung yêu cầu — bản đồ 3D chọn hành trình

Bản đồ là **giao diện 3D tương tác để xem và chọn tuyến/chương**, không phải một thế giới mở tải toàn quốc để lái xe liên tục. Người chơi chọn tuyến rồi chuyển vào khu chơi/chunk tương ứng. Đủ nhãn 34 tỉnh/thành không đồng nghĩa đủ 34 scene; chỉ entry có nội dung sẵn sàng mới bắt đầu được hành trình.

Yêu cầu mới gồm biểu diễn cao độ/độ dốc, xoay–zoom bản đồ và lớp mây/giao thông hỗ trợ cảm giác hành trình. Các mục sau là **AC cần triển khai/kiểm chứng**, không xác nhận tính năng hiện đã hoạt động.

| ID | Điều kiện nghiệm thu bản đồ 3D |
| --- | --- |
| MAP-01 — Chọn tuyến | Có các marker/tuyến với tên, trạng thái và tóm tắt điểm đến. Chọn tuyến demo hiển thị thông tin trước khi bắt đầu; mục `planned` thông báo chưa sẵn sàng, không tải cảnh chung rồi báo đã dựng địa phương. Thao tác quay lại không xóa tiến trình hoặc tự cấp dấu. |
| MAP-02 — Cao độ | Bề mặt có chênh cao nhìn được, tuyến bám bề mặt hợp lý, không nổi/lún bất thường. Trước khi có DEM với nguồn/version/license được xác minh, ghi rõ **địa hình và cao độ minh họa**, không hiển thị chúng như số đo thực địa. Nếu phóng đại chiều cao để dễ nhìn, công bố đó là hệ số hiển thị. |
| MAP-03 — Độ dốc | Cung cấp biểu diễn độ dốc của tuyến được chọn bằng màu/chú giải hoặc thông tin đoạn; cách tính và đơn vị phải rõ. Dữ liệu minh họa phải ghi nhãn, không gọi là độ dốc thực của đèo. Đổi góc/zoom không làm thay đổi giá trị độ dốc nền; không suy độ dốc từ phối cảnh màn hình. |
| MAP-04 — Orbit/zoom | Xoay quanh vùng/tuyến đang xem, zoom có giới hạn và có thao tác về góc tổng quan. Không xuyên địa hình hoặc để camera mất bản đồ; nhãn/marker vẫn chọn được. Touch hỗ trợ orbit/zoom và thao tác tương đương trên desktop; kéo/zoom không đồng thời kích hoạt chọn tuyến ngoài ý muốn. Menu/modal hủy input đang giữ. |
| MAP-05 — Mây | Lớp mây có thể tạo chiều sâu/chuyển động nhưng không che tên, trạng thái, tuyến hoặc nút chọn; có cách giảm/tắt trong mức chất lượng phù hợp. Mây minh họa không phải thời tiết realtime; không gọi hiệu ứng height fog/lớp mesh mây là volumetric cloud nếu chưa có kỹ thuật đó. |
| MAP-06 — Giao thông | Biểu tượng/xe chuyển động trên tuyến bản đồ chỉ biểu diễn minh họa, không phải lưu lượng realtime. Chuyển động không tự bắt đầu chuyến đi, đổi checkpoint hoặc cấp dấu. Phân biệt lớp giao thông tổng quan với xe có vật lý/va chạm trong scene chơi; lớp bản đồ không chứng minh AI giao thông gameplay đã đạt. |
| MAP-07 — Offline và phạm vi tải | Bản đồ, nhãn, tuyến và hiệu ứng cần thiết nằm trong nội dung local; không cần API tile/thời tiết/traffic để thao tác. Bản đồ tổng quan dùng dữ liệu đơn giản hóa riêng, không khởi tạo mọi scene tỉnh/đảo. Khi vào một tuyến, chỉ tải khu chơi và tập chunk hữu hạn cần thiết. |
| MAP-08 — Nghiệm thu nguồn/thiết bị | Nếu dùng DEM/đường bờ/tuyến thật, phải ghi nguồn, version, license và phạm vi đối soát trước khi gọi là dữ liệu thực. Kiểm riêng render/input/bộ nhớ trên model Android/iPhone đích; screenshot desktop hoặc marker đầy đủ không thay cho Editor/build/device pass, chất lượng mỹ thuật hoặc coverage địa lý. |

Chưa có DEM được xác minh thì bản đồ 3D vẫn có thể dùng địa hình dựng tay/thuật toán phục vụ chọn tuyến với nhãn minh họa rõ ràng. Không lấy bước này làm bằng chứng đã hoàn thành mọi tỉnh/thành, mọi đảo hoặc tái dựng đúng Việt Nam.
