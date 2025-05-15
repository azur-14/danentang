import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/ShippingAddress.dart';

List<Order> testOrders = [
  // Đơn hàng 1: Đã giao
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
      OrderStatusHistory(status: 'Đặt hàng', timestamp: DateTime(2025, 5, 15, 11, 00)),
      OrderStatusHistory(status: 'Đang xử lý', timestamp: DateTime(2025, 5, 15, 11, 10)),
      OrderStatusHistory(status: 'Đang giao', timestamp: DateTime(2025, 5, 15, 11, 30)),
      OrderStatusHistory(status: 'Đã giao', timestamp: DateTime(2025, 5, 15, 11, 55)),
    ],
  ),

  // Đơn hàng 2: Đang giao
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
      OrderStatusHistory(status: 'Đặt hàng', timestamp: DateTime(2025, 5, 15, 10, 00)),
      OrderStatusHistory(status: 'Đang xử lý', timestamp: DateTime(2025, 5, 15, 10, 30)),
      OrderStatusHistory(status: 'Đang giao', timestamp: DateTime(2025, 5, 15, 11, 30)),
    ],
  ),

  // Đơn hàng 3: Đặt hàng
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
      OrderStatusHistory(status: 'Đặt hàng', timestamp: DateTime(2025, 5, 15, 11, 58)),
    ],
  ),

  // Đơn hàng 4: Đã hủy
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
      OrderStatusHistory(status: 'Đặt hàng', timestamp: DateTime(2025, 5, 14, 15, 00)),
      OrderStatusHistory(status: 'Đã hủy', timestamp: DateTime(2025, 5, 15, 11, 59)),
    ],
  ),
];
