# Cập nhật camera và vật liệu cho scene Unity đã tạo

Người dùng báo mặt đường chớp/phủ toàn màn hình **chỉ khi xe chạy**, ảnh minh họa ở khoảng mốc 141 và 65 km/h. Team chưa tái hiện bằng Unity Editor; không gọi hướng sửa source là kết quả đã hết lỗi trên máy người dùng.

## Cập nhật tại máy đang chạy Unity

1. Stop Play rồi đóng Editor trước khi cập nhật Git. Lưu hoặc commit các chỉnh sửa local của bạn, đặc biệt scene, `.meta`, Generated materials và project settings. Không dùng reset/clean để ép cập nhật.
2. Lấy thay đổi nhánh `codex-work` rồi mở đúng `unity/TravelVietnamese`. Chờ import/compile xong; nếu Console có lỗi đỏ, xử lý lỗi đầu tiên trước Play.
3. Mở scene `Assets/TravelVietnamese/Scenes/PassDemo.unity` đã tạo.
4. Chọn **TravelVietnamese → Update Scene Graphics**, rồi **Ctrl+S** để lưu scene. Không cần tạo lại scene hoặc xóa `Generated`/`Library`.
5. Play, chạy lại cùng đoạn đường, đặc biệt mốc 130–160, lên tốc độ trước đó; thử dừng xe, quay camera, lái qua cua và đổi chế độ xe/đi bộ.

Menu mới gán các material có texture vào trường `PassGame` của scene, tạo ở `Generated/GraphicsV2`, giữ asset vật liệu cũ. Camera source được dùng khi Play sau compile; menu đồ họa không phải thao tác bật/tắt camera fix. Không ghi vào journal hoặc thay ID của dấu khám phá. Nếu cần quay lại vật liệu cũ, có Undo trước khi đóng Editor và các asset cũ vẫn tồn tại; lưu scene trước cập nhật là cách giữ bản đối chiếu.

## Thay đổi source và phạm vi

- Camera cũ dò layer0 và không lọc hierarchy xe/nhân vật; source mới lọc cả hai actor, bỏ triggers, chọn vật cản world gần nhất và xử lý buffer query bão hòa. Khoảng sphere xét near clip/FOV/aspect; camera thu vào ngay khi bị chắn và hồi ra có giới hạn. Đó là các lỗi/rủi ro thấy được từ source, không chứng minh nguyên nhân duy nhất của symptom.
- Vật liệu cũ chỉ có màu/roughness; bootstrap giữ chúng nếu đã tồn tại, nên pull source không tự cập nhật scene đã tạo. Menu explicit mới gán material mới có albedo, tangent normal và mask smoothness; mesh thủ tục bổ sung tangents.
- Chín map 512×512 do `scripts/art/create-unity-surface-maps.py` tạo bằng NumPy/Pillow, seed cố định, không lấy ảnh tham chiếu, scan hoặc asset bên ngoài. Các file và checksum nằm trong `Art/SurfaceMaps/provenance.json`. Đây là PBR thủ tục nguyên gốc, **chưa đạt photoreal hoặc ảnh tham chiếu**. Shader/normal strength/tiling phải xem thực trong Unity rồi điều chỉnh.
- Bản HDRP desktop có cùng source camera và texture, nhưng Volume/lighting HDRP vẫn cần thiết lập riêng; không suy ra hiệu ứng sương HDRP từ fog URP.

Xem kết quả kiểm thực và phần chưa chạy tại [UNITY_VALIDATION.md](UNITY_VALIDATION.md). Nếu triệu chứng còn, cần video ngắn cùng đoạn trước/sau và thông tin camera/world hit để xác định tiếp; không tiếp tục đổi renderer hoặc engine để né lỗi.
