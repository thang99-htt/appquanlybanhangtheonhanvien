import 'order_detail.dart';
import 'product.dart';

class Order {
  final int? id;
  final int? userId;
  final String? userName;
  final DateTime? orderedAt;
  final DateTime? receivedAt;
  final int totalValue;
  final String nameCustomer;
  final String phoneCustomer;
  final String? addressCustomer;
  final String? status;
  final List<OrderDetail> details;
  final List<Product> products;

  Order({
    this.id,
    this.userId,
    this.userName,
    this.orderedAt,
    this.receivedAt,
    required this.totalValue,
    this.status,
    required this.nameCustomer,
    required this.phoneCustomer,
    this.addressCustomer,
    required this.details,
    required this.products,
  });

  Order copyWith({
    int? id,
    int? userId,
    String? userName,
    DateTime? orderedAt,
    DateTime? receivedAt,
    int? totalValue,
    String? nameCustomer,
    String? phoneCustomer,
    String? addressCustomer,
    String? status,
    List<OrderDetail>? details,
    List<Product>? products,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      orderedAt: orderedAt ?? this.orderedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      totalValue: totalValue ?? this.totalValue,
      nameCustomer: nameCustomer ?? this.nameCustomer,
      phoneCustomer: phoneCustomer ?? this.phoneCustomer,
      addressCustomer: addressCustomer ?? this.addressCustomer,
      status: status ?? this.status,
      details: details ?? this.details,
      products: products ?? this.products,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, products: $products)';
  }
}
