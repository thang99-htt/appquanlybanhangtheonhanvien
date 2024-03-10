import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import 'dart:async';

class UsersManager with ChangeNotifier {
  List<User> _items = [];

  List<User> get items => [..._items];

  Future<void> fetchUsers() async {
    final url = 'http://10.0.2.2:8000/api/users';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _items = responseData.map((data) {
          return User(
            id: data['id'],
            name: data['name'],
            email: data['email'],
            password: data['password'],
            role: data['role'],
            presenter: data['presenter'] ?? '',
            manager: data['manager'] ?? '',
          );
        }).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      throw Exception('Failed to load users: $error');
    }
  }

  Future<void> addUser(User user) async {
    final url = 'http://10.0.2.2:8000/api/users';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'presenter': user.presenter,
          'manager_id': user.managerId,
        }),
      );
      fetchUsers();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to create user: $error');
    }
  }

  Future<void> updateUser(User user) async {
    final url = 'http://10.0.2.2:8000/api/users/${user.id}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'presenter': user.presenter,
          'manager': user.manager,
        }),
      );
      fetchUsers();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }

  int get itemCount {
    return _items.length;
  }

  User? findById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }
}
