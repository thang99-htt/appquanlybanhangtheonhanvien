import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import '../../models/product.dart';

class ProductsManager with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => [..._items];

  Future<void> fetchProducts() async {
    const url = 'http://10.0.2.2:8000/api/products';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _items = responseData.map((data) {
          return Product(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            image: data['image'],
            stock: data['stock'],
            priceSale: data['price_sale'],
            pricePurchase: data['price_purchase'],
            quantity: data['quantity'],
            time: data['time'] != null ? DateTime.parse(data['time']) : null,
          );
        }).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  Future<void> addProduct(Product product) async {
    const url = 'http://10.0.2.2:8000/api/products';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': product.name,
          'description': product.description,
          'image': product.image,
          'price_purchase': product.pricePurchase,
          'price_sale': product.priceSale,
          'quantity': product.quantity,
          'stock': product.stock,
          'time': product.time!.toIso8601String(),
        }),
      );
      fetchProducts();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }

  Future<void> updateProduct(Product product) async {
    final url = 'http://10.0.2.2:8000/api/products/${product.id}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': product.name,
          'description': product.description,
          'image': product.image,
          'price_purchase': product.pricePurchase,
          'price_sale': product.priceSale,
          'quantity': product.quantity,
          'stock': product.stock,
          'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(product.time!),
        }),
      );
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }

  int get itemCount {
    return _items.length;
  }

  Product? findById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }
}
