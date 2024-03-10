class OrderDetail {
  final int productId;
  final String productName;
  final String productImage;
  final int price;
  final int quantity;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });
}
