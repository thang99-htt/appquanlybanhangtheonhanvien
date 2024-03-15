class PurchasesInfo {
  final DateTime time;
  final int price;
  final int quantity;

  PurchasesInfo(
      {required this.time, required this.price, required this.quantity});

  PurchasesInfo copyWith({
    DateTime? time,
    int? price,
    int? quantity,
  }) {
    return PurchasesInfo(
      time: time ?? this.time,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'Product(time: $time, quantity: $quantity, price: $price)';
  }
}
