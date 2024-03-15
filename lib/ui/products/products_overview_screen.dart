import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notifications_manager.dart';
import '../notifications/notifications_overview_screen.dart';
import '../screens.dart';
import 'products_grid.dart';
import '../shared/app_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  late Future<void> _fetchProducts;
  late IO.Socket socket;

  @override
  void initState() {
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
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
        userRole == 'Quản lý bán hàng' ||
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

      body: FutureBuilder(
        future: _fetchProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ProductsGrid();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
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
            Navigator.of(context)
                .pushReplacementNamed(NotificationsOverviewScreen.routeName);
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
