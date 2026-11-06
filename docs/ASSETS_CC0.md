# Tài nguyên đồ họa CC0 dùng từ bản 0.8

Mọi tài nguyên dưới đây thuộc **CC0 1.0** (miền công cộng): được phép dùng thương mại, sửa đổi và phân phối lại, không bắt buộc ghi công. Dự án vẫn ghi nguồn tại đây và trong hộp thoại **Giấy phép & nguồn dữ liệu** của game để minh bạch. Tải ngày 07/11/2026.

## Poly Haven — polyhaven.com

| File trong repo | Tài nguyên gốc | Dùng cho |
| --- | --- | --- |
| `game3d/assets/textures/aerial_grass_rock/*_1k.jpg` | Textures "aerial_grass_rock" (Diffuse/Nor GL/Rough) | Mặt đất sườn đồi (triplanar) |
| `game3d/assets/textures/dark_rock/*_1k.jpg` | Textures "dark_rock" (Diffuse/Nor GL) | Vách đá và khối đá |
| `game3d/assets/textures/asphalt_01/*_1k.jpg` | Textures "asphalt_01" (Diffuse/Nor GL/Rough) | Mặt đường |
| `game3d/assets/sky/cloudy_cliffside_road_1k.hdr` | HDRI "cloudy_cliffside_road" 1k | Bầu trời + ánh sáng môi trường |

Đã đánh giá nhưng KHÔNG dùng: model cây quét 3D của Poly Haven (pine_tree_01, fir_tree_01) — vài trăm MB nguồn và hình học quá nặng cho MultiMesh hàng trăm cây/bản mobile.

## Quaternius — quaternius.com, qua Poly Pizza (poly.pizza)

Gói **Stylized Nature MegaKit**, CC0. Các model GLB trong `game3d/assets/models/quaternius/`:

- Cây: `Pine_1..3`, `Tree_1..5` (đã phân tích màu texture lá: toàn bộ là biến thể lá xanh)
- Bụi/cỏ/dương xỉ: `Bush_with_Flowers_1`, `Fern_1`, `Grass_Wispy_1`, `Tall_Grass_1`, `Plant_1`, `Plant_Big_1`
- Đá: `Rock_Medium_1`, `Rock_Medium_2`
- Đã tải nhưng loại vì lá đỏ mùa thu lệch tông cảnh: `Twisted_Tree_1`, `Bush_1` (không còn trong repo)

Texture trích từ GLB được Godot tách thành PNG cạnh model khi import; toàn bộ texture import đặt nén VRAM (`compress/mode=2` trong các file `.import`) để giữ dung lượng bản dựng thấp. Tổng thư mục `game3d/assets/` khoảng 52 MB nguồn.
