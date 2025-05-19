# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy csproj và restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy toàn bộ source code và build
COPY . ./
RUN dotnet publish -c Release -o out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

# Mở cổng mặc định
EXPOSE 80

# Biến PORT do Railway cấp sẽ được binding tự động
ENV ASPNETCORE_URLS=http://*:${PORT}

# Khởi chạy app
ENTRYPOINT ["dotnet", "OrderManagementService.dll"]