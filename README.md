Dưới đây là bản `README.md` đầy đủ, liền mạch, không sử dụng các ký hiệu định dạng như \*\*, phù hợp để nộp báo cáo hoặc chia sẻ GitHub một cách chuyên nghiệp và rõ ràng.

---

# HoaLaHe Laptop & Accessories Store App

Ứng dụng HoaLaHe là một hệ thống thương mại điện tử đa nền tảng (mobile và web) phát triển bằng Flutter. Ứng dụng cho phép người dùng tìm kiếm, xem chi tiết và đặt mua các sản phẩm laptop và linh kiện điện tử. Phía quản trị viên có thể quản lý sản phẩm, danh mục, đơn hàng và người dùng. Dự án áp dụng kiến trúc Microservices, tích hợp công nghệ realtime và tìm kiếm nâng cao để đảm bảo hiệu suất và trải nghiệm người dùng mượt mà.

Đây là đồ án cuối kỳ thuộc môn học Phát triển Ứng dụng Di động đa nền tảng.

Tác giả:

* Lê Thị Hiếu Ngân – 52200040
* Nguyễn Thị Huyền Diệu – 52200090
* Huỳnh Hoàng Tiến Đạt – 52200023

Công nghệ sử dụng:

* Flutter và Dart: phát triển ứng dụng frontend cho Web, Android, iOS
* ASP.NET Core kết hợp MongoDB: xây dựng backend theo kiến trúc Microservices
* Redis và Socket.IO: xử lý hàng đợi và truyền dữ liệu thời gian thực
* Elasticsearch: tìm kiếm sản phẩm nâng cao
* RESTful API: giao tiếp giữa frontend và backend
* GitHub Pages: deploy frontend web
* Railway (đã hết trial): deploy backend

Hướng dẫn chạy dự án:

1. Clone dự án:
   git clone [https://github.com/azur-14/danentang.git](https://github.com/azur-14/danentang.git)

2. Mở 3 terminal, lần lượt chạy backend từng service:
   cd UserManagementService/UserManagementService
   dotnet restore
   dotnet run

cd ProductManagementService/ProductManagementService
dotnet restore
dotnet run

cd OrderManagementService/OrderManagementService
dotnet restore
dotnet run

3. Chạy frontend Flutter:
   cd frontend
   flutter pub get
   flutter run

Lưu ý: Yêu cầu cài đặt sẵn Flutter SDK, .NET 6, Git và thiết bị Android hoặc emulator để chạy thử ứng dụng.

Tài khoản đăng nhập mẫu:

| Vai trò    | Email                                                   | Mật khẩu   |
| ---------- | ------------------------------------------------------- | ---------- |
| Admin      | [hieungan0906@gmail.com](mailto:hieungan0906@gmail.com) | 0987654321 |
| Khách hàng | [aoi13072004@gmail.com](mailto:aoi13072004@gmail.com)   | Dieu13@    |

Tính năng chính:

* Tìm kiếm và xem chi tiết sản phẩm
* Đăng ký, đăng nhập, phân quyền người dùng
* Thêm vào giỏ hàng, đặt hàng, hủy đơn hàng
* Quản lý sản phẩm, danh mục, đơn hàng (Admin)
* Bình luận và đánh giá theo thời gian thực sử dụng Socket.IO
* Gợi ý tìm kiếm bằng Elasticsearch
* Gửi email xác nhận đơn hàng thông qua Redis Queue

Triển khai:
Frontend web được build bằng Flutter và deploy lên GitHub Pages.
Backend từng microservice triển khai trên Railway, tự động build từ GitHub.
Hiện tại do Railway đã hết trial nên backend đang tạm ngừng hoạt động.
Người dùng có thể chạy toàn bộ hệ thống local theo hướng dẫn trên.

Tính năng mở rộng (Bonus):
Trong thư mục Bonus, nhóm đã thực hiện và trình bày các nội dung mở rộng:

* Triển khai Microservices với ba dịch vụ riêng biệt: người dùng, sản phẩm, đơn hàng
* Giao tiếp giữa các service bằng Redis Queue, đảm bảo bất đồng bộ và giảm kết dính
* Tích hợp AI gồm chatbot gợi ý sản phẩm, tìm kiếm bằng hình ảnh và phân tích cảm xúc đánh giá

Cấu trúc thư mục chính:

danentang/
├── frontend/
│   └── lib/
│       ├── Animation/              # Hiệu ứng chuyển động (animation, transition)
│       ├── constants/              # Hằng số toàn cục (API URL, màu sắc, kích thước)
│       ├── models/                 # Lớp mô hình dữ liệu (Product, User, Order...)
│       ├── Screens/                # Giao diện người dùng
│       │   ├── Customer/           # UI dành cho người dùng thông thường
│       │   └── Manager/            # UI dành cho quản trị viên (admin)
│       ├── Service/                # Gọi API hoặc xử lý logic nghiệp vụ
│       ├── ultis/                  # Các hàm tiện ích, định dạng, helper
│       ├── widgets/                # Các widget tái sử dụng (button, card, app bar)
│       ├── main.dart               # Điểm khởi chạy ứng dụng
│        └── routes.dart             # Quản lý định tuyến (Navigator, named routes)
│
├── UserManagementService/
├── ProductManagementService/
├── OrderManagementService/

Liên hệ:
Lê Thị Hiếu Ngân
Email: [hieungan0906@gmail.com](mailto:hieungan0906@gmail.com)
GitHub: [https://github.com/azur-14](https://github.com/azur-14)

Ghi chú:
Dự án sử dụng hoàn toàn công nghệ mã nguồn mở, không phụ thuộc vào nền tảng Backend-as-a-Service.
Mọi thành phần đều được tự xây dựng và triển khai, có thể chạy thử và kiểm thử độc lập.
Dự án chỉ dùng cho mục đích học thuật, không triển khai thương mại.