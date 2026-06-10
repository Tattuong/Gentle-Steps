# Bước Nhẹ (Gentle Steps)

Ứng dụng đếm bước chân mềm mại — dùng cảm biến có sẵn trên điện thoại, **không cần GPS**.

## Tính năng

- Đếm bước tự động qua accelerometer / step sensor
- Vòng tiến độ mục tiêu ngày với giao diện mềm mại
- Thống kê tuần, chuỗi ngày, quãng đường & calories
- Lịch sử theo tháng
- Nhắc nhở đi bộ
- Hỗ trợ widget màn hình chính
- Tiếng Việt & English, sáng/tối

## Chạy app

```bash
flutter pub get
flutter run
```

## Công nghệ

- Flutter + Provider
- `pedometer` — đếm bước từ sensor
- `permission_handler` — quyền hoạt động (Android)
- `home_widget` — đồng bộ dữ liệu widget
- `fl_chart` — biểu đồ tuần
