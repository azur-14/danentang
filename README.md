Đồ Án Cuối Kỳ
Môn học: Phát triển Ứng dụng Di động đa nền tảng Học kỳ: Cuối Kỳ
Đề tài: Quản lý cửa hàng HoaLaHe bán laptop và phụ kiện

Tác giả:
Lê Thị Hiếu Ngân - 52200040
Nguyễn Thị Huyền Diệu - 52200090
Huỳnh Hoàng Tiến Đạt - 52200023

1 Thông tin chung về dự án
Dự án một hệ thống thương mại điện tử đa nền tảng (mobile & web) được xây dựng bằng Flutter, mang tên HoaLaHe App. Ứng dụng cho phép người dùng thực hiện các chức năng như tìm kiếm, xem chi tiết và mua sắm các sản phẩm máy tính và linh kiện điện tử. Hệ thống được thiết kế để cung cấp trải nghiệm người dùng mượt mà, giao diện trực quan và tốc độ phản hồi nhanh.
Công nghệ phía client: Ứng dụng được phát triển bằng Flutter, hỗ trợ cả hai nền tảng mobile và web, đảm bảo tính nhất quán và hiệu suất cao.
Công nghệ phía server: Chọn ASP.NET làm backend framework để xây dựng API, kết nối với cơ sở dữ liệu MongoDB để quản lý dữ liệu sản phẩm, đơn hàng, và người dùng.

2 Hướng dẫn xây dựng và chạy ứng dụng

Yêu cầu hệ thống
Flutter SDK đã được cài đặt trên máy tính (theo hướng dẫn từ trang Flutter.dev).
Git đã được thiết lập sẵn.
Đã có thiết bị ảo (Emulator) hoặc thiết bị thật chạy Android/iOS để thử nghiệm.
Các bước xây dựng và chạy
* Tải hoặc Clone repository, source code
Mở terminal hoặc command prompt và chạy:
git clone [https://github.com/azur-14/danentang.git]
   	chuyển vào thư mục dự án:
cd lần lượt vào từng thư mục có file csproject(mở 3 terminal): cd UserManagementService\UserManagementService; cd ProductManagementService, cd OrderManagementService
nhập lệnh:(chỉ cần nhập một lần) dotnet restore
dotnet add package MongoDB.Bson
dotnet add package MongoDB.Driver
sau đó nhấn dotnet run đối với từng thư mục
mở terminal ở root của dự án, sau đó cd frontend

	* Cài đặt các thư viện phụ thuộc
   	Trong thư mục dự án, chạy:
   	flutter pub get

	* Chạy ứng dụng
   	Kết nối thiết bị ảo hoặc thiết bị thật với máy tính, sau đó chạy:
   	flutter run

4 Thông tin tài khoản người dùng (dữ liệu đã được tải sẵn)

| Vai trò      | Email                                                   | Mật khẩu     | Ghi chú                     |
| ------------ | ------------------------------------------------------- | --------     | --------------------------- |
| Admin        | [hieungan0906@gmail.com]                                | 0987654321   | Toàn quyền quản lý hệ thống |
| Khách hàng 1 | [aoi13072004@gmail.com]                                 | Dieu13@      | Tài khoản khách hàng mẫu    |


5. Các ghi chú quan trọng

Kết nối Internet: Ứng dụng yêu cầu kết nối Internet để tải dữ liệu sản phẩm qua REST API và hỗ trợ bình luận/đánh giá thời gian thực bằng Socket.IO.
Tài khoản Admin: Có quyền quản lý sản phẩm, danh mục và các thiết lập hệ thống.
Tài khoản Khách hàng: Có thể xem sản phẩm, thêm vào giỏ hàng, thực hiện thanh toán (có thể ở chế độ demo) và tham gia đánh giá/bình luận.

6. Chi tiết các công nghệ đã sử dụng

Flutter: Framework UI mã nguồn mở của Google, hỗ trợ phát triển đa nền tảng từ một codebase duy nhất, với hiệu suất cao và khả năng tùy biến mạnh mẽ.
Dart: Ngôn ngữ lập trình chính cho Flutter, định hướng đối tượng, cú pháp dễ học và thân thiện với người mới.
ASP.NET: Framework backend mạnh mẽ của Microsoft, hỗ trợ xây dựng server hiệu quả, mở rộng cao, triển khai trên Google Cloud.
REST API: Giao thức giao tiếp giữa frontend và backend qua HTTP (GET, POST, PUT, DELETE) để xử lý dữ liệu.
Socket.IO: Thư viện giao tiếp hai chiều thời gian thực giữa client và server, sử dụng cho tính năng bình luận/đánh giá tức thời.
Redis: Hệ thống lưu trữ trong bộ nhớ, đóng vai trò message broker cho hàng đợi gửi email; một worker nền xử lý email từ Redis và thực hiện gửi.
Elasticsearch: Công cụ tìm kiếm dựa trên Lucene, cung cấp khả năng tìm kiếm nhanh, gợi ý và khớp gần đúng cho sản phẩm.

Triển khai:
Ứng dụng web và web view được triển khai trên Firebase Hosting.
Server backend ASP.NET triển khai trên Google Cloud.

7. Điểm cộng
   Để đạt điểm cộng, nhóm phát triển đã chú trọng vào phần xây dựng backend và các công nghệ liên quan, bao gồm:


8. Thư mục Bonus
   Trong thư mục "Bonus", nhóm chúng em đã triển khai các tính năng mở rộng sau để đạt điểm cộng, kèm theo bằng chứng minh họa:

   Integrate AI-related features, such as a smart chatbot that can suggest
   products directly related to this system, product search by image upload, and
   Sentiment Analysis for reviews and feedback.

   Do not utilize Backend-as-a-Service platforms like Firebase. Instead,
   develop your own backend solution using any framework of your choice (e.g.,
   Express.js, NestJS, Spring MVC, or ASP.NET, etc.), with a database of your
   preference such as MySQL, MongoDB, or PostgreSQL. You are required to
   submit the complete source code along with all relevant information and
   supporting evidence to earn additional points.

   Deploy the system following a Microservices Architecture. In addition to the
   front end and database, there must be at least three other services. You must also
   demonstrate asynchronous communication and decoupling between services
   using an intermediary channel, such as RabbitMQ or Redis.
