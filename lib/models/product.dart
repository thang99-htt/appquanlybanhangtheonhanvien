import 'purchase_info.dart';
import 'sale_info.dart';

class Product {
  final int? id;
  final String name;
  final String description;
  final String image;
  final int? stock;
  final DateTime? timeSale;
  final int? priceSale;
  final List<PurchasesInfo>? purchasesInfo;
  final List<PurchasesInfo>? purchaseInfo;
  final List<SalesInfo>? salesInfo;
  final List<SalesInfo>? saleInfo;
  late int? quantity;

  Product(
      {this.id,
      required this.name,
      required this.description,
      required this.image,
      this.stock,
      this.timeSale,
      this.priceSale,
      this.purchasesInfo,
      this.purchaseInfo,
      this.salesInfo,
      this.saleInfo,
      this.quantity});

  get price => null;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? stock,
    DateTime? timeSale,
    int? priceSale,
    List<PurchasesInfo>? purchasesInfo,
    List<PurchasesInfo>? purchaseInfo,
    List<SalesInfo>? salesInfo,
    List<SalesInfo>? saleInfo,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      timeSale: timeSale ?? this.timeSale,
      priceSale: priceSale ?? this.priceSale,
      purchasesInfo: purchasesInfo ?? this.purchasesInfo,
      purchaseInfo: purchaseInfo ?? this.purchaseInfo,
      salesInfo: salesInfo ?? this.salesInfo,
      saleInfo: saleInfo ?? this.saleInfo,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'Product(purchasesInfo: $purchasesInfo)';
  }
}
