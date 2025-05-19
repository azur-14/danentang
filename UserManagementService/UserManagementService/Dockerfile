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

# Expose cổng 80 trong container (mặc định)
EXPOSE 80

# Đặt biến môi trường để app binding vào cổng Railway cấp (PORT)
ENV ASPNETCORE_URLS=http://*:${PORT:-80}

# Khởi chạy app
ENTRYPOINT ["dotnet", "UserManagementService.dll"]
