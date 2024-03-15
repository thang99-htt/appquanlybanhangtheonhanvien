import 'package:appqlbanhang/ui/notifications/notifications_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';
import '../notifications/notifications_manager.dart';
import '../products/products_overview_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({Key? key}) : super(key: key);

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  late IO.Socket socket;
  @override
  void initState() {
    socket = IO.io(
        'http://10.0.2.2:8000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();

    setUpSocketListener();
    super.initState();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  void setUpSocketListener() {
    final notificationsManager = context.read<NotificationsManager>();
    final userRole =
        Provider.of<AuthManager>(context, listen: false).authToken?.userRole ??
            '';
    if (userRole == 'Người quản trị' ||
        userRole == 'bán hàng' ||
        userRole == 'Nhân viên bán hàng') {
      socket.on(
        'message-receive',
        (data) async {
          print(data);
          await notificationsManager.addNotification(context, data);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0; // Chỉ số của item được chọn

    void _onItemTapped(int index) {
      // Xử lý khi chọn một item
      // Thay đổi chỉ số của item được chọn
      // Cập nhật UI hoặc thực hiện hành động tương ứng
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
          break;
        case 1:
          Navigator.of(context)
              .pushReplacementNamed(ProductsOverviewScreen.routeName);
          break;
        case 2:
          Navigator.of(context)
              .pushReplacementNamed(NotificationsOverviewScreen.routeName);
          break;
        case 3:
          Navigator.of(context).pushReplacementNamed('/');

          break;
      }
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      child: SizedBox(
        height: 65,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'Mua sắm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: const Color.fromARGB(255, 110, 110, 110),
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          onTap: _onItemTapped,
          iconSize: 30,
        ),
      ),
    );
  }
}
