import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../orders/user_add_order_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  const ProductDetailScreen(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mã Sản phẩm: ${product.id}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 111, 111, 111),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                            .format(product.priceSale),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Có sẵn: ${product.stock}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 111, 111, 111),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Mô tả:'),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white, // Màu nền của button
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    UserAddOrderScreen.routeName,
                    arguments: product,
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.blue), // Đổi màu ở đây
                ),
                child: const Text(
                  'MUA NGAY',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
