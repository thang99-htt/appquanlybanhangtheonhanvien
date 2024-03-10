import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import 'users_manager.dart';
import '../shared/dialog_utils.dart';
import 'package:email_validator/email_validator.dart';

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
        );
    super.initState();
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
      value: _editedUser.managerId ?? 1,
      decoration: const InputDecoration(labelText: 'Người quản lý'),
      items: const [
        DropdownMenuItem<int>(
          value: 1,
          child: Text('1'),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text('2'),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Text('3'),
        ),
        DropdownMenuItem<int>(
          value: 4,
          child: Text('4'),
        ),
        DropdownMenuItem<int>(
          value: 5,
          child: Text('5'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _editedUser = _editedUser.copyWith(managerId: value);
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
