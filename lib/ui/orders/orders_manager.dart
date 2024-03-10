import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/order.dart';
import 'dart:async';

import '../../models/order_detail.dart';

class OrdersManager with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items => [..._items];

  Future<void> fetchOrders() async {
    const url = 'http://10.0.2.2:8000/api/orders';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Order> orders = [];
        for (var data in responseData) {
          List<OrderDetail> details = [];
          for (var detailData in data['details']) {
            details.add(
              OrderDetail(
                productId: detailData['product_id'],
                productName: detailData['product_name'],
                productImage: detailData['product_image'],
                price: detailData['price'],
                quantity: detailData['quantity'],
              ),
            );
          }
          orders.add(
            Order(
              id: data['id'],
              userId: data['user_id'],
              userName: data['user_name'],
              orderedAt: data['ordered_at'] != null
                  ? DateTime.parse(data['ordered_at'])
                  : null,
              receivedAt: data['received_at'] != null
                  ? DateTime.parse(data['received_at'])
                  : null,
              totalValue: data['total_value'],
              status: data['status'],
              nameCustomer: data['name_customer'],
              phoneCustomer: data['phone_customer'],
              addressCustomer: data['address_customer'],
              details: details,
              products: [],
            ),
          );
        }
        _items = orders;
        notifyListeners();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      throw Exception('Failed to load orders: $error');
    }
  }

  Future<void> addOrder(Order order) async {
    const url = 'http://10.0.2.2:8000/api/orders';
    try {
      // Map each Product object to the desired JSON structure
      List<Map<String, dynamic>> productsJsonList =
          order.products.map((product) {
        return {
          'product_id': product.id,
          'price': product.priceSale,
          'quantity': product.quantity,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': order.userId,
          'total_value': order.totalValue,
          'name_customer': order.nameCustomer,
          'phone_customer': order.phoneCustomer,
          'address_customer': order.addressCustomer,
          'details': productsJsonList, // Use the mapped JSON list here
        }),
      );

      fetchOrders();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  int get itemCount {
    return _items.length;
  }

  Order? findById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }
}
