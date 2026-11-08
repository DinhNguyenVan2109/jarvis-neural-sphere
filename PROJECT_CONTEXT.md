# J.A.R.V.I.S. Neural Consciousness — Context & AI Session Handover
> **Tài liệu chuyển giao ngữ cảnh dự án (Session Handover & Continuity Context)**
> *Dành riêng cho Antigravity hoặc AI Agent khi người dùng tiếp tục làm việc trên máy ở nhà.*

---

## 1. Lịch sử đầy đủ của phiên làm việc trước

Toàn bộ lịch sử hội thoại từ đầu đến cuối đã được lưu trữ ngay trong repo này:
* **Đọc nhanh toàn bộ đối thoại (Markdown):** [`conversation_history/CONVERSATION_HISTORY.md`](./conversation_history/CONVERSATION_HISTORY.md) (Toàn bộ 22 Turns từ lúc phân tích ảnh mẫu *Age of Ultron*, viết đặc tả kỹ thuật, tối giản hóa UI, thiết kế lại giải phẫu bộ não Homeostatic Connectome cho đến khi nối trực tiếp vào Antigravity).
* **Dữ liệu bước thực thi nguyên bản (JSONL):** [`conversation_history/transcript_sanitized.jsonl`](./conversation_history/transcript_sanitized.jsonl) (Hơn 515 bước `USER_INPUT` và `PLANNER_RESPONSE` thực tế).

Khi người dùng mở workspace này ở nhà và yêu cầu tiếp tục, **hãy đọc file `PROJECT_CONTEXT.md` này và phần cuối của `conversation_history/CONVERSATION_HISTORY.md`** để nắm bắt ngay lập tức mạch công việc.

---

## 2. Những nguyên tắc cốt lõi mà người dùng đã chỉ rõ (Rất quan trọng!)

1. **Loại bỏ mọi chú thích "màu mè", thừa thãi trên UI:**
   - Không hiển thị các bảng HUD rườm rà, thanh 7 bước giả lập, các nút mẫu kịch bản giả hay nhật ký giả.
   - Giao diện chỉ giữ lại khối cầu 3D J.A.R.V.I.S., dòng trạng thái kết nối tối giản góc trên-trái, thanh nhập câu lệnh dưới đáy và nhãn mảnh (`hoverCard`) khi trỏ chuột vào từng vùng thần kinh.
2. **Giải phẫu bộ não phải hợp lý sinh học — Không phình to vô hạn (Bounded Homeostatic Connectome):**
   - Bộ não thật không mọc thêm một nhánh mới vĩnh viễn cho mỗi câu nói (như vậy não sẽ phình to đến phát nổ).
   - Thay vào đó, cấu trúc giải phẫu của J.A.R.V.I.S. gồm:
     - **Executive Core (`r = 0.08..0.18`):** Trung tâm suy luận của mô hình ngôn ngữ (LLM Planner).
     - **8-Slot Hippocampus Working Memory Ring (`r = 0.28..0.36`, `HIPPOCAMPUS_SLOTS`):** Vòng bộ nhớ làm việc ngắn hạn gồm 8 khe cố định. Các lượt hội thoại mới ghi xoay vòng vào 8 khe này, trong khi thông tin cũ được **củng cố (Synaptic Consolidation)** vào trọng số của các bó sợi vỏ não.
     - **7 Thùy Chức năng Vỏ não Cố định (`CORTICAL_REGIONS`):** Đại diện cho 7 năng lực thực tế của Antigravity (`Language & Reasoning`, `Perception & Read`, `Code Synthesis`, `Motor & Shell`, `Procedural Skills`, `Episodic Memory`, `Swarm & Search`).
     - **Log-Saturated Hebbian Plasticity:** Độ dày, độ sáng và xung nhịp của từng đường dẫn thần kinh tăng theo hàm logarit bão hòa dựa trên tần suất sử dụng thực tế trong phiên.
3. **Phải liên kết TRỰC TIẾP với chính Antigravity (Không làm giả / Không hardcode kịch bản):**
   - Khối cầu J.A.R.V.I.S. là hiện thân trực quan của chính Antigravity.
   - Daemon `jarvis-antigravity-bridge.ps1` đọc trực tiếp file `transcript.jsonl` của phiên Antigravity đang chạy (tự động tìm file `transcript.jsonl` mới nhất trong `$env:USERPROFILE\.gemini\antigravity\brain\*\ .system_generated\logs\transcript.jsonl`, hoặc fallback về `conversation_history\transcript_sanitized.jsonl`) và phục vụ JSON thời gian thực tại `http://127.0.0.1:18765/api/brain`.
   - Khi người dùng nhập lệnh vào ô dưới đáy J.A.R.V.I.S., lệnh được gửi qua `POST http://127.0.0.1:18765/api/prompt` -> lưu vào `pending_prompt.json` -> đánh thức script `wait-jarvis-prompt.ps1` để Antigravity xử lý bằng chính LLM đang chọn trong Antigravity.

---

## 3. Cách khôi phục phiên làm việc ngay lập tức trên máy ở nhà

Khi người dùng mở thư mục repo `jarvis-neural-sphere` trong Antigravity ở nhà, Agent cần thực hiện 2 lệnh nền sau để kích hoạt lại toàn bộ hệ thống:

1. **Khởi chạy Bridge Daemon (IsDaemon = true):**
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\jarvis-antigravity-bridge.ps1 -Port 18765
   ```
   *(Script sẽ tự động phát hiện file `transcript.jsonl` của cuộc trò chuyện mới trên máy ở nhà và đồng bộ trực tiếp lên khối cầu 3D!)*
2. **Khởi chạy Prompt Listener (tuỳ chọn khi người dùng muốn chat từ giao diện 3D):**
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\wait-jarvis-prompt.ps1
   ```
