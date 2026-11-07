# Yêu cầu đồ họa mới — UE5, cảnh đèo Việt Nam

## Nguồn, mục tiêu và trạng thái

Nguồn đầu vào: tệp người dùng `Văn bản đã dán.txt` trong attachment `b9f54ef2-0c46-4411-bf6f-6d57d765008e`, đã đọc đầy đủ. Yêu cầu mới hướng tới UE5 và hệ sinh thái tài sản scan/PBR để tiến gần ảnh tham chiếu: đường nhựa ướt, vách đá, rừng nhiệt đới, thung lũng có sương, người lái xe và chi tiết Việt Nam. Tài liệu này chuyển các đề xuất thành điều kiện triển khai/nghiệm thu; lời quảng bá, giá, ngưỡng miễn phí, thời gian “vài phút” và hỗ trợ nền tảng trong tệp chưa được xác minh.

Hiện tại: Godot0.5 là prototype chơi được; hướng UE mới chỉ có scaffold/source đang được Dev chuẩn bị, **chưa compile/cook/render UE** tại thời điểm đặc tả. Chưa mua/tải/nhập các thư viện bên ngoài. Thiếu asset scan và render kiểm chứng thì không được tuyên bố đã đạt photoreal, UE fidelity hoặc ảnh tham chiếu. Không dùng ảnh tham chiếu làm texture hay bằng chứng quyền sử dụng.

Mobile Android/iOS và chơi offline vẫn là yêu cầu sản phẩm. Thiết bị mục tiêu: **Oppo Find X7 Ultra** và **iPhone13**; chưa có đo GPU/FPS/nhiệt/bộ nhớ thực trên hai máy. Cảnh đèo750scene-m/hai điểm dừng là lát cắt nghiệm thu, không phải bản sao tuyến thật hoặc toàn Việt Nam. Các yêu cầu toàn quốc/đảo và save/gameplay không tự hoàn thành khi đổi engine.

## Engine và hai nhánh chất lượng

UE5 là hướng được yêu cầu. Chọn một phiên bản cụ thể sau khi xác minh toolchain, SDK, plugin và cook cho cả hai nền tảng; “5.4 hoặc5.5+” trong nguồn không phải giấy phép dùng bản bất kỳ hoặc chứng minh plugin tương thích. C++/Blueprint là đường mặc định; UnrealCLR/UnrealSharp hoặc Unity6/HDRP+Gaia/MicroSplat chỉ là phương án nguồn đã nêu, không thêm dependency hoặc đổi engine ngầm.

| Hạng mục | Desktop showcase/reference | Mobile offline — hai thiết bị mục tiêu |
| --- | --- | --- |
| Nanite/scan high-poly | Đánh giá trên renderer/GPU được hỗ trợ, chỉ bật sau kiểm tra | Có mesh LOD/HLOD thông thường và collision giản lược; không giả định Nanite hoạt động/tối ưu trên máy đích |
| Lumen/GI/reflection | Đánh giá để đạt ánh sáng dưới tán và mặt đường ẩm | Có ánh sáng bake/probe hoặc phương án renderer đã kiểm; reflection capture/material wetness thay thế nếu cần; không bắt buộc Lumen |
| PCG/spline | Tool dựng/rải theo seed và exclusion rõ | Cook/bake kết quả hoặc xác minh runtime PCG thực sự được hỗ trợ; không phụ thuộc editor/plugin/cloud khi chơi |
| Fog/weather | Có thể thử volumetric/dynamic sky nếu hỗ trợ | Phương án fog đơn giản/card/VFX giới hạn, không che đường; các plugin chỉ dùng sau test cook/thiết bị |
| Foliage | Scan/cây chi tiết, kiểm alpha/shadow | LOD/impostor/culling/instancing; giới hạn overdraw, wind và shadow; không biến scene thành rừng trống |
| Nước/thác | Có thể thử sim nặng ở showcase riêng | Mesh/material nước chảy đơn giản, không buộc FluidFlux/VDB runtime |

Desktop đẹp không thay bằng chứng mobile. Chế độ Tiết kiệm/Chi tiết không được thay collision/POI/traffic/objective. Chỉ công bố tính năng renderer sau khi có build chạy; không dùng tên Nanite/Lumen như đồng nghĩa hình ảnh đạt yêu cầu.

## AC đồ họa có thể review

### GR-01 — Mặt đường PBR ướt và lề đường

Có base color, normal, roughness và thông tin tỉ lệ vật liệu; metallic hợp lý cho asphalt phi kim. Mặt đường có hạt mịn, vết sửa/nứt, vùng ẩm và vũng nông phân bố có chủ đích bằng vertex paint/mask hoặc phương án tương đương. Vũng nước không mặc định đổi collision thành hố; ổ gà vật lý nếu có phải thuộc scope gameplay riêng. Đất sỏi/bùn/rêu ở mép tiếp giáp vách tự nhiên, không một dải màu phẳng.

Kiểm ở camera sau xe và camera sát mặt đường: không lặp tile quá rõ, không texture kéo dài, không specular trắng cháy, vạch đường không nổi/z-fighting hoặc đứt qua cua. Wetness phải có tham số kiểm soát và đọc được ở mobile fallback. Texture scan chỉ nhập khi nguồn/license/version xác minh; procedural placeholder có nhãn, không được gọi là scanned.

### GR-02 — Vách đá và núi xa

Đá có silhouette/outcrop/ledge thật, mặt địa hình có breakup và chân đá tiếp đất, không chỉ noise trên tường nghiêng. Dùng scan được phép hoặc mesh riêng; tỷ lệ và kiểu đá/ẩm/rêu phù hợp bối cảnh đã chọn. Các tên Nordic/Thai/Jungle trong nguồn chỉ là hướng tìm, không đảm bảo địa chất Việt Nam.

Núi xa có2–3 lớp liên tục, màu/erosion khác nhau, không tấm tam giác rời hay trắng-cyan như tuyết ngoài chủ ý. Gaea/WorldMachine là công cụ ứng viên tạo heightmap; lưu recipe/version/scale và license đầu ra, không gọi heightmap tạo sinh là dữ liệu đo địa hình thật.

### GR-03 — Rừng nhiệt đới nhiều tầng

Cận cảnh có thân/cành, dương xỉ, cây bụi/chuối rừng/dây leo hoặc loài đã chọn có nguồn tham khảo; trung cảnh canopy biến thể; xa cảnh là khối rừng/LOD/impostor. Không rải mọi loài ngẫu nhiên hoặc dùng một sphere cho mọi cây. PCG có seed, tránh lòng đường/guardrail/lay-by/POI; không tạo trùng cây sau restart/đổi preset.

Foliage wind và lá ướt là yêu cầu nhìn thấy có kiểm soát, không hứa plugin tự làm mọi mesh ướt. Kiểm alpha edge, shimmer, overdraw, shadow và clipping từ camera lái. Mọi asset MAWI/ProjectNature/SpeedTree phải có phiên bản, giấy phép xuất/phân phối và mobile cook test riêng; chưa có asset thì chưa đạt tiêu chí scan/fidelity dù placeholder đủ chức năng.

### GR-04 — Ánh sáng, trời mưa/sau mưa và fog

Chốt một weather reference lặp lại được (trời u ám sau mưa là baseline phù hợp) để review cùng exposure. Wetness thống nhất trên đường/đá/lá/yên xe/ba lô với mask đúng vật liệu; không phải mọi bề mặt thành gương. Mưa/bắn nước nếu thêm phải có toggle/LOD và không làm HUD/đường khó đọc.

Fog thung lũng có phân lớp, giữ rõ đường/traffic/biển/điểm dừng ở khoảng gameplay. Không dùng sương che thiếu geometry; không mặc định plugin UDS/UDW/EasyFog tương thích mọi renderer. Thác/rãnh nước nhỏ là lớp bổ sung sau core, có luồng chảy và điểm tiếp xúc hợp lý; plugin FluidFlux/VDB là ứng viên, không phụ thuộc bắt buộc của bản mobile.

### GR-05 — Chi tiết Việt Nam, nhân vật và xe

Có bộ chi tiết gần camera: cột mốc, biển, hộ lan tôn, mép bê tông, đồ phượt và xe máy/người lái đúng tỷ lệ. Chữ tiếng Việt đọc được, vị trí biển hợp lý, gỉ/bùn có chủ đích. Không đặt tên tuyến/cột mốc thật để khẳng định dữ liệu GIS khi cảnh hư cấu. Xe khách/tải có silhouette phù hợp nhưng không tự dùng logo/livery thương hiệu thật khi chưa có quyền.

RealityCapture/Polycam chỉ dùng ảnh do nhóm có quyền chụp/xử lý; ghi provenance của scan và quyền người/vật/địa điểm khi liên quan. Không lặp khẳng định giá/ngưỡng miễn phí trong nguồn như điều khoản hiện hành. Xe ứng viên từ Fab/Sketchfab/CGTrader cùng SubstancePainter/backpack asset phải qua license/rig/LOD/texture kiểm tra; dùng mẫu xe generic khi chưa được phép dùng tên/logo/model thương hiệu.

### GR-06 — Xe máy: hình ảnh và vật lý là hai cửa riêng

Mesh có bánh, phuộc, tay lái, người ngồi/tay/chân, helmet, trang phục và animation tư thế phù hợp. Vật liệu bùn/ướt phải bám đúng bề mặt. Bánh quay, lái/nghiêng/phuộc cần đồng bộ vận động, không chỉ animation trang trí lệch collision.

ChaosVehicles là framework ứng viên, **không tự cung cấp mô hình xe máy ổn định hai bánh**. FGear/SimpleMotorcyclePhysics cũng chỉ là ứng viên chưa xác minh phiên bản/mobile/license. Cần prototype kiểm tra cân bằng hỗ trợ, steer/lean, phanh, vận tốc, suspension, collision và phục hồi trước khi chọn model; không quảng bá vật lý chân thực vì bật plugin. Giữ loop lái→dừng→đi bộ→POI→lên xe, input đa chạm và save an toàn.

## Asset pipeline, offline và quyền tài nguyên

Manifest ở `docs/art/asset-manifest.json` là danh sách ứng viên, không phải tài sản đã mua hoặc license đã cấp. Không download/mua khi chỉ đang lập yêu cầu. Mỗi asset được nhập sau này bắt buộc có: URL listing chính xác/creator, assetID, phiên bản, ngày lấy, license tên+revision+chứng từ quyền dùng, phạm vi platform/engine/phân phối, attribution, source-file checksum, đường dẫn asset cook, texture scale/channels, LOD/collision, mobile cook result. Không đặt credentials/chứng từ nhạy cảm vào repo.

Runtime chỉ đọc nội dung đã cook/đóng gói trong bản cài hoặc gói nội dung đã có sẵn trên máy; không cần Fab login, streaming cloud, tải texture/font/PCG data khi chơi. Audit dependency plugin, shader/material và file ngoài cook. Chế độ máy bay phải hoàn thành cả hai điểm dừng sau fresh install. Bản quyền/licensing chưa xác minh là blocker nhập asset; không thay trạng thái bằng “free” do thấy trong tệp tham khảo.

## Cửa nghiệm thu và bằng chứng

1. **Source gate:** scaffold mở/compile được bằng UE version xác định, plugin list rõ. Source chưa compile không gọi là bản UE chạy được.
2. **Asset gate:** ít nhất một bộ asphalt/rock/foliage/prop có license và import/cook được; placeholder không đóng cửa scan/fidelity.
3. **Desktop render:** chụp actual render cùng station/lane/origin/basis/FOV/resolution tại start, bend350, stop230; bổ sung stop550 để phân biệt bố cục; giữ weather/exposure/time-of-day. Ghi renderer, engine, preset, shadow, far plane và số liệu frame. Ảnh tạo sinh chỉ là concept, không là screenshot game.
4. **Mobile cook/run:** Android và iOS cook/build riêng; iOS cần toolchain/signing thích hợp. Cài/chạy trên OppoFindX7Ultra và iPhone13, kiểm cùng4góc, camera chuyển động/collision, giữ ga+lái/phanh, loop hai điểm, restart/save và airplane mode. Không suy pass iOS từ Android.
5. **Device budget:** mục tiêu ban đầu30fps, chưa cam kết đạt; ghi GPU/CPU frame-time, spike khi streaming/chuyển cảnh, memory/package size, thời gian tải, nhiệt và ổn định phiên dài. Chốt ngân sách texture/triangles/overdraw/drawcalls theo phép đo thực, không lấy con số desktop làm chuẩn mobile.
6. **Fidelity acceptance:** PO/người dùng review GR-01–05 so ảnh tham chiếu ở cùng điều kiện; ghi điểm đạt/chưa đạt. “Chạy UE”, “có scans” hoặc “build APK” không tự đóng cửa hình ảnh.

Không hạ mục tiêu mobile/offline âm thầm để đạt showcase desktop. Nếu asset/toolchain còn thiếu, tiếp tục chuẩn bị source/pipeline và ghi blocker cụ thể; không công bố photoreal đã hoàn thành.
