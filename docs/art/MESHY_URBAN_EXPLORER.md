# Urban Explorer — kiểm tra asset Meshy thực nhận

Đã ghép và đọc đủ ba volume người dùng cung cấp, sau đó import FBX thật bằng **Blender 4.3.2** và render CPU Cycles hai phía với bốn map gốc. Đây là **một nhân vật nam duy nhất** có mũ bảo hiểm, áo khoác cam, máy ảnh, túi đeo và ba lô; tên tệp “Character Sheet” không đồng nghĩa với một tấm nhiều nhân vật hay mô hình nhiều góc nhìn bị ghép vào nhau. Hai ảnh kiểm tra cho thấy mặt ở phía trước và ba lô ở phía sau của cùng nhân vật.

Đây vẫn là **mesh tĩnh chưa rig**, đứng A-pose, chân thẳng và hai tay chếch xuống ra ngoài. Không phải tư thế ngồi lái xe; không có bằng chứng cho phép coi bản này đã có animation hoặc dùng trực tiếp làm rider. Không thay thế Courier, Walker hay Rider trong Unity ở bước kiểm tra này.

## Kết quả đo

| Thuộc tính | Kết quả thực nhận |
|---|---|
| Nội dung archive | 1 FBX và 4 PNG |
| Mesh import | `Mesh_0`, một mesh object |
| Vertices | 563,215 |
| Polygons / triangles | 1,126,822 / 1,126,822 |
| UV | Một lớp `UVMap` |
| Material gốc | Một slot `Material.001` |
| Bounds Blender | khoảng 1.11693 × 0.667952 × 1.900204 đơn vị world |
| Pivot / chân | Bounds Z khoảng −0.950511 đến +0.949693; pivot chưa đặt tại chân |
| Armatures / bones | Không có |
| Actions / animation | Không có action import |
| Vertex groups / skinning | Không có; không có armature modifier |
| Shape keys / modifiers | Không có |
| Map | Base Color, Metallic, Roughness, Normal, mỗi map 2048×2048 |

Các kích thước là kết quả importer Blender, chưa phải chiều cao đã được xác nhận trong Unity. Ảnh `front`/`reverse` là nhãn camera kiểm tra; hướng trục mặt trước trong Unity còn phải xác nhận khi import. Kiểm tra hình ảnh không phải phép đo connected-component topology: một mesh có thể chứa những phần phụ kiện rời về topology.

Map màu được đọc sRGB; ba map dữ liệu được đọc Non-Color. Inspector chỉ nối lại map trong bộ nhớ cho render kiểm tra, không chỉnh sửa/re-export FBX hoặc PNG nguồn. Các đường dẫn embedded material có thể cần được gán lại rõ ràng khi import engine.

## Nguồn, hash và bằng chứng

Ba volume có kích thước lần lượt **25,165,824 / 25,165,824 / 15,699,524 bytes**. Ghép được 7z chứa ZIP `Meshy_AI_Urban_Explorer_Character_Sheet_20261108_texture_fbx.zip`, **68,122,495 bytes**.

- SHA256 archive ghép: `674884608c7b610b5b12249ae5747b58a7a2c4743dcc824c5877af5f6cc94aa6`
- SHA256 ZIP bên trong: `228ba8fef9658d12814029d5c12328cc933b8921024499f59db32fc3dcc37f70`
- Manifest volume và kích thước: `/tmp/meshy-urban-explorer/parts.json`.
- Báo cáo mesh, map và SHA256 từng tệp: `/tmp/meshy-urban-inspection/report.json`.
- Ảnh render thật: `/tmp/meshy-urban-inspection/front-blender.png` và `reverse-blender.png`.

Bản gốc và kết quả giải nén được giữ **ngoài Unity Assets** tại `/workspace/attachments`, `/tmp/meshy-urban-explorer` và `/tmp/meshy-urban-inspection`. Không thay hoặc xóa bản Courier trước đó. Báo cáo Courier tiếp tục mô tả asset Courier riêng; Urban Explorer là một ứng viên khác.

## Chạy lại

Ghép bằng công cụ đã có, truyền đúng thứ tự các đường dẫn `.001`, `.002`, `.003`:

```bash
python scripts/art/unpack-meshy-volumes.py \
  --output /tmp/meshy-urban-explorer \
  <archive.7z.001> <archive.7z.002> <archive.7z.003>

blender --background --python scripts/art/inspect-meshy-urban.py -- \
  --source-zip /tmp/meshy-urban-explorer/extracted/Meshy_AI_Urban_Explorer_Character_Sheet_20261108_texture_fbx.zip \
  --output /tmp/meshy-urban-inspection
```

Chọn thư mục output mới cho bước ghép; công cụ từ chối ghi đè archive đã ghép. Inspector cũng hỗ trợ `--asset-dir <folder>` và `--fbx-name <filename>` để chọn chính xác model trong thư mục có nhiều FBX.

## Điều kiện trước khi dùng trong game

Bản gốc hơn 1.12 triệu triangles chưa được chấp nhận cho mobile. Cần retopology/LOD được kiểm tra silhouette, UV và chất lượng; skeleton/weights; animation đi bộ riêng; chỉnh tư thế và animation ngồi lái riêng nếu muốn làm rider. Việc đứng được trong ảnh không chứng minh có thể bẻ sang tư thế ngồi mà không lỗi.

Chưa import hoặc render bản này trong Unity, chưa kiểm tra GPU/FPS, chưa build Android/iOS và chưa xác minh quyền phát hành thương mại. Lượt kiểm tra này chỉ xác nhận cấu trúc và hình ảnh Blender của asset người dùng tải lên; không tạo rig, animation hay bản playable giả.
