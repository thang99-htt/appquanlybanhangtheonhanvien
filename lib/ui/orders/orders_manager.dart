import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../models/order.dart';
import 'dart:async';

import '../../models/order_detail.dart';
import '../auth/auth_manager.dart';

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

  Future<void> addOrder(BuildContext context, Order order) async {
    // Pass BuildContext as a parameter
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

      final userId =
          Provider.of<AuthManager>(context, listen: false).authToken?.userId;

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
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

  Future<void> addOrderUser(BuildContext context, Order order) async {
    // Pass BuildContext as a parameter
    const url = 'http://10.0.2.2:8000/api/orders';
    try {
      // Map each Product object to the desired JSON structure
      List<Map<String, dynamic>> productsJsonList =
          order.products.map((product) {
        return {
          'product_id': product.id,
          'price': product.priceSale,
          'quantity': 1,
        };
      }).toList();

      const userId = null; // Lấy userId từ AuthManager

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
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

  Future<void> updateStatusOrder(BuildContext context, Order order) async {
    final url = 'http://10.0.2.2:8000/api/orders/update-status/${order.id}';
    try {
      final userId =
          Provider.of<AuthManager>(context, listen: false).authToken?.userId;

      await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': order.id,
          'user_id': userId,
          'status': order.status,
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
