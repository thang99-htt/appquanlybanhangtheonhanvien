import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'add_order_screen.dart';
import 'manager_order_list_tile.dart';
import 'orders_manager.dart';

class ManagerOrdersScreen extends StatelessWidget {
  static const routeName = '/manager-orders';
  const ManagerOrdersScreen({super.key});

  Future<void> _refreshUsers(BuildContext context) async {
    await context.read<OrdersManager>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('QL Đơn hàng'),
          actions: <Widget>[
            buildAddButton(context),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _refreshUsers(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _refreshUsers(context),
              child: buildManagerOrderListView(),
            );
          },
        ));
  }

  Widget buildManagerOrderListView() {
    return Consumer<OrdersManager>(
      builder: (ctx, ordersManager, child) {
        return ListView.builder(
          itemCount: ordersManager.itemCount,
          itemBuilder: (ctx, i) => Column(
            children: [
              ManagerOrderListTile(
                ordersManager.items[i],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget buildAddButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          AddOrderScreen.routeName,
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}
