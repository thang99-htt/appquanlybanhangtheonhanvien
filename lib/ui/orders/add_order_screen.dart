import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import 'orders_manager.dart';
import '../shared/dialog_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AddOrderScreen extends StatefulWidget {
  static const routeName = '/add-order';

  final Order? order;

  const AddOrderScreen({Key? key, this.order}) : super(key: key);

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _addForm = GlobalKey<FormState>();
  late Order _addedOrder;
  var _isLoading = false;
  List<Product> _selectedProducts = [];
  late List<Product> _allProducts = [];
  @override
  void initState() {
    _imageUrlFocusNode.addListener(() {
      if (!_imageUrlFocusNode.hasFocus) {
        if (!_isValidImageUrl(_imageUrlController.text)) {
          return;
        }
        setState(() {});
      }
    });
    _addedOrder = widget.order ??
        Order(
            id: 0,
            userId: 0,
            orderedAt: DateTime.now(),
            totalValue: 0,
            nameCustomer: '',
            phoneCustomer: '',
            addressCustomer: '',
            details: [],
            status: 'Chờ xử lý',
            products: []);
    super.initState();
    _fetchAllProducts();
  }

  void _fetchAllProducts() async {
    const url = 'http://10.0.2.2:8000/api/products';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _allProducts = responseData.map((data) {
          return Product(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            image: data['image'],
            stock: data['stock'],
            priceSale: data['price_sale'],
            pricePurchase: data['price_purchase'],
            quantity: 1,
            time: data['time'] != null ? DateTime.parse(data['time']) : null,
          );
        }).toList();
        setState(() {});
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _addForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _addForm.currentState!.save();

    int totalValue = 0;
    for (var product in _selectedProducts) {
      totalValue += product.priceSale * product.quantity;
    }

    // Cập nhật tổng giá trị cho đơn hàng
    _addedOrder = _addedOrder.copyWith(totalValue: totalValue);

    _addedOrder = _addedOrder.copyWith(products: _selectedProducts);

    setState(() {
      _isLoading = true;
    });

    try {
      final ordersManager = context.read<OrdersManager>();
      await ordersManager.addOrder(_addedOrder);
    } catch (error) {
      await showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm đơn hàng'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _addForm,
                child: ListView(
                  children: <Widget>[
                    buildNameCutomerField(),
                    buildPhoneCustomerField(),
                    const SizedBox(height: 20),
                    buildTotalValueField(),
                    const SizedBox(height: 20),
                    buildProductSelectionList(),
                  ],
                ),
              ),
            ),
    );
  }

  bool _isValidImageUrl(String value) {
    return (value.startsWith('http') || value.startsWith('https')) &&
        (value.endsWith('.png') ||
            value.endsWith('.jpg') ||
            value.endsWith('.jpeg'));
  }

  TextFormField buildNameCutomerField() {
    return TextFormField(
      initialValue: _addedOrder.nameCustomer,
      decoration: const InputDecoration(labelText: 'Tên khách hàng'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập tên khách hàng.';
        }
        return null;
      },
      onSaved: (value) {
        _addedOrder = _addedOrder.copyWith(nameCustomer: value);
      },
    );
  }

  TextFormField buildPhoneCustomerField() {
    return TextFormField(
      initialValue: _addedOrder.phoneCustomer,
      decoration: const InputDecoration(labelText: 'Số điện thoại'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập số điện thoại khách hàng.';
        }
        return null;
      },
      onSaved: (value) {
        _addedOrder = _addedOrder.copyWith(phoneCustomer: value);
      },
    );
  }

  Widget buildTotalValueField() {
    int totalValue = 0;
    for (var product in _selectedProducts) {
      totalValue += product.priceSale * product.quantity;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tổng giá trị:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
              .format(totalValue),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget buildProductSelectionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn sản phẩm:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _allProducts.length,
          itemBuilder: (context, index) {
            final product = _allProducts[index];
            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Giá bán: ${product.priceSale}'),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    onChanged: (value) {
                      // Chuyển đổi giá trị từ String sang int trước khi gán cho quantity
                      product.quantity = int.parse(value);
                    },
                  ),
                ],
              ),
              trailing: Checkbox(
                value: _selectedProducts.contains(product),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedProducts.add(product);
                    } else {
                      _selectedProducts.remove(product);
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
