# Hướng Dẫn Cấu Hình Kết Nối API Backend Cho Team

Để tránh việc mỗi người trong team khi tải code về phải tự sửa đổi (hardcode) địa chỉ IP trong source code gây ra lỗi **Conflict** trên Git, dự án đã được chuyển sang sử dụng biến môi trường thông qua file `.env`.

Dưới đây là các bước bắt buộc để chạy app mà không bị lỗi kết nối:

## Bước 1: Cập nhật thư viện
Sau khi `git pull` code mới nhất về, hãy mở Terminal (tại thư mục `toeic-mobile-app`) và chạy lệnh sau để tải các package mới:
```bash
flutter pub get
```

## Bước 2: Tạo file `.env`
1. Ngay tại thư mục gốc của app (`toeic-mobile-app`), tạo một file mới và đặt tên là **`.env`** (Lưu ý: Bắt buộc phải có dấu chấm ở đầu).
2. Bạn cũng có thể copy file `.env.example` có sẵn trong thư mục, paste ra và đổi tên bản sao đó thành `.env`.

> [!NOTE]
> File `.env` này đã được cấu hình trong `.gitignore`. Nó sẽ chỉ nằm cục bộ trên máy tính của bạn và **không bao giờ bị đẩy lên Git**. Do đó, bạn có thể thoải mái thay đổi IP theo máy của mình mà không sợ ảnh hưởng đến người khác.

## Bước 3: Cấu hình địa chỉ IP
Mở file `.env` vừa tạo và dán cấu hình sau vào:

```env
API_BASE_URL=http://<IP_MÁY_CỦA_BẠN>:5133/api
```

### Cách chọn IP phù hợp:

- **Nếu bạn test bằng điện thoại thật (cắm cáp USB):**
  Bạn phải lấy địa chỉ IPv4 LAN của máy tính đang chạy Backend (Ví dụ: `192.168.1.15`).
  *Cấu hình mẫu:* `API_BASE_URL=http://192.168.1.15:5133/api`

- **Nếu bạn test bằng máy ảo Android (Emulator):**
  Máy ảo Android tự hiểu máy tính của bạn qua IP `10.0.2.2`.
  *Cấu hình mẫu:* `API_BASE_URL=http://10.0.2.2:5133/api`

- **Nếu bạn test bằng máy ảo iOS (Simulator) hoặc Web:**
  *Cấu hình mẫu:* `API_BASE_URL=http://127.0.0.1:5133/api`

## Bước 4: Chạy App
Sau khi lưu file `.env`, bạn chỉ cần chạy app như bình thường (ví dụ: `flutter run`). App sẽ tự động đọc địa chỉ IP mà bạn đã thiết lập để kết nối tới Backend.
