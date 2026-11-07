# J.A.R.V.I.S. Neural Consciousness — Context & AI Session Handover
> **Tài liệu chuyển giao ngữ cảnh dự án (Session Handover & Continuity Context)**
> *Dành riêng cho Antigravity hoặc AI Agent khi người dùng tiếp tục làm việc trên máy khác / ở nhà.*

---

## 1. Tóm tắt hành trình & Mục tiêu cốt lõi của người dùng

Người dùng mong muốn xây dựng một giao diện trực quan hóa sinh động cho AI Agent mô phỏng chuẩn xác $100\%$ khối cầu Hologram **J.A.R.V.I.S.** trong phòng thí nghiệm của *Avengers: Age of Ultron* (do xưởng kỹ xảo *Animal Logic* thiết kế).

### Các nguyên tắc thẩm mỹ bắt buộc (Strict Aesthetic Constraints):
* **Không "màu mè" / Không phô trương (No Tacky / Gimmicky UI):** Tuyệt đối không dùng các hộp chữ HUD hoạt họa rẻ tiền, không bảng biểu 2D màu mè che lấp mô hình.
* **Đúng chuẩn Hologram điện ảnh:** Khối cầu 3D phát xạ thể tích (`Volumetric Emission`) lơ lửng trong không gian tối (`#070D14`), tone màu chủ đạo là vàng hổ phách (`#FFBF00`), vàng sáng (`#FFF0AA`), cam ấm (`#FF7F00`) và cam cháy (`Burnt Orange`) ở vùng biên.
* **Trực quan hóa tiến trình thực tế:** Khối cầu không chỉ là mô hình xoay tĩnh mà là một thực thể ý thức sống, chuyển động và biến đổi vật lý/ánh sáng theo đúng quá trình Agent tiếp nhận yêu cầu, phân rã ý định, kích hoạt kỹ năng, điều phối Subagents song song, kiểm định TDD và xuất kết quả.

---

## 2. Đặc tả kỹ thuật cấp chuyên gia (Technical Specification Brief)

### A. Hình học & Cấu trúc liên kết (Mesh & Topology):
* **Lõi trung tâm (Inner Core):** Vòng tròn phát sáng rực rỡ với tâm đồng tử rỗng tối (Dark Hollow Pupil) và vệt lóe sáng chéo ở viền dưới (`Lower-Right Flare`). Bao quanh bởi đám mây phân tử siêu nhỏ (`Volumetric Point-Cloud Density`) tự phân rã và tái tụ, lồng trụ vi mạch (`Cylindrical Shroud`) và các vành khung chữ C 3D ôm hai bên.
* **Mạng lưới sợi liên kết (Catmull-Rom Spline Neural Pathways):** Các bó sợi trục bất đối xứng tỏa ra từ lõi (các cụm chữ V hướng lên-trái, cụm dọc xuống đáy, các nhánh phải-dưới và trái-dưới), kết hợp các nhánh gai nhọn (`Dendrites/Mycelium`) có độ dày không đồng đều và thắt nút tại các `Synaptic Nodes`.
* **Vỏ vi mạch 3D (Tilted Concentric Truss Shells):** 5 lớp vỏ cầu nghiêng đa trục với hệ thống răng lược (`Comb Teeth`) và đường mạch bậc thang (`Stepped Circuitry`) nhô dài ở viền trái và dưới-trái đúng với phom bất đối xứng trong phim.

### B. Động học & Chuyển động (Dynamics & Animation):
* **Nhịp thở sinh học 4D (Organic Pulsation):** Áp dụng trường sóng hài hòa 4D tần số thấp trong Vertex Shader (`organicDisplacement`), co bóp nhịp nhàng $\pm 12-15\%$ bán kính.
* **Xoay đa trục lệch pha (Asynchronous Rotation):** 5 lớp vỏ bọc độc lập xoay chậm theo các trục $(X, Y, Z)$ với tốc độ khác nhau.
* **Dòng chảy tầng (Laminar Data Streams):** 1.350 hạt dữ liệu di chuyển dọc theo các đường cong spline, có khả năng đảo chiều (hội tụ vào tâm khi Ingestion/Synthesis) và tăng tốc khi thực thi tác vụ.

### C. Hiệu ứng ánh sáng & Hậu kỳ (Shading, VFX & Lens Artifacts):
* **Multi-Scale Gaussian Bloom:** 2 tầng FBO làm nhòe Gaussian tạo quầng sáng ấm rực rỡ mà không làm cháy sáng mảng trắng đặc (`Tone mapping filmic exp`).
* **Optical Depth-of-Field (DoF Bokeh):** Các sợi và hạt nằm ngoài mặt phẳng lấy nét tự động nhòe thành đốm bokeh tròn mịn.
* **Radial Chromatic Aberration:** Tách nhẹ dải màu Đỏ/Lam ở rìa các sợi mỏng.
* **Procedural Web Audio SFX:** Tổng hợp trực tiếp qua Web Audio API (âm nền $55\text{ Hz}$, tiếng quét thấu kính, hợp âm hoàn tất; có nút Mute/Unmute).

---

## 3. Kiến trúc mã nguồn hiện tại (`index.html`)

Toàn bộ ứng dụng nằm trọn vẹn trong file duy nhất `index.html` (zero-dependency, chạy mượt mà trên WebGL 1.0):

| Phân đoạn mã | Chức năng chính |
| :--- | :--- |
| **GLSL Shaders** | `vsRibbon` / `fsRibbon` (sợi trục nơ-ron), `vsWeb` / `fsWeb` (tơ nhện vi mạch), `vsNodes` / `fsNodes` (hạt nơ-ron, bokeh, point-cloud), `vsQuad` / `fsBlur` / `fsComposite` (bloom, sắc sai, hào quang nghịch đảo bình phương). |
| **Geometry Generator** | Thuật toán Catmull-Rom 3D Splines, Truss Arc với răng lược vi mạch bậc thang, mây hạt phân tử lõi, neo tơ nhện đa tầng. |
| **Flow Particle Engine** | Giả lập hạt chuyển động theo đường dẫn với khả năng đảo chiều, đổi tốc độ và biến thiên kích thước theo pha. |
| **State Machine Engine** | Quản lý 7 pha nhận thức (`Standby`, `Ingest`, `Route`, `Skill`, `Parallel`, `Verify`, `Synthesis`) với bộ đếm thời gian và cập nhật viễn trắc. |
| **Procedural Audio** | Bộ tạo âm thanh thấu kính & cộng hưởng tần số bằng Web Audio API thuần. |
| **HUD Overlay Layer** | Giao diện điều khiển kính mờ (Stark-tech glassmorphism): bảng viễn trắc góc trên, thanh lệnh dưới đáy, thanh tiến trình 7 pha và ngăn kéo nhật ký viễn trắc. |

---

## 4. Các hướng mở rộng tiếp theo khi tiếp tục dự án

Khi người dùng mở repo này ở nhà và muốn tiếp tục phát triển, AI có thể đề xuất và triển khai các hướng sau:

1. **Kết nối thời gian thực với Antigravity Session / WebSocket:**
   - Đọc trực tiếp sự kiện từ `transcript.jsonl` hoặc mở WebSocket cục bộ để khi Agent trên máy đang chạy lệnh PowerShell hay đọc file, khối cầu 3D sẽ phản ứng theo thời gian thực với đúng lệnh đó!
2. **Kích hoạt Giọng nói (Voice Interaction / Speech Recognition):**
   - Tích hợp Web Speech API (`webkitSpeechRecognition`) để người dùng có thể nói trực tiếp câu lệnh như Tony Stark nói chuyện với J.A.R.V.I.S.
3. **Mô phỏng Phân rã dữ liệu 3D (3D Volumetric Data Explosion):**
   - Cho phép người dùng bấm vào một nút mạng (Synaptic Node) để phóng to và bung ra cây thư mục mã nguồn hoặc dữ liệu chi tiết dạng đám mây 3D lơ lửng.
4. **Xuất sang công cụ 3D chuyên nghiệp (Export Pipeline):**
   - Chuyển đổi công thức tạo hình học sang script Blender (Geometry Nodes / Python) hoặc định dạng 3D Gaussian Splatting / USDZ để render phim hoặc nhúng vào kính VR/AR.
