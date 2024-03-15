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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders(BuildContext context) async {
    await context.read<OrdersManager>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Đơn hàng'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AddOrderScreen.routeName,
          );
        },
        backgroundColor: Colors.blue, // Màu nền xanh
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: SizedBox(height: 40), // Đặt chiều cao của bottomAppBar
      ),
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
                    const Divider(),
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
          Tab(text: 'Tất cả'),
          Tab(text: 'Chờ xác nhận'),
          Tab(text: 'Hoàn thành'),
        ],
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.blue,
      ),
    );
  }
}
