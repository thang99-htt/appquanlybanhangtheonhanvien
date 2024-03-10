import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens.dart';
import 'products_grid.dart';
import '../shared/app_drawer.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  late Future<void> _fetchProducts;

  @override
  void initState() {
    super.initState();
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katec'),
        actions: <Widget>[
          buildShoppingCartIcon(),
        ],
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

  Widget buildShoppingCartIcon() {
    return IconButton(
      icon: const Icon(
        Icons.shopping_cart,
      ),
      onPressed: () {
        print('go to cart screen');
      },
    );
  }
}
