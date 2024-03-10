import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';

class ManagerProductDetailScreen extends StatelessWidget {
  static const routeName = '/manager-product-detail';
  const ManagerProductDetailScreen(
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
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Mã Sản phẩm: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${product.id}',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Còn lại: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${product.stock}',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Giá nhập: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.pricePurchase)}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Giá bán: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.priceSale)}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.description,
                  textAlign: TextAlign.left,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ])));
  }
}
