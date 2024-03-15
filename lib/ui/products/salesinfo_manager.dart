import 'dart:convert';
import 'package:provider/provider.dart';

import '../../models/sale_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'products_manager.dart';

class SalesInfoManager with ChangeNotifier {
  Future<void> updateChecked(BuildContext context, SalesInfo salesInfo) async {
    const url = 'http://10.0.2.2:8000/api/products/update-checked';
    try {
      await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'product_id': salesInfo.productId,
          'time': salesInfo.time.toString(),
          'price': salesInfo.price,
          'checked': salesInfo.checked,
        }),
      );
      final productsManager = context.read<ProductsManager>();

      await productsManager.fetchProducts();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }
}
