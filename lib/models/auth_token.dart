class AuthToken {
  final String _token;
  final int _userId;
  final String _userRole;
  final DateTime _expiryDate;

  AuthToken({
    token,
    userId,
    userRole,
    expiryDate,
  })  : _token = token,
        _userId = userId,
        _userRole = userRole,
        _expiryDate = expiryDate;

  bool get isValid {
    return token != null;
  }

  String? get token {
    if (_expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  int get userId {
    return _userId;
  }

  String get userRole {
    return _userRole;
  }

  DateTime get expiryDate {
    return _expiryDate;
  }

  Map<String, dynamic> toJson() {
    return {
      'token': _token,
      'userId': _userId,
      'userRole': _userRole,
      'expiryDate': _expiryDate.toIso8601String(),
    };
  }

  static AuthToken fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'],
      userId: json['userId'],
      userRole: json['userRole'],
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }
}
