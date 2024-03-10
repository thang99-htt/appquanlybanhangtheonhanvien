import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';
import '../products/manager_products_screen.dart';
import '../revenues/manager_revenues_screen.dart';
import '../users/manager_users_screen.dart';
import '../orders/manager_orders_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title:
                Consumer<AuthManager>(builder: (context, authManager, child) {
              final userId = authManager.authToken?.userId ??
                  ''; // Lấy userId từ AuthManager
              return Text('Xin Chào! $userId'); // Hiển thị userId trong AppBar
            }),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('QL Người dùng'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ManagerUsersScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('QL Sản phẩm'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ManagerProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop_2),
            title: const Text('QL Đơn hàng'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ManagerOrdersScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat_rounded),
            title: const Text('QL Doanh thu'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ManagerRevenuesScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.of(context)
                ..pop()
                ..pushReplacementNamed('/');
              context.read<AuthManager>().logout();
            },
          ),
        ],
      ),
    );
  }
}
