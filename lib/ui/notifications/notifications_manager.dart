import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/notification.dart';
import '../auth/auth_manager.dart';

class NotificationsManager with ChangeNotifier {
  List<Notifications> _items = [];

  List<Notifications> get items => [..._items];

  Future<void> fetchNotifications(BuildContext context) async {
    try {
      final userId =
          Provider.of<AuthManager>(context, listen: false).authToken?.userId;
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/notifications/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Notifications> notifications = [];
        for (var data in responseData) {
          notifications.add(
            Notifications(
              id: data['id'],
              message: data['message'],
              sendby: data['sendby'],
              date: DateTime.parse(data['date']),
              readed: data['readed'],
            ),
          );
        }
        _items = notifications;
        notifyListeners();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      throw Exception('Failed to load notifications: $error');
    }
  }

  Future<void> addNotification(
      BuildContext context, Map<String, dynamic> message) async {
    try {
      final userId =
          Provider.of<AuthManager>(context, listen: false).authToken?.userId;
      const url = 'http://10.0.2.2:8000/api/notifications';
      await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'message': message['message'],
          'sendby': message['sendby'],
          'date': message['date'],
          'sendto': userId,
        }),
      );

      fetchNotifications(context);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to create notification: $error');
    }
  }

  Future<void> addNotificationAll(
      BuildContext context, Map<String, dynamic> message) async {
    try {
      final responseUserId = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/users/findbysale'));

      if (responseUserId.statusCode == 200) {
        final List<dynamic> responseUserIdData =
            json.decode(responseUserId.body);
        List<int> userIds = [];

        for (var data in responseUserIdData) {
          int id = data['id'];
          userIds.add(id);
        }

        for (int userId in userIds) {
          const url = 'http://10.0.2.2:8000/api/notifications';
          await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'message': message['message'],
              'sendby': message['sendby'],
              'date': message['date'],
              'sendto': userId,
            }),
          );
        }
      }

      fetchNotifications(context);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to create notification: $error');
    }
  }

  Future<void> updateNotification(BuildContext context, int id) async {
    try {
      final url =
          'http://10.0.2.2:8000/api/notifications/readed/$id'; // Đảm bảo rằng id được chèn trực tiếp vào URL
      await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'readed': 1, // Cập nhật trường 'readed' thành 1
        }),
      );

      fetchNotifications(context);

      notifyListeners();
    } catch (error) {
      throw Exception('Failed to update notification: $error');
    }
  }

  int get itemCount {
    return _items.length;
  }
}
