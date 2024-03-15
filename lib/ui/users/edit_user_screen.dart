import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import 'users_manager.dart';
import '../shared/dialog_utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class EditUserScreen extends StatefulWidget {
  static const routeName = '/edit-user';

  final User? user;

  const EditUserScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _editForm = GlobalKey<FormState>();
  late User _editedUser;
  var _isLoading = false;
  late List<User> _allUsers = [];
  int? _selectedUserId;

  @override
  void initState() {
    _editedUser = widget.user ??
        User(
          id: null,
          name: '',
          role: '',
          email: '',
          presenter: '',
          manager: '',
          password: '',
          managerId: null, 
        );
    super.initState();
    _fetchAllUsers();
  }

  void _fetchAllUsers() async {
    const url = 'http://10.0.2.2:8000/api/users';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _allUsers = responseData.map((data) {
          return User(
            id: data['id'],
            name: data['name'],
            email: '',
            password: '',
            role: '',
          );
        }).toList();
        _allUsers.insert(
          0,
          User(
            id: null,
            name: 'Unknown',
            email: '',
            password: '',
            role: '',
          ),
        );

        setState(() {});
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    _editedUser = _editedUser.copyWith(managerId: _selectedUserId);

    setState(() {
      _isLoading = true;
    });

    try {
      final usersManager = context.read<UsersManager>();
      if (_editedUser.id != null) {
        await usersManager.updateUser(_editedUser);
      } else {
        await usersManager.addUser(_editedUser);
      }
    } catch (error) {
      await showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Người dùng'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _editForm,
                child: ListView(
                  children: <Widget>[
                    buildNameField(),
                    buildRoleField(),
                    buildPresenterField(),
                    const SizedBox(height: 16),
                    Text(
                        'Người quản lý hiện tại: ${_editedUser.managerId == null ? _editedUser.manager : 'NULL'}'),
                    buildManagerField(),
                    buildEmailField(),
                    if (_editedUser.id == null) buildPasswordField(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildManagerField() {
    return DropdownButtonFormField<int>(
      value: _editedUser.managerId,
      decoration: const InputDecoration(labelText: 'Người quản lý'),
      items: _allUsers.map((User user) {
        return DropdownMenuItem<int>(
          value: user.id ?? -1,
          child: Text('${user.id} - ${user.name}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUserId = value;
          _editedUser = _editedUser.copyWith(managerId: _selectedUserId);
        });
      },
      validator: (value) {
        return null;
      },
    );
  }

  TextFormField buildNameField() {
    return TextFormField(
      initialValue: _editedUser.name,
      decoration: const InputDecoration(labelText: 'Họ tên'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập họ tên.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(name: value);
      },
    );
  }

  TextFormField buildEmailField() {
    return TextFormField(
      initialValue: _editedUser.email,
      decoration: const InputDecoration(labelText: 'Email'),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập email.';
        }
        if (!EmailValidator.validate(value)) {
          return 'Email không hợp lệ.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(email: value);
      },
    );
  }

  TextFormField buildPasswordField() {
    return TextFormField(
      initialValue: _editedUser.password,
      decoration: const InputDecoration(labelText: 'Mật khẩu'),
      textInputAction: TextInputAction.next,
      obscureText: true, // Hiển thị dạng password
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập mật khẩu.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(password: value);
      },
    );
  }

  TextFormField buildRoleField() {
    return TextFormField(
      initialValue: _editedUser.role,
      decoration: const InputDecoration(labelText: 'Vai trò'),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập vai trò.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(role: value);
      },
    );
  }

  TextFormField buildPresenterField() {
    return TextFormField(
      initialValue: _editedUser.presenter,
      decoration: const InputDecoration(labelText: 'Người giới thiệu'),
      textInputAction: TextInputAction.next,
      validator: (value) {
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(presenter: value);
      },
    );
  }
}
