# Kế Hoạch Triển Khai: Toàn Cảnh Hệ Thống Gamification & Flashcards

Tầm nhìn của bạn rất chính xác! Để Gamification (Streak & EP) phát huy tối đa sức mạnh, nó phải hiện diện khắp nơi trong App để liên tục "nhắc nhở" và "khoe" thành tích của người dùng. Dưới đây là bức tranh toàn cảnh về cách chúng ta sẽ triển khai:

## 1. Hệ Sinh Thái Gamification (Global System)
Điểm EP và Streak sẽ là "tài sản chung" của toàn bộ ứng dụng, không chỉ riêng phần Từ vựng. Chúng ta sẽ tạo một `GamificationProvider` để quản lý.

### 1.1. Trang Chủ (Home Screen)
- **Vị trí:** Ngay trên cùng (Top AppBar) của trang chủ.
- **Hiển thị:** Luôn hiện 2 thông số quan trọng nhất:
  - Ngọn lửa 🔥 + Số ngày Streak.
  - Ngôi sao 🌟 + Tổng điểm EP hiện tại.
- **Tác dụng:** Đập ngay vào mắt người dùng khi mở App, nhắc nhở họ "Hôm nay chưa học kìa, coi chừng mất Streak!".

### 1.2. Trang Cá Nhân (User Profile)
- **Tính năng mới:** Thêm một Tab hoặc Nút để vào Trang Cá Nhân.
- **Nội dung:** 
  - Avatar, Tên người dùng.
  - **Level (Cấp độ) và Danh hiệu** (VD: Level 5 - Chiến Thần TOEIC).
  - Biểu đồ thống kê số từ vựng đã học, số câu làm đúng.
  - Thanh tiến trình (Progress bar) cho biết cần bao nhiêu EP nữa để lên cấp tiếp theo.

### 1.3. Bảng Xếp Hạng (Leaderboard)
- **Tính năng mới:** Thêm một màn hình Xếp Hạng (có thể gắn ở thanh điều hướng dưới cùng - Bottom Navigation).
- **Nội dung:** Sắp xếp người dùng dựa trên điểm EP (Xếp hạng Tuần / Xếp hạng Tổng). 
- **Tác dụng:** Tạo sự cạnh tranh khốc liệt giữa các User (hệt như Duolingo).

---

- **Cơ chế EP đa dạng (Học là có điểm):**
  - Quẹt Flashcard (Đã thuộc): +5 EP/từ.
  - Trả lời đúng câu hỏi Practice: +10 EP/câu.
  - Hoàn thành 1 bài Test: +50 EP Bonus.
  - Xem giải thích chi tiết: +2 EP (Khuyến khích học kỹ).
- **Cơ chế Streak:**
  - Mục tiêu ngày (Daily Goal): Tích lũy đủ 50 EP để giữ Streak.
  - Hiệu ứng: Lửa Streak trên trang chủ sẽ bùng cháy khi đạt mục tiêu.

## 2. Tính Năng Lõi: Flashcard & Hệ thống Ôn tập (SRS)
Giải quyết vấn đề "từ chưa thuộc" và quản lý tiến trình học.

- **Thuật toán Spaced Repetition (SRS) đơn giản:**
  - **New (Mới):** Từ vừa mới gặp lần đầu.
  - **Learning (Đang học):** Từ quẹt trái (Chưa thuộc) hoặc mới thuộc 1 lần.
  - **Mastered (Đã thuộc):** Từ đã quẹt phải 3 lần ở các phiên học khác nhau.
- **Trang "Ôn Tập Hôm Nay":**
  - Tự động gom các từ `Learning` và các từ `Mastered` đã đến hạn ôn (ví dụ sau 3 ngày) vào một xấp bài riêng.
  - **EP Thưởng:** Ôn tập từ cũ sẽ được nhiều EP hơn học từ mới (khuyến khích ôn tập).

## 3. Tính Năng Sổ Tay (Personal Notebook) & Note
Giải quyết vấn đề "lưu từ hay/ghi chú".

- **Nút "Lưu vào Sổ tay" (Star icon):** Xuất hiện ở mọi nơi có từ vựng (Flashcard, List từ, Giải thích câu hỏi).
- **Trang Sổ tay:**
  - Hiển thị danh sách từ đã lưu.
  - **Ghi chú (Quick Note):** Cho phép User nhấn vào từ để gõ thêm câu ví dụ cá nhân hoặc mẹo nhớ.
  - **Mini-game Sổ tay:** Chỉ học flashcard dựa trên chính các từ User đã lưu.

---

## 3. Câu Hỏi Cốt Lõi Để Quyết Định Khung Hệ Thống

> **Đây là 2 quyết định mang tính "Sống còn" cho dự án, bạn hãy chốt kỹ nhé:**
> 
> 1. **Cơ Sở Dữ Liệu (Quan trọng nhất):** Vì bạn muốn có **Bảng Xếp Hạng (Leaderboard)**, chúng ta BẮT BUỘC phải lưu điểm EP lên Server (Backend/Firebase) thì các User mới so sánh điểm với nhau được. Nếu chỉ lưu Local (bộ nhớ máy) thì ai chơi máy nấy, không xếp hạng được. Bạn đã có sẵn Backend API cho việc lưu trữ user và điểm chưa?
> 2. **Thứ tự ưu tiên Code:** Hệ thống này khá lớn. Bạn muốn mình code cái **Flashcard Swipe** trước cho xong phần học thuật, hay muốn mình dựng cái **Khung UI Gamification** (hiện Streak trên Trang chủ, Trang Cá nhân, Bảng Xếp hạng) trước?
