import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/ShippingAddress.dart';
import 'package:danentang/models/product.dart';

// Đường dẫn đến tài nguyên cục bộ thay vì chuỗi base64
const String placeholderImagePath = 'assets/placeholder.jpg';

// Danh sách sản phẩm (products)
final List<Product> products = [
  Product(
    id: 'SP001',
    name: 'Laptop Dell Inspiron 15',
    brand: 'Dell',
    description: 'Mạnh mẽ và gọn nhẹ',
    discountPercentage: 0,
    categoryId: 'c1',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img001',
        url: placeholderImagePath, // Sử dụng đường dẫn tài nguyên
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR001',
        variantName: 'i5 12th Gen',
        additionalPrice: 0,
        inventory: 10,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP002',
    name: 'Laptop HP Pavilion 14',
    brand: 'HP',
    description: 'Hiệu suất cao',
    discountPercentage: 0,
    categoryId: 'c1',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img002',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR002',
        variantName: 'i7 11th Gen',
        additionalPrice: 0,
        inventory: 8,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP003',
    name: 'Laptop ASUS ZenBook 13',
    brand: 'ASUS',
    description: 'Thiết kế mỏng nhẹ',
    discountPercentage: 0,
    categoryId: 'c1',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img003',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR003',
        variantName: 'i9 13th Gen',
        additionalPrice: 0,
        inventory: 5,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP004',
    name: 'Laptop Lenovo ThinkPad X1',
    brand: 'Lenovo',
    description: 'Dành cho doanh nghiệp',
    discountPercentage: 0,
    categoryId: 'c1',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img004',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR004',
        variantName: 'i5 12th Gen',
        additionalPrice: 0,
        inventory: 7,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP005',
    name: 'Tai nghe Sony WH-1000XM5',
    brand: 'Sony',
    description: 'Chống ồn vượt trội',
    discountPercentage: 0,
    categoryId: 'c2',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img005',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR005',
        variantName: 'Black',
        additionalPrice: 0,
        inventory: 15,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP006',
    name: 'Chuột Logitech MX Master 3',
    brand: 'Logitech',
    description: 'Chuột văn phòng cao cấp',
    discountPercentage: 0,
    categoryId: 'c3',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img006',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR006',
        variantName: 'Black',
        additionalPrice: 0,
        inventory: 20,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP007',
    name: 'Bàn phím Keychron K8',
    brand: 'Keychron',
    description: 'Bàn phím cơ chất lượng',
    discountPercentage: 0,
    categoryId: 'c3',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img007',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR007',
        variantName: 'RGB',
        additionalPrice: 0,
        inventory: 12,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP008',
    name: 'Tai nghe JBL Live 650BTNC',
    brand: 'JBL',
    description: 'Âm thanh sống động',
    discountPercentage: 0,
    categoryId: 'c2',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 15),
    images: [
      ProductImage(
        id: 'img008',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR008',
        variantName: 'Black',
        additionalPrice: 0,
        inventory: 10,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 15),
      ),
    ],
  ),
  Product(
    id: 'SP009',
    name: 'Laptop Acer Aspire 7',
    brand: 'Acer',
    description: 'Hiệu năng tốt cho game',
    discountPercentage: 0,
    categoryId: 'c1',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 16),
    images: [
      ProductImage(
        id: 'img009',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR009',
        variantName: 'i7 12th Gen',
        additionalPrice: 0,
        inventory: 6,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 16),
      ),
    ],
  ),
  Product(
    id: 'SP010',
    name: 'Loa Bluetooth JBL Charge 5',
    brand: 'JBL',
    description: 'Âm thanh mạnh mẽ',
    discountPercentage: 0,
    categoryId: 'c4',
    createdAt: DateTime(2025, 5, 1),
    updatedAt: DateTime(2025, 5, 16),
    images: [
      ProductImage(
        id: 'img010',
        url: placeholderImagePath,
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'VAR010',
        variantName: 'Blue',
        additionalPrice: 0,
        inventory: 15,
        createdAt: DateTime(2025, 5, 1),
        updatedAt: DateTime(2025, 5, 16),
      ),
    ],
  ),
];

// Danh sách đơn hàng (testOrders)
List<Order> testOrders = [
  Order(
    id: '1',
    userId: 'USER001',
    orderNumber: 'DH001',
    shippingAddress: ShippingAddress(
      receiverName: 'Trần Minh Quân',
      phoneNumber: '0901234567',
      addressLine: '123 Lê Lợi',
      ward: 'Phường Bến Thành',
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
    ),
    createdAt: DateTime(2025, 5, 15, 11, 00),
    updatedAt: DateTime(2025, 5, 15, 11, 55),
    status: 'Đã giao',
    totalAmount: 31000000.0,
    discountAmount: 0.0,
    couponCode: null,
    loyaltyPointsUsed: 0,
    items: [
      OrderItem(
        productId: 'SP001',
        productVariantId: 'VAR001',
        productName: 'Laptop Dell Inspiron 15',
        variantName: 'i5 12th Gen',
        quantity: 1,
        price: 25000000.0,
      ),
      OrderItem(
        productId: 'SP005',
        productVariantId: 'VAR005',
        productName: 'Tai nghe Sony WH-1000XM5',
        variantName: 'Black',
        quantity: 1,
        price: 6000000.0,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        status: 'Đặt hàng',
        timestamp: DateTime(2025, 5, 15, 11, 00),
      ),
      OrderStatusHistory(
        status: 'Đang xử lý',
        timestamp: DateTime(2025, 5, 15, 11, 10),
      ),
      OrderStatusHistory(
        status: 'Đang giao',
        timestamp: DateTime(2025, 5, 15, 11, 30),
      ),
      OrderStatusHistory(
        status: 'Đã giao',
        timestamp: DateTime(2025, 5, 15, 11, 55),
      ),
    ],
  ),
  Order(
    id: '2',
    userId: 'USER002',
    orderNumber: 'DH002',
    shippingAddress: ShippingAddress(
      receiverName: 'Lê Thị Mai',
      phoneNumber: '0933444555',
      addressLine: '456 Nguyễn Trãi',
      ward: 'Phường Thanh Xuân Trung',
      district: 'Quận Thanh Xuân',
      city: 'Hà Nội',
    ),
    createdAt: DateTime(2025, 5, 15, 10, 00),
    updatedAt: DateTime(2025, 5, 15, 11, 30),
    status: 'Đang giao',
    totalAmount: 33000000.0,
    discountAmount: 0.0,
    couponCode: null,
    loyaltyPointsUsed: 0,
    items: [
      OrderItem(
        productId: 'SP002',
        productVariantId: 'VAR002',
        productName: 'Laptop HP Pavilion 14',
        variantName: 'i7 11th Gen',
        quantity: 1,
        price: 28000000.0,
      ),
      OrderItem(
        productId: 'SP006',
        productVariantId: 'VAR006',
        productName: 'Chuột Logitech MX Master 3',
        variantName: 'Black',
        quantity: 1,
        price: 5000000.0,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        status: 'Đặt hàng',
        timestamp: DateTime(2025, 5, 15, 10, 00),
      ),
      OrderStatusHistory(
        status: 'Đang xử lý',
        timestamp: DateTime(2025, 5, 15, 10, 30),
      ),
      OrderStatusHistory(
        status: 'Đang giao',
        timestamp: DateTime(2025, 5, 15, 11, 30),
      ),
    ],
  ),
  Order(
    id: '3',
    userId: 'USER003',
    orderNumber: 'DH003',
    shippingAddress: ShippingAddress(
      receiverName: 'Phạm Văn Dũng',
      phoneNumber: '0988777666',
      addressLine: '789 Hai Bà Trưng',
      ward: 'Phường Hải Châu 1',
      district: 'Quận Hải Châu',
      city: 'Đà Nẵng',
    ),
    createdAt: DateTime(2025, 5, 15, 11, 58),
    updatedAt: DateTime(2025, 5, 15, 11, 58),
    status: 'Đặt hàng',
    totalAmount: 35000000.0,
    discountAmount: 0.0,
    couponCode: null,
    loyaltyPointsUsed: 0,
    items: [
      OrderItem(
        productId: 'SP003',
        productVariantId: 'VAR003',
        productName: 'Laptop ASUS ZenBook 13',
        variantName: 'i9 13th Gen',
        quantity: 1,
        price: 30000000.0,
      ),
      OrderItem(
        productId: 'SP007',
        productVariantId: 'VAR007',
        productName: 'Bàn phím Keychron K8',
        variantName: 'RGB',
        quantity: 1,
        price: 5000000.0,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        status: 'Đặt hàng',
        timestamp: DateTime(2025, 5, 15, 11, 58),
      ),
    ],
  ),
  Order(
    id: '4',
    userId: 'USER004',
    orderNumber: 'DH004',
    shippingAddress: ShippingAddress(
      receiverName: 'Ngô Văn Hòa',
      phoneNumber: '0911888999',
      addressLine: '101 Trần Phú',
      ward: 'Phường An Hội',
      district: 'Quận Ninh Kiều',
      city: 'Cần Thơ',
    ),
    createdAt: DateTime(2025, 5, 14, 15, 00),
    updatedAt: DateTime(2025, 5, 15, 11, 59),
    status: 'Đã hủy',
    totalAmount: 31000000.0,
    discountAmount: 0.0,
    couponCode: null,
    loyaltyPointsUsed: 0,
    items: [
      OrderItem(
        productId: 'SP004',
        productVariantId: 'VAR004',
        productName: 'Laptop Lenovo ThinkPad X1',
        variantName: 'i5 12th Gen',
        quantity: 1,
        price: 26000000.0,
      ),
      OrderItem(
        productId: 'SP008',
        productVariantId: 'VAR008',
        productName: 'Tai nghe JBL Live 650BTNC',
        variantName: 'Black',
        quantity: 1,
        price: 5000000.0,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        status: 'Đặt hàng',
        timestamp: DateTime(2025, 5, 14, 15, 00),
      ),
      OrderStatusHistory(
        status: 'Đã hủy',
        timestamp: DateTime(2025, 5, 15, 11, 59),
      ),
    ],
  ),
  Order(
    id: '5',
    userId: 'USER005',
    orderNumber: 'DH005',
    shippingAddress: ShippingAddress(
      receiverName: 'Nguyễn Thị Lan',
      phoneNumber: '0922333444',
      addressLine: '202 Hai Phong',
      ward: 'Phường Tân Định',
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
    ),
    createdAt: DateTime(2025, 5, 16, 3, 0),
    updatedAt: DateTime(2025, 5, 16, 3, 0),
    status: 'Đặt hàng',
    totalAmount: 29000000.0,
    discountAmount: 0.0,
    couponCode: null,
    loyaltyPointsUsed: 0,
    items: [
      OrderItem(
        productId: 'SP009',
        productVariantId: 'VAR009',
        productName: 'Laptop Acer Aspire 7',
        variantName: 'i7 12th Gen',
        quantity: 1,
        price: 24000000.0,
      ),
      OrderItem(
        productId: 'SP010',
        productVariantId: 'VAR010',
        productName: 'Loa Bluetooth JBL Charge 5',
        variantName: 'Blue',
        quantity: 1,
        price: 5000000.0,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        status: 'Đặt hàng',
        timestamp: DateTime(2025, 5, 16, 3, 0),
      ),
    ],
  ),
];