# Meshy Mountain Jungle — tiếp nhận dữ liệu nguồn

## Kết quả kiểm tra

Đã tải đủ 14 volume người dùng cung cấp, theo batch tối đa 4 tệp; giữ nguyên bản tải. Ghép thứ tự số `.001`–`.014`, giải 7z bằng `scripts/art/unpack-meshy-volumes.py` (system libarchive), rồi kiểm tra và giải ZIP lồng bằng Python zipfile. Kiểm tra tên entry, đường dẫn tuyệt đối/traversal, link/special file, kích thước và đọc tới EOF để kiểm CRC ZIP. Không chạy nội dung archive.

Kết quả: **1 FBX và 4 PNG**, tổng dữ liệu nguồn 349,009,293 bytes. FBX 337,994,060 bytes (~322.3 MiB); topology được đo ở phần inspection sau intake. Scale thực địa và chất lượng topology/deformation vẫn chưa được xác minh. Mọi PNG có IHDR 2048 × 2048, 8 bit. Tên cho thấy base color/metallic/normal/roughness; ý nghĩa kênh và hướng normal chưa được renderer kiểm chứng.

**Mốc intake ban đầu:** đã dừng sau extract/listing, chưa chạy Blender. Sau đó root cho phép đúng một job Blender có giới hạn mẫu/độ phân giải; kết quả ở phần inspection bên dưới. Chưa decimate, tạo LOD/collider, đưa FBX lớn vào Unity hoặc commit. Không coi kích thước nén hoặc texture 2K là chứng minh asset phù hợp mobile.

## Staging và bảo toàn

- Thư mục tạm: `/tmp/meshy-mountain-jungle/`.
- `downloads.json`: số part, uploaded file ID và đường dẫn bản tải nguyên gốc.
- `parts.json`: tên/bytes/SHA256 từng volume và hash archive ghép.
- `joined.7z`: bản ghép giữ nguyên, không thay bản gốc.
- `extracted/`: ZIP nguyên bản bên trong 7z (349,011,057 bytes).
- `nested-zip-files.json`: directory listing của ZIP trước giải.
- `content/`: 1 FBX và 4 PNG được giải, giữ tên nguồn.
- `content-manifest.json`: file size/hash và PNG header metadata.

Staging `/tmp` có thể mất khi môi trường thay; bảng hash dưới đây là bằng chứng nhận diện trong repository, không thay file nguồn. Đường dẫn gốc asset trong `content/` là `Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture_fbx/`.

Archive ghép SHA256: `3ca53c71566ec5f1e813e86d0cebbf311a7ef7ded08233e2d31eaac563504c99`.

ZIP gốc bên trong SHA256: `d433d29b9b73714e08f89bbd525a7fbde53ee8ce4e4c8e3230822ca123a6ba0d`.

## File nguồn

| Tên file (trong asset folder) | Bytes | PNG | SHA256 |
| --- | ---: | --- | --- |
| Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture.fbx | 337994060 | — | `45149c3f65da45f92c464b72d663df571e81d6d4a655f9303e4b0d6a3eb8c786` |
| Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture.png | 4532274 | 2048×2048, color type 2 | `0c5ea78cdd131f69379419be4b7f7996475628b5c7124d1b63d304212591a603` |
| Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture_metallic.png | 46582 | 2048×2048, color type 0 | `3b2fef1a02febca084f8448819c972e3d85518007fb107285e963d99b8ca18bc` |
| Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture_normal.png | 4676484 | 2048×2048, color type 2 | `5d20f9cd935657ec14bf1de765a70b44fd7ec5a969ccddf0ed6557cf384cfba8` |
| Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture_roughness.png | 1759893 | 2048×2048, color type 0 | `915d5f78fba4240ea08339e1d188730dacd91f7f464a34a91c0347a9d0b1d28b` |

PNG color type 2 = RGB; type 0 = grayscale theo IHDR. Header metadata chưa thay cho kiểm tra hình ảnh hoặc color-space/import settings.

## Manifest 14 volume

Cùng tiền tố `Meshy_AI_Mist_Shrouded_Mountain_Jungle_Asset_20261108_texture_fbx_2.7z`.

| Part | Uploaded ID | Bytes | SHA256 |
| --- | --- | ---: | --- |
| 001 | `file_000000001a5882099b34a142c8ad9c76` | 25165824 | `5ba224ac9129f27952eb767deab45dc326fff994bf2767cbea294e2c333dab09` |
| 002 | `file_000000008cdc8212a372529c84c6c744` | 25165824 | `f54fef23ea635c308112e302590c1501c582297568725218a145345b2f8da480` |
| 003 | `file_0000000064e08209a6e07c29b37137a9` | 25165824 | `71fae6465c13c3c627c1c46ee49a9bbb8f2d9deda536d242320342e2ea9e2eea` |
| 004 | `file_00000000e3408209993bc0eba80cc5c7` | 25165824 | `de6b5eb06b50a026c12538c0fd655ee7a27f9b320383e38399a21c47d1ec7145` |
| 005 | `file_0000000056ac8209949728569fbd595b` | 25165824 | `0727e9a118695063321b90c803ef1b7fc12e254d7a7ff177ef81570a14c3458f` |
| 006 | `file_00000000d74882099f5a57865e9a4bba` | 25165824 | `c0dcf390c6e5531c72e6ea8a6a6b052356ea5dab85afd056f411625033b24a2e` |
| 007 | `file_00000000fbd882119af0a6a1b79da010` | 25165824 | `d4737d6ee027ed66dfc13828e92e32ea2e0134a8a7b1a7d8f6e9e58aa36fd446` |
| 008 | `file_000000009b9081f8a1b49cb82919882f` | 25165824 | `e321fd76ee2ce5b4ab98c6fc18071c2b2acec1ee957c33c0ecb13d5a4aa03802` |
| 009 | `file_00000000dab88209b1d127252a4f59f6` | 25165824 | `d3488d0c5b9285ae741f64c6962311941f86aa0f369f1c86445f2c3dc351e063` |
| 010 | `file_0000000019f48209ac6fe3b43c2f5d4c` | 25165824 | `e121f5ff22d88d2f919e46add2cecf90854e89f9a230fde557bbde4337842dde` |
| 011 | `file_0000000014448230b83a9e225d6c7af3` | 25165824 | `b25b9a996f45fb303c73c8430249e212631ec61335092503031cfecf28af7881` |
| 012 | `file_000000000d5081f88d30b27c0e523c24` | 25165824 | `a582320cc807e561cfc92ba40a849a302074459ec5a208db235abed5c174601f` |
| 013 | `file_0000000052e48209bd4120a19c846d58` | 25165824 | `3ab773ed31c0db57a5b743597ea632b1287ed86df25ed88df7a7a3657435238d` |
| 014 | `file_00000000eda482099554f295df8f828f` | 4366936 | `b0c0c05487662c749d37ec565c639d2802fbec5d36150613c0f25d4162fbbf55` |

## License và bước tiếp theo

Đây là tài nguyên người dùng upload; không có license/attribution document trong 5 file được giải. Quyền sử dụng/phân phối và điều kiện Meshy của tài khoản tạo asset chưa được chứng minh chỉ từ tên file. Không kết luận asset bị cấm hoặc đã được cấp license đầy đủ. Trước phát hành, lưu bằng chứng quyền sử dụng phù hợp.

Bước kế tiếp do root điều phối sau inspection: quyết định trích riêng từng chunk, kiểm scale/orientation/material trong Unity và tạo LOD với so sánh hình ảnh, không đưa thẳng nguyên layout vào cảnh. Chưa đề xuất đưa nguyên FBX 322 MiB vào APK mobile hoặc coi asset là toàn bộ một địa phương địa lý thực.

## Inspection Blender thực tế sau khi được điều phối RAM

Đã hoàn thành **một** process Blender 4.3.2, CPU Cycles, 4 threads, 8 samples, 700×700, không denoise; process thoát exit 0 và giải phóng RAM trước khi giao slot job nặng cho asset khác. Script tái lập: `scripts/art/inspect-meshy-jungle.py`. Không lưu `.blend`, sửa/reexport FBX, tạo LOD hoặc tích hợp Unity trong job này. SHA256 FBX sau render trùng nguồn.

- [Front Blender](meshy-mountain-jungle-front-blender.png)
- [Reverse Blender](meshy-mountain-jungle-reverse-blender.png)
- [Top Blender](meshy-mountain-jungle-top-blender.png)
- [Report JSON](meshy-mountain-jungle-inspection.json)

Đây là render kiểm tra **Blender**, không phải screenshot Unity/HDRP/URP, không chứng minh hiệu năng hay chất lượng bản cài mobile.

| Thuộc tính đo | Kết quả |
| --- | --- |
| Mesh object | Một object `Mesh_0` |
| Vertices | 3,864,148 |
| Polygons / triangles | **7,746,512 / 7,746,512** |
| UV / material slot | Một `UVMap` / một `Material.001` |
| Armatures / actions / modifiers | Không / không / không |
| Vertex groups / shape keys | Không / không |
| Bounds min XYZ | −0.952102, −0.908874, −0.184101 |
| Bounds max XYZ | +0.946012, +0.910348, +0.167517 |
| Dimensions XYZ | 1.898114 × 1.819222 × 0.351618 Blender importer world units |
| Location / scale | 0 / 1 |

### Phân loại hình học và cách dùng hợp lý

Ba góc nhìn cho thấy **ba khối diorama rừng–vách đá–đế nền tách rời về hình ảnh, được bố trí cùng nhau trong một object/material**. Có một mảng lớn gần hình chữ nhật, một mảng rừng khác và một dải dài hẹp. Đây không phải một địa hình liên tục, không phải bộ cây/đá riêng có thể đặt từng prop; muốn dùng modular phải trích/chia chunk thành derivative riêng. Chưa chạy phân tích connected components nên không đồng nhất số khối nhìn thấy với số island topology chính xác.

Tán cây và vách/đế có thể tích thấy rõ từ mặt trước, mặt sau và trên cao: **không phải một poster phẳng**. Tuy vậy, đây cũng không phải một khu rừng/đèo hoàn chỉnh cho người chơi tự đi vào. Các cây, tầng lá, đá và nền có hình dạng AI hợp khối, không có tree hierarchy/collider hoặc walkable terrain được cung cấp. Cần xem kỹ artefact và ranh giới đế cắt trước khi đặt gần camera.

Upright khoảng **Blender +Z**, mặt nền nằm gần XY, phía đáy quanh Z=−0.1841; pivot gần tâm cả layout, không phải ground pivot của từng chunk. Không có một hướng front chung cho cả bộ ba; nhãn front/reverse chỉ là vị trí camera kiểm tra. Không áp scale trực tiếp theo metres ngoài đời; dựng wrapper bằng Renderer bounds Unity sau import và đối chiếu scene.

**Có thể cân nhắc làm decorative forest/cliff chunks bên ngoài đường lái**, sau khi tách từng mảng, tối ưu mesh/LOD và kiểm material. Không dùng nguyên layout gồm ba mảng để thay `CoreRoad`, collision, biên làn, POI hoặc nền gameplay. 7.75 triệu tam giác cho một object là nguồn high-poly, chưa đạt điều kiện mobile; việc texture chỉ 2K không giảm chi phí hình học đó. Chưa có derivative tối ưu hoặc asset đã sẵn sàng đưa vào APK.

### Map và giới hạn render

Render gán rõ bốn PNG nguồn: base color sRGB; metallic, roughness và normal Non-Color; normal qua Blender NormalMap node. FBX material ban đầu tham chiếu `.fbm/Image_0.jpg`, `.fbm/Image_2.jpg` và các map nhúng. Unity cần remap explicit PNG, không dựa vào các đường dẫn `.fbm` sinh khi import. Hướng green channel tangent normal chưa được xác minh trên Unity. Roughness phải chuyển theo smoothness/packed-channel của material Unity nếu dùng, không cắm trực tiếp vào smoothness hoặc ghi đè PNG gốc.

Ánh sáng studio 8 samples dùng để nhận diện cấu trúc, không đánh giá màu/độ ẩm cuối. Chưa kiểm manifold, self-intersection, tessellation density, texel density từng chunk hoặc khả năng decimate giữ lá. Các bước đó và license/Unity import/mobile profiling vẫn còn trước khi phát hành.
