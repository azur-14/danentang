cd dô trong thư mục có file csproject; đối với User Service thì phải dô danentang/UserManagementService/UserManagementService nhe
xong nhập lệnh
dotnet restore
dotnet add package MongoDB.Bson
dotnet add package MongoDB.Driver
rồi dotnet build là UserManagementService sẽ chạy trên cổng 5012, nhập http://localhost:5012/swagger/index.html nếu muốn xem mấy phương thức ha test API đồ; tương tự đối với các service khác nma phải chạy đồng thời nhiều terminal á

