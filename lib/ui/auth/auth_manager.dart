import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/auth_token.dart';
import 'package:http/http.dart' as http;

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;
  Timer? _authTimer;

  bool get isAuth {
    return authToken != null && authToken!.isValid;
  }

  AuthToken? get authToken {
    return _authToken;
  }

  void _setAuthToken(AuthToken token) {
    _authToken = token;
    // _autoLogout();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/users/login');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);
      if (responseData != null &&
          responseData['token'] != null &&
          responseData['role'] != null &&
          responseData['expiryDate'] != null) {
        final authToken = AuthToken(
          token: responseData['token'],
          userId: responseData['userId'],
          userRole: responseData['role'].toString(),
          expiryDate: DateTime.parse(responseData['expiryDate']),
        );
        _setAuthToken(authToken);
      } else {
        throw Exception(responseData);
      }
    } catch (error) {
      throw Exception('Failed to login: $error');
    }
  }

  Future<void> logout() async {
    _authToken = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    if (_authToken != null && _authToken!.expiryDate.isAfter(DateTime.now())) {
      return true;
    }

    return false;
  }

  Future<void> signup(String email, String password) async {
    try {
      const url = 'http://10.0.2.2:8000/api/users/signup';
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);
      final authToken = AuthToken(
        token: responseData['token'],
        expiryDate: DateTime.parse(responseData['expiryDate']),
      );

      _setAuthToken(authToken);
    } catch (error) {
      throw Exception('Failed to sign up: $error');
    }
  }

  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer!.cancel();
  //   }
  //   final timeToExpiry =
  //       _authToken!.expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }
}
