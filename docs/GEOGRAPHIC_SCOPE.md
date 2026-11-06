# Phạm vi dữ liệu địa lý và quy tắc coverage

## Trạng thái dữ liệu hiện tại — 05/11/2026

Registry tại [`game3d/data/geography/regions.json`](../game3d/data/geography/regions.json) hiện có **47 bản ghi: 34 tỉnh/thành và 13 vùng đảo/đặc khu**. Nguồn được pin tại [`sources.json`](../game3d/data/geography/sources.json):

- Repository cộng đồng: [ThangLeQuoc/vietnamese-provinces-database](https://github.com/ThangLeQuoc/vietnamese-provinces-database).
- Commit: `8b78ba5118715e1fa81769286724db79346abf52`.
- File: `json/simplified_json_generated_data_vn_units.json`.
- SHA-256 upstream: `f624138116bde151c860cbd25a84cd6b9b38250e8a049ed371c55dee729ac286`.
- Giấy phép MIT; bản giấy phép lưu tại [`LICENSE-vietnamese-provinces-database.txt`](../game3d/data/geography/LICENSE-vietnamese-provinces-database.txt).

Đây là dữ liệu cộng đồng có dẫn nguồn nhà nước, **chưa phải dữ liệu được đối chiếu trực tiếp đầy đủ với văn bản nhà nước**. Con số 34 đã được đối chiếu với bản dữ liệu trên; không suy ra mọi nhãn loại đơn vị hoặc thông tin pháp lý đều đã được xác minh. Tên/mã cần tiếp tục đối chiếu nguồn chính thức trước phát hành.

**13 bản ghi vùng đảo/đặc khu:** Vân Đồn, Cô Tô, Cát Hải, Bạch Long Vĩ, Cồn Cỏ, Hoàng Sa, Lý Sơn, Trường Sa, Phú Quý, Côn Đảo, Phú Quốc, Thổ Châu, Kiên Hải. Một vùng đảo/đặc khu có thể gồm nhiều đảo; không coi 13 bản ghi này là 13 đảo đơn hoặc danh sách tất cả đảo có tên. `type: island` trong registry prototype là phân loại chọn cảnh, không xác lập bản chất pháp lý/hình học của từng đối tượng. Với Hoàng Sa/Trường Sa, nhãn phản ánh mục nhập nguồn; không phải kết luận độc lập về chủ quyền, kiểm soát hay khả năng tham quan thực tế.

`sources.json` ghi `all_vietnam_islands_verified: false`, không kèm tọa độ hoặc hình học ranh giới; địa hình hiện là minh họa thuật toán, không phải đo đạc. **Còn thiếu:** danh mục đầy đủ đảo thành phần có tên, ID đối soát giữa các nguồn, đường bờ, cao độ, quan hệ đảo/quần đảo, nội dung và POI đặc trưng từng nơi. Có 47 entry hoặc 47 cảnh tạo được không đồng nghĩa đã hoàn thành toàn bộ tỉnh/đảo theo yêu cầu nội dung.

## Nguồn và truy xuất

- Tên, mã, đơn vị cấp tỉnh và ngày hiệu lực: dùng văn bản chính thức cùng danh mục mã đơn vị hành chính hiện hành. Văn bản ứng viên cần tra cứu/đối chiếu là Nghị quyết 202/2025/QH15; ghi URL chính thức, ngày truy cập và phạm vi xác minh khi sử dụng, không suy ra các chi tiết chưa đọc.
- Địa danh du lịch: lưu tên hiển thị, tên thay thế, tọa độ/độ chính xác nếu có, đơn vị quản lý tham chiếu và nguồn. Địa danh không tự tạo thành tỉnh/thành mới.
- Đảo/quần đảo: cần dataset có ID ổn định, định nghĩa đối tượng và giấy phép phù hợp. Làm rõ đảo đơn, quần đảo, đảo có tên, đá/bãi ngầm và tên trùng có nằm trong phạm vi hay không. Không tự gom quần đảo thành một đảo để làm giảm số lượng coverage.
- Khi nguồn không thống nhất về ranh giới hoặc tên tại khu vực tranh chấp, giữ thông tin nguồn và trình bày phù hợp; không tự kết luận tranh chấp từ mô hình hoặc nhãn trong game.

## Bản ghi tối thiểu

| Nhóm | Trường tối thiểu |
| --- | --- |
| Province | ID ổn định; tên hiện hành; loại đơn vị; mã chính thức nếu xác minh được; ngày hiệu lực; nguồn/giấy phép |
| Destination/POI | ID; tên du lịch; provinceId khi quan hệ đã xác minh; nguồn nội dung; sceneId hoặc trạng thái chưa có cảnh |
| Island | ID nguồn; tên; loại đối tượng; quan hệ nhóm/quần đảo nếu có; tọa độ/hình học và độ chính xác khi có; nguồn/phiên bản/giấy phép; trạng thái kiểm duyệt |
| Scene | ID; vùng/đối tượng đại diện; tài nguyên nội bộ; mức độ chi tiết; POI; trạng thái chơi được; nền tảng/kết quả kiểm thử |

Quan hệ tỉnh/địa danh/đảo có thể để chưa xác minh và chặn tuyên bố đầy đủ, thay vì điền giá trị đoán. Tọa độ sơ đồ dùng cho layout phải ghi là minh họa, không giả làm tọa độ địa lý.

## Mức chi tiết đảo đã được chủ sản phẩm bổ sung

Mọi đảo thuộc dataset thống nhất đều phải vào được **cảnh địa hình 3D có điều khiển nhân vật và tương tác**. Có bản ghi hoặc marker trên bản đồ là chưa đủ.

- **Đảo tiêu biểu:** cảnh thiết kế thủ công, có chi tiết và POI đặc trưng được kiểm chứng. Danh sách đảo tiêu biểu phải công bố rõ.
- **Các đảo còn lại:** được dùng địa hình sinh bằng thuật toán để cung cấp cảnh tương tác, nhưng nhãn phải ghi rõ “địa hình minh họa”, không phải số hóa thực địa. Cảnh liên kết đúng ID, có bề mặt/va chạm, vùng an toàn và ít nhất một POI để tương tác. Không biến seed thuật toán thành tuyên bố về hình dạng, độ cao hoặc công trình có thật.

Danh mục coverage phải phân biệt cảnh thủ công, cảnh thuật toán, marker-only và chưa có nội dung. Nếu chưa có dataset exhaustive thì chỉ nghiệm thu đủ theo **dataset đã chốt**, không khẳng định bao phủ tất cả đảo Việt Nam. Báo cáo các khoảng trống về nguồn, đảo không tên, đối tượng ngoài tiêu chí hoặc quan hệ chưa xác minh là bắt buộc. Đánh giá kích thước offline, bộ nhớ và thời gian nạp trước khi nhân rộng.

## Lộ trình bổ sung dữ liệu có đầu ra kiểm tra được

| Bước | Công việc | Đầu ra và cửa nghiệm thu |
| --- | --- | --- |
| D1 — Đối soát hành chính | So sánh 34 ID/tên/mã với danh mục nhà nước hiện hành, lưu văn bản, URL, thời điểm hiệu lực và bảng khác biệt | Mỗi entry có nguồn trực tiếp hoặc trạng thái chưa đối soát; sửa nhãn không đúng mà không đổi ID tùy tiện; không coi MIT dataset thay cho thẩm quyền pháp lý |
| D2 — Danh mục đảo có tên | Đánh giá GeoNames country dump `VN.zip`, lọc feature code đảo/nhóm đảo và bảo toàn geonameId/tên/tọa độ; đánh giá dữ liệu OSM `place=island`/`place=islet` như nguồn đối chiếu | Snapshot được pin và kiểm tra license, bảng tổng số trước/sau lọc, danh sách trùng/khác biệt; không loại tên chỉ vì không khớp với 13 đặc khu |
| D3 — Kiểm duyệt phạm vi | So sánh tên, alias, quan hệ nhóm và nguồn địa lý/du lịch chính thức; xử lý vùng ngoài phạm vi hoặc có tranh chấp bằng trạng thái nguồn | Danh sách ID đủ điều kiện + danh sách còn thiếu/chưa xác minh + lý do; không tuyên bố nguồn đơn lẻ exhaustive |
| D4 — Hình học và địa hình | Chọn nguồn đường bờ, cao độ có license phân phối offline; đối soát geometry với ID đã chốt | Tách `real_geometry` và `illustrated_terrain`; không ghép polygon gần nhất thành dữ kiện chắc chắn; có attribution theo nguồn |
| D5 — Cảnh tương tác toàn registry | Tạo scene theo ID cho mọi entry đủ điều kiện; cảnh đảo chưa authored dùng terrain minh họa có điều khiển và POI | Test tự động scene load/ID/va chạm/POI và test thiết bị theo nền tảng; marker không được tính thay scene; không tính procedural là chi tiết thực địa |
| D6 — Chi tiết từng đảo | Ưu tiên đảo tiêu biểu rồi mở rộng POI, mô hình đặc trưng và nội dung địa phương theo backlog | Báo cáo riêng scene generic, scene minh họa có nội dung và scene authored; phần chi tiết riêng chưa làm vẫn là gap so với mong muốn tham quan chi tiết |

GeoNames là **nguồn dự kiến**, chưa được nhập hoặc kiểm chứng: URL phân phối `https://download.geonames.org/export/dump/VN.zip`; host tải hiện chưa có trong allowlist môi trường theo kiểm tra của nhóm. Không truy cập đường vòng hoặc coi dữ liệu đã có. Cần license/attribution và kiểm chứng mức bao phủ trước khi dùng. Dữ liệu OSM cần đánh giá nghĩa vụ ODbL và attribution trước khi đóng gói; chưa có snapshot OSM nào được xác nhận trong registry hiện tại.

Đã khảo sát một bản cache candidate hình học đảo nhỏ toàn cầu: 2.795 features, chỉ có metadata phân loại/scale, không có tên/ID đảo hoặc quốc gia. Candidate này không giải quyết danh mục đảo có tên; chỉ xem xét tiếp sau khi pin được provenance và license. Bounding box địa lý không đủ để kết luận quan hệ quản lý hoặc chủ quyền.

## Báo cáo coverage bắt buộc

1. Đóng băng phiên bản nguồn và danh sách ID thuộc phạm vi, nêu ngoại lệ với lý do.
2. Kiểm tra thiếu/trùng ID, tên, quan hệ và tình trạng giấy phép.
3. Báo cáo riêng: registry tỉnh đã xác minh / mục tiêu; tỉnh có cảnh đại diện đạt nghiệm thu / registry; đảo trong dataset; đảo có marker; đảo có scene thủ công đạt nghiệm thu; đảo có scene thuật toán đạt nghiệm thu; khoảng trống so với mục tiêu đủ đảo.
4. Với mỗi cảnh, nêu Android/iOS đã hoặc chưa kiểm thử; nội dung placeholder không được tính là scene địa danh hoàn chỉnh.
5. Công bố mức bao phủ theo ngày và phiên bản. Khi địa giới hoặc dataset thay đổi, đối soát lại và giữ khả năng di trú tiến trình theo ID ổn định.

“34 bản ghi tỉnh” chỉ chứng minh độ phủ registry nếu đã kiểm chứng nguồn. “34 scene” chỉ chứng minh số scene; muốn kết luận mọi tỉnh có cảnh phải đối soát quan hệ và nghiệm thu từng tỉnh. Không dùng “toàn bộ đảo Việt Nam” nếu chưa có dataset, tiêu chí và kiểm đếm đủ điều kiện.
