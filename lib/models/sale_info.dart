class SalesInfo {
  final int? productId;
  final DateTime time;
  final int price;
  final int? checked;

  SalesInfo(
      {this.productId, required this.time, required this.price, this.checked});

  SalesInfo copyWith({
    int? productId,
    DateTime? time,
    int? price,
    int? checked,
  }) {
    return SalesInfo(
      productId: productId ?? this.productId,
      time: time ?? this.time,
      price: price ?? this.price,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toString() {
    return 'Product(time: $time, price: $price, checked: $checked, product_id: $productId)';
  }
}
