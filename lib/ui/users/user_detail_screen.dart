import 'package:flutter/material.dart';

import '../../models/user.dart';

class UserDetailScreen extends StatelessWidget {
  static const routeName = '/user-detail';
  const UserDetailScreen(
    this.user, {
    super.key,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin người dùng"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Họ tên: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: user.name,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Vai trò: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: user.role,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Email: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: user.email,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Người giới thiệu: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: user.presenter,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Người quản lý: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: user.manager,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
