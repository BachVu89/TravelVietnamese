# Roadmap sản phẩm — VietTrail mới

Quyết định PO ngày 09/11/2026. Người dùng yêu cầu viết lại toàn bộ theo hướng **stylized painterly**. Đây là roadmap của project Unity mới tại `Assets/VietTrail`, không kế thừa nghiệm thu, tài nguyên hoặc số kiểm thử của game cũ. Lịch sử Git chỉ là hồ sơ; không nhập lại source/assets cũ vào implementation mới.

## Hướng sản phẩm và phạm vi bản đầu

Trải nghiệm du lịch Việt Nam bằng xe máy và đi bộ, mobile Android/iOS, chơi offline. Hình ảnh theo tham chiếu: pastel hài hòa, chuyển màu theo cao độ, khối núi mềm nhiều lớp, ruộng bậc thang và bình minh. Menu tiêu đề và gameplay phải thuộc cùng một thế giới hình ảnh, không dùng một ảnh quảng bá đẹp để đại diện cho cảnh chơi chưa đạt.

Bản đầu là **một tuyến đèo miền Bắc khoảng 1.600 đơn vị scene**, ba điểm dừng có góc nhìn/nội dung riêng, vòng lái → đỗ → đi bộ tham quan → lên xe đi tiếp. Đây là chiều dài minh họa, không phải đo GIS hoặc tái dựng chính xác một con đèo thực. Menu gồm vào chơi/tiếp tục, garage ba lựa chọn phối màu xe, bản đồ hành trình và cài đặt input. Ba phối màu không được gọi là ba dòng xe có vật lý khác nhau nếu chỉ đổi palette. Không thêm thanh toán/mua hàng hoặc nghiên cứu thị trường trong batch này.

Bản đồ Việt Nam minh họa có bốn chương và tên 34 tỉnh/thành dự kiến; tên địa phương không đồng nghĩa đã có scene/nội dung chơi được. Những địa điểm chưa làm phải được ghi là dự kiến, không tạo nút vào cảnh giả. Mọi đảo có tên vẫn là yêu cầu tương lai chưa đối soát; ba điểm dừng trên đèo không thay thế catalog đảo.

## Ưu tiên hiện tại — bản đồ 3D tương tác trước full ride scene

**Cập nhật theo yêu cầu mới nhất:** giao bản đồ 3D có thể nhìn, xoay, zoom và chọn địa điểm trước khi hoàn thiện các cảnh lái xe. Các mốc tuyến đèo/garage phía sau vẫn là định hướng sản phẩm, không phải phạm vi bắt buộc của lượt bản đồ này. Không hứa hoàn thành trong 15 phút hoặc thời lượng cố định khi chưa có bằng chứng thực thi.

| ID | Điều kiện nghiệm thu bản đồ | Bằng chứng cần có |
| --- | --- | --- |
| MAP-01 Địa hình painterly | Bản đồ minh họa có khối địa hình phân cao độ, độ dốc đọc được qua hình khối/màu, núi mềm và palette nhất quán. Đây là địa hình sinh minh họa, **chưa dùng DEM**, không phải mô hình cao độ Việt Nam chính xác. Không ghi phủ đủ toàn quốc hoặc mọi đảo. | Capture Unity thật ở góc toàn cảnh và cận cảnh, nêu rõ dữ liệu procedural và gap hình học/địa lý; không dùng ảnh mockup làm bằng chứng chạy. |
| MAP-02 Tương tác camera | Orbit và zoom hoạt động bằng mouse/keyboard tương ứng và touch theo input contract; có giới hạn zoom/pitch để tránh chui qua địa hình hoặc mất bản đồ. UI/modal hủy drag đang giữ, không vừa bấm marker vừa quay camera. | Thao tác thật orbit/zoom/chọn địa điểm, kiểm giới hạn và focus/modal; desktop touch simulation được ghi riêng thiết bị thật. |
| MAP-03 Chọn địa điểm | Marker có tên và trạng thái rõ, chọn mở thông tin/preview của địa điểm. Chỉ scene thực sự tồn tại mới có thao tác vào chơi; địa điểm dự kiến ghi rõ chưa có nội dung. Tên 34 tỉnh hoặc bố cục bốn chương không tự chứng minh geometry/scene hoàn chỉnh. | UI flow mở/chọn/đóng, trạng thái planned/playable trung thực và không ghi dấu tham quan từ thao tác chọn marker. |
| MAP-04 Chuyển động thế giới | Mây và traffic trang trí tạo cảm giác sống trên bản đồ nhưng không che thông tin hoặc cản chọn marker. Chúng là hiệu ứng minh họa, không phải dữ liệu thời tiết/giao thông thật. Không cần mạng; chuyển động tạm dừng/tiếp tục hợp lệ theo vòng đời ứng dụng. | Capture hoặc phiên chạy thật thể hiện chuyển động và vẫn tương tác camera/marker được; kiểm tài nguyên offline và không claim traffic routing/GIS. |

**Gate bản đồ:** PO/Designer rà render thật về palette, cao độ/độ dốc, bố cục và độ rõ tương tác. QA kiểm orbit/zoom/selection/modal/lifecycle phù hợp; source chuẩn bị hoặc tổng test không tự đóng gate render. Nếu Unity/toolchain chưa có, báo đúng blocker và tiếp tục source/data độc lập, không claim app đã chạy/build/publish.

**DEM là bước tương lai có điều kiện:** chỉ nhập khi có nguồn/version/license/phạm vi độ phân giải, hệ tọa độ và kiểm địa lý. Blur/smoothing và vertical exaggeration phải là tham số được ghi rõ, đối chiếu trước–sau để biết đã làm biến dạng độ dốc/cao độ thế nào; không dùng phép làm mượt/phóng đại để tuyên bố chính xác thực địa. Geometry đảo/biên giới phải qua catalog và đối soát nguồn, không suy từ ảnh tham chiếu hoặc bbox. Bản đồ minh họa hiện tại không được đổi nhãn thành DEM vì có relief.

## Mốc kế tiếp sau bản đồ — chứng minh hình ảnh và vòng chơi mới

Mốc vòng chơi này thực hiện sau khi bản đồ 3D tương tác dưới đây có bằng chứng; chưa mở rộng hàng loạt full ride scene. Team có thể chuẩn bị project/data độc lập khi thiếu Editor, nhưng không tự đánh dấu mốc đạt.

| ID | Điều kiện nghiệm thu | Bằng chứng cần có |
| --- | --- | --- |
| NEW-01 Project chạy thật | Project mở bằng Unity 6/URP theo manifest cấu hình hiện tại; scene vào được, không lỗi compile/import chặn chơi. Không tái dùng Godot/UE/source/assets cũ, HDRP hoặc bộ PBR/Meshy thay cho hướng painterly. | Phiên bản Editor/package thực, kết quả import/console và Play Mode hoặc bản chạy thật. Source tĩnh không đủ. |
| NEW-02 Một khung hình thống nhất | Title/menu có bố cục hoàn chỉnh, chữ đọc được và cùng palette/ánh sáng/ngôn ngữ hình khối với gameplay. Gameplay tại đầu tuyến, khúc cua và điểm dừng thể hiện pastel, height gradients, núi mềm phân lớp, ruộng bậc thang và bình minh. Không nghiệm thu chỉ bằng screenshot menu. | Ảnh tham chiếu được gắn nhãn rõ và ảnh chụp Unity thật tại các vị trí cố định; ghi camera/FOV/resolution/render settings. Designer/PO nêu từng điểm khớp và gap còn lại. Ảnh tạo ngoài engine không thay capture gameplay. |
| NEW-03 Lái và tham quan | Tuyến mục tiêu 1.600 scene-m liên tục, ba điểm dừng phân biệt được. Input thật điều khiển ga/phanh/lái/camera; đỗ đúng vùng và tốc độ an toàn mới xuống xe, đi bộ tới POI để tương tác rồi quay lại xe. Chạy qua không tự nhận dấu; reset không làm mất tiến trình hoặc đẩy tới đoạn chưa đi. | Video/capture hoặc phiên chơi quan sát được qua ít nhất một vòng dừng–đi bộ–tương tác–lái tiếp, cùng kiểm thử guards và khả năng đi hết tuyến. Teleport setup không thay bằng chứng chơi. BA/SA ghi rõ ngưỡng/config trước QA. |
| NEW-04 Menu/garage/map/input | Vào chơi/tiếp tục, ba phối màu xe, bản đồ bốn chương và input presets dùng được; lựa chọn phản ánh hành vi thật. Map phân biệt rõ tuyến đã chơi được với tên dự kiến. Touch/keyboard không bị kẹt khi modal/focus thay đổi. | Thao tác UI thật; cài đặt/garage áp dụng vào gameplay; sơ đồ map có chú thích coverage. Preset phải được giải thích bằng thông số/hành vi, không hứa tối ưu thiết bị khi chưa đo. |

**Gate hình ảnh:** PO/Designer chỉ chấp nhận chất lượng đã nhìn thấy trong capture engine. Tests logic đạt không tự chứng minh painterly, tương đồng tham chiếu hoặc trải nghiệm thú vị. Nếu núi/ánh sáng/menu chưa tạo được một thế giới thống nhất, sửa tại tuyến mẫu trước khi thêm nhiều asset. Không đổi mục tiêu sang photoreal.

## Ràng buộc render và tài nguyên

- URP là pipeline đã chọn; baseline dùng height fog rẻ/giải pháp phù hợp được triển khai và kiểm thực tế. Không mô tả URP như mặc định đã có native volumetric fog hoặc cam kết hiệu ứng volumetric chưa làm.
- Palette dùng chung giúp nhất quán màu; **không tự động tạo một draw call**. Draw calls/batches phải lấy từ công cụ profiler/frame debugger của scene thực với thiết lập đã ghi.
- Chunk có giới hạn số lượng không tự chứng minh RAM được chặn hoặc tài nguyên đã giải phóng. Kiểm số chunk đang sống, vòng đời mesh/material/texture và memory sau đi tới–quay lại; phân biệt managed/native/GPU theo công cụ có sẵn.
- Mesh, shader, texture, font và âm thanh mới phải do team tạo hoặc có provenance/license được kiểm. Không dùng lại asset cũ hoặc ảnh tham chiếu làm texture chỉ vì đã xuất hiện trong cuộc trò chuyện. Mọi nội dung bắt buộc đóng gói để chơi offline.

## Mốc sau vòng chơi — save, vòng đời và thiết bị mobile

Chỉ mở rộng mỹ thuật/nội dung sau khi mốc hình ảnh/vòng chơi có bằng chứng. Tiếp theo ưu tiên save/lifecycle thay vì menu phụ.

1. Chốt schema save của game mới với ID ổn định, checkpoint an toàn đã đi qua, dấu POI, phối màu và input settings. Không tự nhận tương thích save game cũ; nếu muốn import dữ liệu cũ cần yêu cầu/migration riêng. File hỏng được phục hồi có báo rõ và không mất bản gốc ngoài chủ ý.
2. Kiểm đóng/mở lại, chuyển scene, pause/background, mất focus và gián đoạn lúc ghi; không mất dấu, sinh thêm xe hoặc giữ ga/touch cũ. Save theo transition/checkpoint hợp lý, không ghi mỗi frame.
3. Build Android/iOS chỉ được gọi sẵn sàng khi đã có artifact thực và kết quả kiểm phù hợp. Editor/import hoặc C# compile không đồng nghĩa APK/IPA build được. Không giả vờ đã ký, cài, publish hoặc chạy khi chưa có công cụ.
4. Kiểm thiết bị thật: khởi động offline, điều khiển đa chạm, safe area, readability, save/resume và profiler CPU/GPU/RAM/nhiệt trong tuyến mẫu. Ghi model/OS/build/config và thời lượng. Target phone không phải device tested; không cam kết 30 FPS hoặc memory ceiling khi chưa đo.

Mỗi lần giao ghi riêng: **source prepared → Editor verified → desktop playable/art reviewed → artifact ready → device verified → published**. Trạng thái sau cần bằng chứng riêng, không được suy ra từ trạng thái trước. Không thêm bước xin phép mới cho công việc đã được người dùng giao; tiếp tục các việc độc lập và ghi blocker thật khi thiếu Editor/toolchain.

## Mốc catalog địa lý trước mở rộng toàn Việt Nam

Chuẩn bị catalog song hành khi có nguồn; sau bằng chứng bản đồ/game mới và save/lifecycle, giao catalog địa lý có thể review trước khi thêm tuyến phụ/asset hàng loạt:

- Xác minh nguồn/version/license cho danh mục tỉnh và các đảo/quần đảo có tên; định nghĩa đơn vị bản ghi, ID/alias/quan hệ cha–con, geometry và ngày rà soát. Không dùng bbox hoặc tên đoán để tự gắn quốc gia.
- Báo riêng registry, geometry đã kiểm, scene vào được và nội dung tham quan đã biên tập. Mẫu số “mọi đảo” chưa được công bố khi nguồn và quy tắc đối soát chưa chốt.
- Bốn chương là cấu trúc dẫn chuyện của bản đồ minh họa; không phải bằng chứng phủ lãnh thổ hoặc bốn khu vực hành chính chính xác.
- Đề xuất một cảnh đảo có nội dung/góc nhìn riêng theo pipeline đã chứng minh trên đèo; chỉ mở rộng sau rà nguồn, chi phí và kiểm offline. Tên đủ 34 tỉnh không đóng yêu cầu Việt Nam/đảo.

## Cách PO chốt nghiệm thu

BA chuyển các ID trên thành AC/config kiểm được; SA/Dev ghi implementation và rủi ro; Designer đối chiếu capture thật; QA báo kết quả theo từng AC và môi trường; PO quyết định accepted/needs revision theo phạm vi. Báo cáo nêu vòng chơi thực hiện được, ảnh nào cho thấy mục tiêu mỹ thuật, artifact nào tồn tại và phần chưa kiểm — không lấy tổng assertion hoặc số asset làm kết quả sản phẩm.

**Trạng thái khởi tạo:** roadmap/AC được chuẩn bị; Unity Editor và toolchain chưa được xác minh khả dụng trong môi trường hiện tại. Chưa có bằng chứng để nghiệm thu gameplay/render, build mobile, hiệu năng hay phát hành của bản viết lại.
