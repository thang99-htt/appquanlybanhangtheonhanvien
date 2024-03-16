import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../shared/app_drawer.dart';
import 'add_order_screen.dart';
import 'manager_order_list_tile.dart';
import 'orders_manager.dart';

class ManagerOrdersScreen extends StatefulWidget {
  static const routeName = '/manager-orders';

  const ManagerOrdersScreen({Key? key}) : super(key: key);

  @override
  _ManagerOrdersScreenState createState() => _ManagerOrdersScreenState();
}

class _ManagerOrdersScreenState extends State<ManagerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _totalOrders;
  late int _pendingOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _totalOrders = 0;
    _pendingOrders = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders(BuildContext context) async {
    await context.read<OrdersManager>().fetchOrders();
  }

  void _calculateOrderStats(BuildContext context) {
    final ordersManager = context.read<OrdersManager>();
    _totalOrders = ordersManager.items.length;
    _pendingOrders = ordersManager.items
        .where((order) => order.status == 'Chờ xác nhận')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'QL Đơn hàng',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          buildOrderStats(context),
          Expanded(
            child: Column(
              children: [
                buildFilter(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildManagerOrderListView(context, ''),
                      buildManagerOrderListView(context, 'Chờ xác nhận'),
                      buildManagerOrderListView(context, 'Hoàn thành'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AddOrderScreen.routeName,
            );
          },
          backgroundColor: Colors.blue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30), // Thiết lập bán kính của nút
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white, // Đặt màu trắng cho icon
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget buildManagerOrderListView(BuildContext context, String statusFilter) {
    return FutureBuilder(
      future: _refreshOrders(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Consumer<OrdersManager>(
          builder: (ctx, ordersManager, child) {
            List<Order> filteredOrders = ordersManager.items
                .where((order) =>
                    statusFilter.isEmpty || order.status == statusFilter)
                .toList();
            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (ctx, i) {
                return Column(
                  children: [
                    ManagerOrderListTile(
                      filteredOrders[i],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildFilter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            child: Text(
              'Tất cả',
              style: TextStyle(
                  fontSize: 16), // Đặt kích thước font cho văn bản ở đây
            ),
          ),
          Tab(
            child: Text(
              'Chờ xác nhận',
              style: TextStyle(
                  fontSize: 16), // Đặt kích thước font cho văn bản ở đây
            ),
          ),
          Tab(
            child: Text(
              'Hoàn thành',
              style: TextStyle(
                  fontSize: 16), // Đặt kích thước font cho văn bản ở đây
            ),
          ),
        ],
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.blue,
      ),
    );
  }

  Widget buildOrderStats(BuildContext context) {
    _calculateOrderStats(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('$_totalOrders',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Text(
                'Tổng số đơn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          Column(
            children: [
              Text('$_pendingOrders',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Text(
                'Chờ duyệt',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
