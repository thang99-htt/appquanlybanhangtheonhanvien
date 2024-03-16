import 'package:appqlbanhang/ui/products/products_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor:
                  Colors.white, // Đặt màu nền của AppBar là màu trắng
              title:
                  Consumer<AuthManager>(builder: (context, authManager, child) {
                final userId =
                    authManager.authToken?.userId; // Lấy userId từ AuthManager
                return Text(
                    'Xin Chào $userId!'); // Hiển thị userId trong AppBar
              }),
              automaticallyImplyLeading: false,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home,
                  color: Colors.black), // Thêm màu cho Icon
              title: const Text('Trang chủ',
                  style: TextStyle(color: Colors.black)), // Thêm màu cho Text
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shop,
                  color: Colors.black), // Thêm màu cho Icon
              title: const Text('Mua sắm',
                  style: TextStyle(color: Colors.black)), // Thêm màu cho Text
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ProductsOverviewScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app,
                  color: Colors.black), // Thêm màu cho Icon
              title: const Text('Đăng xuất',
                  style: TextStyle(color: Colors.black)), // Thêm màu cho Text
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushReplacementNamed('/');
                context.read<AuthManager>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
