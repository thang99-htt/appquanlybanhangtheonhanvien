import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import 'product_grid_tile.dart';
import 'products_manager.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsManager = ProductsManager();
    final products = context.select<ProductsManager, List<Product>>(
        (productsManager) => productsManager.items);

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductGridTile(products[i]),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
