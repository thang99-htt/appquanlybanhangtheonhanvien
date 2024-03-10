import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'product_detail_screen.dart';

class ProductGridTile extends StatelessWidget {
  const ProductGridTile(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: buildGridFooterBar(context),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product),
              ),
            );
          },
          child: Image.network(
            product.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildGridFooterBar(BuildContext context) {
    return GridTileBar(
      backgroundColor: Colors.black87,
      title: Text(
        product.name,
        textAlign: TextAlign.left,
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.shopping_cart,
        ),
        onPressed: () {
          print('add item to cart');
          // final cart = context.read<CartManager>();
          // cart.addItem(product);
          // ScaffoldMessenger.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(
          //     SnackBar(
          //       content: const Text(
          //         'Item added to cart',
          //       ),
          //       duration: const Duration(seconds: 2),
          //       action: SnackBarAction(
          //         label: 'UNDO',
          //         onPressed: () {
          //           cart.removeSingleItem(product.id!);
          //         },
          //       ),
          //     ),
          //   );
        },
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
