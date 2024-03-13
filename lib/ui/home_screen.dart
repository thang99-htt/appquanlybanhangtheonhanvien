import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'auth/auth_manager.dart';
import 'notifications/notifications_manager.dart';
import 'notifications/notifications_overview_screen.dart';
import 'orders/manager_orders_screen.dart';
import 'products/manager_products_screen.dart';
import 'revenues/manager_revenues_screen.dart';
import 'shared/app_drawer.dart';
import 'users/manager_users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _refreshNotifications(BuildContext context) async {
    await context.read<NotificationsManager>().fetchNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FutureBuilder(
            future: _refreshNotifications(context),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return RefreshIndicator(
                onRefresh: () => _refreshNotifications(context),
                child: buildNotificationIcon(),
              );
            },
          ),
        ],
        title: SizedBox(
          height: 36,
          width: 500,
          child: TextField(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              hintText: 'Tìm kiếm...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color.fromARGB(87, 196, 204, 211),
              hintStyle: const TextStyle(color: Colors.white),
            ),
            onChanged: (value) {},
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ManagerUsersScreen.routeName);
                  },
                  child: buildCard(
                    title: 'Người dùng',
                    icon: Icons.people,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ManagerOrdersScreen.routeName);
                  },
                  child: buildCard(
                    title: 'Đơn hàng',
                    icon: Icons.shopping_cart,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ManagerProductsScreen.routeName);
                  },
                  child: buildCard(
                    title: 'Sản phẩm',
                    icon: Icons.inventory,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ManagerRevenuesScreen.routeName);
                  },
                  child: buildCard(
                    title: 'Doanh thu',
                    icon: Icons.attach_money,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildCard({required String title, required IconData icon}) {
    return SizedBox(
      height: 150, // Điều chỉnh kích thước theo ý muốn của bạn
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotificationIcon() {
    return Consumer<NotificationsManager>(
      builder: (context, notificationsManager, child) {
        int unreadNotificationsCount = notificationsManager.items
            .where((notification) => notification.readed == 0)
            .length;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsOverviewScreen(),
              ),
            );
          },
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white, // Change the icon color to white
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsOverviewScreen(),
                    ),
                  );
                },
              ),
              if (unreadNotificationsCount > 0)
                Positioned(
                  top: 2.0,
                  right: 4.0,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red, // You can change the color as needed
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
