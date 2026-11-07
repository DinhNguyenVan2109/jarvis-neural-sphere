# J.A.R.V.I.S. — 3D Neural Consciousness Interface
> **Avengers: Age of Ultron Hologram Replica & Interactive Agent Process Visualizer**

Hệ thống mô phỏng thực thể ý thức số 3D Hologram **J.A.R.V.I.S.** nguyên bản (thiết kế bởi *Animal Logic* trong *Avengers: Age of Ultron*), được xây dựng hoàn toàn bằng **thuần WebGL 1.0 (Zero Dependencies)** kết hợp công cụ trực quan hóa tiến trình nhận thức của AI Agent theo thời gian thực.

![J.A.R.V.I.S. Reference](assets/references/reference_sphere_overview.jpg)

---

## ✦ Điểm nổi bật & Tính năng kỹ thuật

### 1. Cấu trúc hình học (Bio-organic Liquid Neural Topology)
* **Lõi trung tâm (Volumetric Point-Cloud Core):** Vòng sáng rực rỡ (`#FFF0AA` / `#FFBF00`) với tâm đồng tử rỗng tối và vệt lóe sáng chéo ở viền dưới, bao quanh bởi đám mây phân tử siêu nhỏ tự phân rã và tái tụ, lồng trụ vi mạch và các vành khung chữ C 3D.
* **Mạng lưới liên kết chính (Catmull-Rom Neural Splines):** Các bó sợi trục bất đối xứng tỏa ra từ lõi, kết hợp các nhánh xung điện gai nhọn (`Dendrites/Mycelium`) có độ dày biến thiên và thắt nút tại các `Synaptic Nodes`.
* **Vỏ cầu vi mạch 3D (Tilted Concentric Truss Shells):** 5 lớp vỏ cầu nghiêng đa trục với hệ thống răng lược (`Comb Teeth`) và đường mạch bậc thang (`Stepped Circuitry`).
* **Không gian âm (Negative Space):** Bảo tồn ~60% khoảng rỗng tối bên trong khối cầu để tạo chiều sâu lập thể nhìn xuyên thấu (`Translucent Additive Blending`).

### 2. Động lực học & Chuyển động (Dynamics & Animation)
* **Nhịp thở sinh học 4D (Organic Pulsation):** Co bóp nhịp nhàng theo trường sóng 4D Simplex/Perlin tần số thấp với biên độ $\pm 12-15\%$ bán kính.
* **Xoay đa trục lệch pha (Asynchronous Rotation):** 5 lớp vỏ bọc độc lập xoay chậm theo các trục $(X, Y, Z)$ với tốc độ khác nhau.
* **Dòng chảy photon tầng (Laminar Data Streams):** 1.350 hạt dữ liệu trượt mượt mà dọc theo các đường cong spline từ tâm ra ngoài và ngược lại.
* **Tương tác trực tiếp:** Hỗ trợ xoay $360^\circ$ bằng chuột/cảm ứng, lăn chuột để zoom, kích thích tần số nơ-ron khi rê chuột gần tâm.

### 3. Cỗ máy trực quan hóa tiến trình (7-Stage Live Agent Process)
Khối cầu phản ứng trực tiếp theo 7 pha nhận thức thực tế của Agent:
1. **`1. Standby`:** Nhận thức thụ động, thở nhẹ ($42\text{ Hz}$).
2. **`2. Ingest`:** Sóng hạt đảo chiều đổ dồn từ ngoài vào Lõi, lõi bừng sáng trắng hấp thụ yêu cầu.
3. **`3. Route`:** Tần số tăng lên $86\text{ Hz}$, các sợi trục phát xung định hướng phân rã bài toán.
4. **`4. Skill`:** Vành đai vi mạch xoay vào tiêu cự, kích hoạt kỹ năng chuyên sâu (`heat = 1.6`, tốc độ dòng chảy $3.6\text{ c}$).
5. **`5. Parallel`:** Kích hoạt đồng thời 2 bán cầu đối xứng mô phỏng Subagents song song, trao đổi tín hiệu chéo.
6. **`6. Verify`:** Sóng hài hòa kiểm định TDD quét qua khối cầu xác nhận không có lỗi ($100\%$ Coherence).
7. **`7. Synthesis`:** Dòng năng lượng hội tụ về Lõi, phát âm thanh thấu kính và hiển thị báo cáo tổng hợp.

### 4. Hiệu ứng thấu kính & Âm thanh (Optics & Audio)
* **Multi-Scale Gaussian Bloom:** Ánh sáng phát xạ thể tích (`Volumetric Emission`) với hào quang cam ấm và neon vàng.
* **Optical Depth-of-Field (DoF Bokeh):** Các sợi và hạt nằm ngoài mặt phẳng lấy nét tự động nhòe thành các đốm bokeh tròn mịn.
* **Radial Chromatic Aberration:** Tách nhẹ dải màu Đỏ/Lam ở rìa các sợi mỏng.
* **Procedural Web Audio SFX:** Tổng hợp trực tiếp qua Web Audio API (âm nền $55\text{ Hz}$, tiếng quét thấu kính, hợp âm hoàn tất; có nút Mute/Unmute).

---

## 🚀 Hướng dẫn khởi chạy

Dự án không có bất kỳ thư viện ngoài nào (không cần `npm install` hay build tool):
* **Cách 1:** Mở trực tiếp file `index.html` bằng bất kỳ trình duyệt hiện đại nào (Chrome, Edge, Firefox, Safari).
* **Cách 2:** Sử dụng local server nếu muốn (ví dụ: `npx serve .` hoặc VS Code Live Server).

---

## 🌐 Hướng dẫn đẩy lên GitHub Repository

Để tiếp tục làm việc trên máy khác hoặc chia sẻ:

```bash
# 1. Khởi tạo Git repo (nếu chưa có)
git init
git add .
git commit -m "feat: initial commit of J.A.R.V.I.S. 3D Neural Consciousness Interface"

# 2. Tạo một repository mới trên GitHub (ví dụ: jarvis-neural-sphere)
# 3. Liên kết remote và đẩy code lên:
git remote add origin https://github.com/<YOUR_USERNAME>/jarvis-neural-sphere.git
git branch -M main
git push -u origin main
```

---

## 📁 Cấu trúc thư mục

```text
jarvis-neural-sphere/
├── index.html                 # Ứng dụng WebGL 3D Hologram hoàn chỉnh
├── README.md                  # Tài liệu hướng dẫn sử dụng & kiến trúc
├── PROJECT_CONTEXT.md         # Bối cảnh & đặc tả chi tiết để AI tiếp tục cuộc trò chuyện
├── .gitignore                 # Cấu hình bỏ qua các file tạm
└── assets/
    └── references/            # Ảnh mẫu gốc J.A.R.V.I.S. từ phim
        ├── reference_sphere_overview.jpg
        └── reference_core_detail.jpg
```
