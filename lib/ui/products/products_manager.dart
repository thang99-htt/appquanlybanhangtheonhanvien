import 'dart:convert';
import 'package:appqlbanhang/models/purchase_info.dart';
import 'package:appqlbanhang/models/sale_info.dart';
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
        List<Product> products = [];
        for (var data in responseData) {
          List<PurchasesInfo> purchasesInfo = [];
          for (var detailData in data['purchasesInfo']) {
            purchasesInfo.add(
              PurchasesInfo(
                time: DateTime.parse(detailData['time'])
                    .add(const Duration(hours: 7)),
                price: detailData['price'],
                quantity: detailData['quantity'],
              ),
            );
          }

          List<SalesInfo> salesInfo = [];
          for (var detailData in data['salesInfo']) {
            salesInfo.add(
              SalesInfo(
                productId: detailData['product_id'],
                time: DateTime.parse(detailData['time'])
                    .add(const Duration(hours: 7)),
                price: detailData['price'],
                checked: detailData['checked'],
              ),
            );
          }
          products.add(
            Product(
              id: data['id'],
              name: data['name'],
              description: data['description'],
              image: data['image'],
              stock: data['stock'],
              timeSale: data['time_sale'] != null
                  ? DateTime.parse(data['time_sale'])
                      .add(const Duration(hours: 7))
                  : null,
              priceSale: data['price_sale'],
              purchasesInfo: purchasesInfo,
              salesInfo: salesInfo,
            ),
          );
        }
        _items = products;
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
        }),
      );
      fetchProducts();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }

  Future<void> updateProductPricePurchase(Product product) async {
    final url =
        'http://10.0.2.2:8000/api/products/update-price-purchase/${product.id}';
    try {
      List<Map<String, dynamic>> purchasesInfoJson =
          product.purchaseInfo != null
              ? product.purchaseInfo!.map((item) {
                  return {
                    'time': item.time.toString(),
                    'price': item.price,
                    'quantity': item.quantity,
                  };
                }).toList()
              : [];

      final List<Map<String, dynamic>> purchasesInfoSeparated =
          purchasesInfoJson.map((purchase) {
        return {
          'time': purchase['time'],
          'price': purchase['price'],
          'quantity': purchase['quantity'],
        };
      }).toList();

      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            purchasesInfoSeparated[0]), // Pass as a Map instead of a List
      );
      fetchProducts();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }

  Future<void> updateProductPriceSale(Product product) async {
    final url =
        'http://10.0.2.2:8000/api/products/update-price-sale/${product.id}';
    try {
      List<Map<String, dynamic>> salesInfoJson = product.saleInfo != null
          ? product.saleInfo!.map((item) {
              return {
                'time': item.time.toString(),
                'price': item.price,
              };
            }).toList()
          : [];

      final List<Map<String, dynamic>> salesInfoSeparated =
          salesInfoJson.map((purchase) {
        return {
          'time': purchase['time'],
          'price': purchase['price'],
        };
      }).toList();

      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            salesInfoSeparated[0]), // Pass as a Map instead of a List
      );
      final responseData = json.decode(response.body);
      print(responseData);
      fetchProducts();
      notifyListeners();
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
