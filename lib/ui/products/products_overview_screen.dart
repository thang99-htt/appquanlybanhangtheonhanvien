import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../screens.dart';
import 'products_grid.dart';
import '../shared/app_drawer.dart';

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  late Future<void> _fetchProducts;
  late List<Product> _filteredProducts;

  @override
  void initState() {
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
    _filteredProducts = []; // Khởi tạo _filteredProducts trống ban đầu
    _initializeFilteredProducts(); // Gọi hàm để cập nhật danh sách sản phẩm
    super.initState();
  }

  void _initializeFilteredProducts() {
    setState(() {
      _filteredProducts =
          context.read<ProductsManager>().items; // Cập nhật danh sách sản phẩm
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = context.read<ProductsManager>().items;
      } else {
        _filteredProducts =
            context.read<ProductsManager>().items.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: <Widget>[],
        iconTheme: const IconThemeData(color: Colors.white),
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
            onChanged: _searchProducts,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _fetchProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ProductsGrid(products: _filteredProducts);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
