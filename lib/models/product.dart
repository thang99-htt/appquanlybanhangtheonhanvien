import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Product {
  final int? id;
  final String name;
  final String description;
  final String image;
  final int? stock;
  final int priceSale;
  final int pricePurchase;
  late int quantity;
  final DateTime? time;

  Product(
      {this.id,
      required this.name,
      required this.description,
      required this.image,
      this.stock,
      required this.priceSale,
      required this.pricePurchase,
      required this.quantity,
      required this.time});

  get price => null;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? stock,
    int? priceSale,
    int? pricePurchase,
    int? quantity,
    DateTime? time,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      priceSale: priceSale ?? this.priceSale,
      pricePurchase: pricePurchase ?? this.pricePurchase,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, image: $image)';
  }
}
