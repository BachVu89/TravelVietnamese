# Chuyển Dọc miền Việt sang Unity 6 / C#

## Quyết định nền tảng và trạng thái

Yêu cầu mới chuyển sang Unity 6 và C#. Game vẫn cần chạy Android/iOS và offline. Dự án nguồn mới ở `unity/TravelVietnamese/`, ghim mục tiêu **Unity 6.0 LTS `6000.0.32f1`** và **URP `17.0.3`**. Đây là cặp phiên bản mục tiêu cho scaffold, chưa được Unity Editor/Package Manager xác minh trong môi trường này; không tự đổi phiên bản để bỏ qua lỗi tương thích. Không bịa revision hash hoặc package lock khi chưa resolve thực.

Môi trường không có Unity Editor. Hiện chưa import project, resolve packages, compile bằng Unity, tạo scene/material assets, build APK/IPA hoặc chạy trên thiết bị. Nếu kiểm tra riêng thuật toán C# bằng compiler ngoài Unity thì kết quả chỉ áp dụng phần domain đó, không chứng minh scene/physics/input/render hay IL2CPP chạy đúng.

Source UE trước đó được giữ như lịch sử phương án; APK Godot hiện có không bị gọi lại thành Unity. Không có Asset Store/Quixel/plugin được mua, tải hay cấp quyền sử dụng trong bước này. Các nguồn và điều kiện license hiện hành phải kiểm chứng trước khi thêm vào repository hoặc bản cài.

## HDRP và yêu cầu mobile

HDRP không hỗ trợ Android/iOS làm nền tảng phát hành của dự án này. Không chọn HDRP rồi quảng bá cùng project chạy trên mobile. Đường mobile dùng **URP**, chỉ có package URP trong manifest. Yêu cầu HDRP được tách thành một companion source project desktop riêng, tạo bằng `scripts/create-unity-hdrp-reference.py`, với scope và ngân sách phần cứng riêng. Không cài cả hai render pipeline trong project mobile hoặc giả rằng có thể chuyển runtime từ URP sang HDRP.

| Mục | Mobile Android/iOS | Desktop tùy chọn |
| --- | --- | --- |
| Pipeline | URP 17, cấu hình và shader mobile được kiểm chứng | Companion source project HDRP riêng; chưa import/compile/render |
| Hình ảnh | Asset được tối ưu, LOD/culling/instancing, ánh sáng phù hợp và hiệu ứng đường ẩm tiết kiệm | Có thể đánh giá hiệu ứng cao hơn cùng chi phí GPU/RAM |
| Ánh sáng | Baked/mixed hoặc realtime có ngân sách, phải đo thiết bị | Phương án desktop không suy ra chạy được trên điện thoại |
| Offline | Scene, mesh, texture, âm thanh, shader và dữ liệu cần thiết đi trong gói | Cùng nguyên tắc; không phụ thuộc tải asset khi chơi |
| C#/plugin | API Unity 6 và plugin đúng nền tảng; kiểm tra IL2CPP/AOT/stripping | Editor hoặc Mono chạy được không chứng minh mobile tương thích |

Nguồn tham khảo chính thức cho phạm vi HDRP: [Unity Graphics — System Requirements](https://raw.githubusercontent.com/Unity-Technologies/Graphics/master/Packages/com.unity.render-pipelines.high-definition/Documentation~/System-Requirements.md), được truy xuất ở nhánh `master`, liệt kê desktop/console và không hỗ trợ Android/iOS. Đây không phải bằng chứng đã resolve hoặc chạy package ghim `17.0.3`.

Các tuyên bố “đạt 95% ảnh”, “8 GB là đủ”, hoặc “cài plugin là nhanh chóng hoàn thiện” chưa được xác minh. Chất lượng phụ thuộc asset, kỹ thuật mỹ thuật, thời gian dựng cảnh và ngân sách thiết bị; RAM không phải thước đo duy nhất. Mục tiêu 30 FPS chưa có kết quả đo điện thoại. Chốt model thiết bị, độ phân giải, chất lượng hình ảnh, dung lượng gói và phiên chơi đo nhiệt trước khi cam kết.

## Manifest và input

`Packages/manifest.json` ghim URP `17.0.3`; các built-in modules gồm physics, legacy input, IMGUI, UI, audio và JsonUtility. Runtime hiện định hướng `UnityEngine.Input`; không yêu cầu package Input System mới hoặc asset/plugin điều khiển trả phí. Bootstrap cần đặt Active Input Handling phù hợp với legacy input và tạo/gán URP pipeline asset thực trong Graphics/Quality settings; manifest có URP chưa làm scene tự dùng URP.

`ProjectVersion.txt` chỉ ghim Editor version, chưa chứa revision đã xác minh. Sau lần mở thành công, kiểm tra và lưu lockfile do Unity tạo nếu phù hợp quy tắc repository; báo rõ bất kỳ thay đổi package version nào. Một package resolve thành công vẫn chưa chứng minh shader hoặc build target mobile hoạt động.

## Các giai đoạn và cổng nghiệm thu

1. **Mở scaffold:** có Unity Hub/Editor phiên bản ghim và entitlement/license phù hợp; resolve packages, compile không lỗi, bootstrap scene/URP, xác minh Main Camera, ánh sáng, input và collision. Không xem mã Editor C# là scene `.unity` đã tạo.
2. **Một đoạn đèo chơi được:** đường spline/procedural có collider, xe góc nhìn thứ ba, lái/phanh, traffic, điểm đỗ, xuống xe đi bộ và POI. Tách mô hình toán/quy tắc khỏi MonoBehaviour khi hợp lý để kiểm thử. Không tự nhận placeholder thành đèo Khánh Lê số hóa.
3. **Nâng mỹ thuật:** asset có quyền dùng, mesh LOD, terrain/vegetation có ngân sách, instancing, texture compression/LOD và lighting được bake/đo. Không thêm plugin Asset Store trước khi xác minh license, Unity 6/URP/mobile compatibility và kích thước gói.
4. **Build mobile và offline:** Android/iOS riêng, shader variants và nội dung được đưa đủ vào build; cài standalone rồi mở lạnh không mạng, chơi, lưu và phục hồi. Editor Game View/Device Simulator không thay điện thoại thật.
5. **Mở rộng địa phương:** registry 34 tỉnh/thành và dataset đảo không đồng nghĩa có cảnh Unity hoàn thiện cho từng mục. Chốt nguồn, coverage, độ chính xác và khả năng sản xuất trước rollout. Thêm địa phương theo cổng gameplay, art, licensing và profiling đã qua.

Chỉ nâng mức photoreal hoặc thêm mật độ rừng/traffic sau khi có một đoạn mẫu đáp ứng ngân sách; không mở rộng toàn quốc trước khi nghiệm thu đoạn mẫu.

## Build prerequisites và giới hạn hiện tại

- Unity 6 Editor đúng phiên bản, activation/license hợp lệ, Editor modules đúng target. Không tự đăng nhập, giả activation hoặc cài engine từ nguồn không được phép.
- Android: Android Build Support gồm SDK/NDK/OpenJDK tương thích với Unity version; SDK từ Godot/Expo không tự động được coi là phù hợp. Cấu hình package ID, ARM64/IL2CPP theo nhu cầu, texture format và signing theo kênh thử/phát hành. License và khóa ký được xử lý an toàn, không đưa secret vào source.
- iOS: iOS Build Support để export Xcode project; macOS/Xcode cùng Apple signing/provisioning cho build/cài/phân phối. Unity chạy trên Linux không chứng minh tạo hoặc ký được IPA.
- Offline: nhúng scene/data và mọi asset bắt buộc. Nếu dùng Addressables sau này thì bundle cần thiết phải local; chưa đưa Addressables hoặc tải nội dung vào đường chơi cốt lõi của scaffold.
- Dữ liệu sinh trong Editor cần bake/save trước build nếu thiết kế dựa vào nó; không để script `UnityEditor` lọt vào runtime assembly. Kiểm tra IL2CPP, linker/stripping và AOT cho C#/plugin trên thiết bị thật.

## Save và tiến trình giữa engine

Unity dùng save riêng có version tại `Application.persistentDataPath` hoặc cơ chế tương ứng được thiết kế rõ. Stable region/POI IDs có thể làm khóa import tương lai, nhưng tọa độ Godot, Unreal và Unity không được sao chép trực tiếp: khác trục, đơn vị, world geometry và collision. Giữ tệp cũ; import cần hành động rõ, validation, mapping version và checkpoint an toàn. Sandbox/app ID riêng cũng không tự truy cập dữ liệu app khác.

Giữ độc lập scope mobile/desktop và không suy ra APK Unity đã tồn tại từ artifact Godot. Bàn giao hiện tại là scaffold C# và tài liệu, chờ Editor/toolchain để qua cổng import/compile/build thực.

## Companion HDRP desktop và các entrypoint cụ thể

`scripts/create-unity-hdrp-reference.py` tạo companion desktop từ runtime C# dùng chung và ba FBX nguyên gốc của project URP. Companion ghim Editor `6000.0.32f1` và HDRP `17.0.3`; package/project resolution chưa được Editor kiểm chứng. Generator không mang Editor bootstrap URP sang project HDRP. Shared runtime không chứa phụ thuộc API HDRP; renderer assets và Editor setup tách riêng. FBX nguyên gốc không đồng nghĩa đã có asset mỹ thuật photoreal hoặc mọi importer đã chạy thành công.

Bootstrap desktop yêu cầu người dùng mở Editor, chạy **HDRP Wizard** và cấu hình/gán pipeline asset HDRP trước. Guard từ chối tiếp tục khi pipeline chưa sẵn sàng, thay vì tự coi manifest HDRP là renderer đã hoạt động. Sau đó mới tạo scene/build desktop theo entrypoint của companion. Không có camera render, screenshot, material conversion hay bản build HDRP được chứng minh trong môi trường hiện tại.

Mobile vẫn mở `unity/TravelVietnamese`, không mở companion để build Android/iOS. Lệnh mobile từ gốc repository:

```bash
python scripts/build-unity.py --editor /path/to/Unity --target scene --check-only
python scripts/build-unity.py --editor /path/to/Unity --target scene
python scripts/build-unity.py --editor /path/to/Unity --target android
```

`scene` gọi `TravelVietnamese.Editor.PassProjectSetup.CreateMobilePass`; `android` gọi `BuildAndroid` và chọn target Android. `--check-only` chỉ kiểm tra entrypoint/project tồn tại, không xác minh Editor version, activation, package, modules, compile hoặc thiết bị. Thiếu executable trả exit code 2, không build.

Kiểm tra domain C# riêng đã chạy 60 checks đạt bằng .NET; không phải Unity compile hoặc Engine tests. Máy hiện thiếu Editor và request tới domain tải Unity chính thức bị proxy từ chối CONNECT 403. Điều đó chặn cài/chạy Editor trong môi trường này; không giả định quyền license, không dùng nguồn tải thay thế để vượt chính sách. Chưa có APK/IPA Unity hoặc kết quả HDRP desktop để đánh giá tỷ lệ giống ảnh.

Companion đã được tạo tại `unity/TravelVietnamese-HDRP/`; bootstrap desktop riêng là `TravelVietnamese.Editor.DesktopPassSetup.CreateDesktopPass`. Sau khi cấu hình HDRP Wizard trong Editor, gọi `python scripts/build-unity.py --editor /path/to/Unity --profile hdrp --target scene`. Đây là tạo scene, chưa phải build player desktop. Wrapper từ chối `--profile hdrp --target android`.

Generator không ghi đè project tồn tại. Dùng `--output` khác khi cập nhật, review diff và giữ nội dung artist đã tạo; `--verify` chỉ so sánh shared runtime/FBX. Sky/fog/clouds của HDRP cần global Volume đúng pipeline, không dựa vào legacy `RenderSettings.fog`. Không có pipeline asset/scene đã tạo hay render HDRP được chứng minh bằng việc source companion tồn tại.
