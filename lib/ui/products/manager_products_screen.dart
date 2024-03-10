import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'edit_product_screen.dart';
import 'manager_product_list_tile.dart';
import 'products_manager.dart';

class ManagerProductsScreen extends StatelessWidget {
  static const routeName = '/manager-products';
  const ManagerProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await context.read<ProductsManager>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('QL Sản phẩm'),
          actions: <Widget>[
            buildAddButton(context),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: buildManagerProductListView(),
            );
          },
        ));
  }

  Widget buildManagerProductListView() {
    return Consumer<ProductsManager>(
      builder: (ctx, productsManager, child) {
        return ListView.builder(
          itemCount: productsManager.itemCount,
          itemBuilder: (ctx, i) => Column(
            children: [
              ManagerProductListTile(
                productsManager.items[i],
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
          EditProductScreen.routeName,
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}
