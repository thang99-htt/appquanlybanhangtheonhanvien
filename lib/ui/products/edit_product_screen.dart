import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/purchase_info.dart';
import '../../models/sale_info.dart';
import 'products_manager.dart';
import '../shared/dialog_utils.dart';
import 'salesinfo_manager.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  final Product? product;

  const EditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with SingleTickerProviderStateMixin {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;
  var _isLoading = false;
  late TabController _tabController;
  late PurchasesInfo _purchaseInfo;
  late SalesInfo _saleInfo;
  int? _selectedSaleIndex;
  late SalesInfo _updateSaleInfo;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _imageUrlFocusNode.addListener(() {
      if (!_imageUrlFocusNode.hasFocus) {
        if (!_isValidImageUrl(_imageUrlController.text)) {
          return;
        }
        setState(() {});
      }
    });
    _editedProduct = widget.product ??
        Product(
          id: null,
          name: '',
          description: '',
          image: '',
          purchasesInfo: [],
          purchaseInfo: [],
          salesInfo: [],
          saleInfo: [],
        );
    _imageUrlController.text = _editedProduct.image;
    _purchaseInfo = PurchasesInfo(price: 0, time: DateTime.now(), quantity: 0);
    _saleInfo = SalesInfo(price: 0, time: DateTime.now(), checked: 0);
    _updateSaleInfo =
        SalesInfo(productId: 0, price: 0, time: DateTime.now(), checked: 0);

    super.initState();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    // Handle tab selection
  }
  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    _editedProduct = _editedProduct.copyWith(purchaseInfo: [_purchaseInfo]);
    _editedProduct = _editedProduct.copyWith(saleInfo: [_saleInfo]);

    try {
      final productsManager = context.read<ProductsManager>();
      final salesInfoManager = context.read<SalesInfoManager>();

      if (_editedProduct.id != null) {
        if (_tabController.index == 0) {
          await productsManager.updateProduct(_editedProduct);
        } else if (_tabController.index == 1) {
          await productsManager.updateProductPricePurchase(_editedProduct);
        } else if (_tabController.index == 2) {
          if (_saleInfo.price != 0) {
            await productsManager.updateProductPriceSale(_editedProduct);
          } else {
            await salesInfoManager.updateChecked(context, _updateSaleInfo);
          }
        }
      } else {
        await productsManager.addProduct(_editedProduct);
      }
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
        title: const Text('Sản phẩm'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Giá nhập'),
            Tab(text: 'Giá bán'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _editForm,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildInfoTab(),
                    buildPurchasePriceTab(),
                    buildSalePriceTab(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildInfoTab() {
    return ListView(
      children: <Widget>[
        buildNameField(),
        const SizedBox(height: 8),
        buildDescriptionField(),
        buildProductPreview(),
      ],
    );
  }

  Widget buildPurchasePriceTab() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Giá nhập'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập giá nhập';
              }
              return null;
            },
            onSaved: (value) {
              // Lưu giá nhập vào _purchaseInfo
              _purchaseInfo = _purchaseInfo.copyWith(price: int.parse(value!));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Thời gian nhập'),
            keyboardType: TextInputType.datetime,
            readOnly: true, // To show the date picker
            controller: TextEditingController(
              text: DateFormat('dd/MM/yyyy HH:mm').format(_purchaseInfo.time),
            ),
            onTap: () async {
              final DateTime? pickedDateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDateTime != null) {
                // ignore: use_build_context_synchronously
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _purchaseInfo = _purchaseInfo.copyWith(
                      time: DateTime(
                        pickedDateTime.year,
                        pickedDateTime.month,
                        pickedDateTime.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ),
                    );
                  });
                }
              }
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _purchaseInfo = _purchaseInfo.copyWith(time: _purchaseInfo.time);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Số lượng nhập'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số lượng nhập';
              }
              return null;
            },
            onSaved: (value) {
              // Lưu số lượng nhập vào _purchaseInfo
              _purchaseInfo =
                  _purchaseInfo.copyWith(quantity: int.parse(value!));
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Lịch sử giá nhập:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _editedProduct.purchasesInfo?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final purchaseIfo = _editedProduct.purchasesInfo?[index];
                return ListTile(
                  title: Text(
                      'Giá nhập: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(purchaseIfo?.price)}'),
                  subtitle: purchaseIfo != null
                      ? Text(
                          'Ngày nhập: ${DateFormat('dd/MM/yyyy HH:mm').format(purchaseIfo.time)} - Số lượng: ${purchaseIfo.quantity}')
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSalePriceTab() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Giá bán'),
            keyboardType: TextInputType.number,
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              if (value != null && value.isNotEmpty) {
                _saleInfo = _saleInfo.copyWith(price: int.parse(value));
              } else {
                _saleInfo = _saleInfo.copyWith(price: 0);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Thời gian bán'),
            keyboardType: TextInputType.datetime,
            readOnly: true, // To show the date picker
            controller: TextEditingController(
              text: DateFormat('dd/MM/yyyy HH:mm').format(_saleInfo.time),
            ),
            onTap: () async {
              final DateTime? pickedDateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDateTime != null) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _saleInfo = _saleInfo.copyWith(
                      time: DateTime(
                        pickedDateTime.year,
                        pickedDateTime.month,
                        pickedDateTime.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ),
                    );
                  });
                }
              }
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _saleInfo = _saleInfo.copyWith(time: _saleInfo.time);
            },
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            'Lịch sử giá bán:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _editedProduct.salesInfo?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final saleInfo = _editedProduct.salesInfo?[index];
                final bool isChecked = saleInfo?.checked == 1;
                if (isChecked && _selectedSaleIndex == null) {
                  _selectedSaleIndex = index;
                }
                final productId = _editedProduct
                    .salesInfo?[_selectedSaleIndex ?? 0].productId;
                final time =
                    _editedProduct.salesInfo?[_selectedSaleIndex ?? 0].time;
                final price =
                    _editedProduct.salesInfo?[_selectedSaleIndex ?? 0].price;
                final checked =
                    _editedProduct.salesInfo?[_selectedSaleIndex ?? 0].checked;

                _updateSaleInfo = _updateSaleInfo.copyWith(
                    productId: productId,
                    time: time,
                    price: price,
                    checked: checked);
                return ListTile(
                  title: Text(
                      'Giá bán: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(saleInfo?.price)}'),
                  subtitle: saleInfo != null
                      ? Text(
                          'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(saleInfo.time)}')
                      : null,
                  trailing: isChecked
                      ? Radio<int>(
                          value: index,
                          groupValue: _selectedSaleIndex,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedSaleIndex = value;
                            });
                          },
                        )
                      : Radio<int>(
                          // Radio không được kiểm tra nếu điều kiện không đúng
                          value: index,
                          groupValue: _selectedSaleIndex,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedSaleIndex = value;
                            });
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidImageUrl(String value) {
    return (value.startsWith('http') || value.startsWith('https')) &&
        (value.endsWith('.png') ||
            value.endsWith('.jpg') ||
            value.endsWith('.jpeg'));
  }

  TextFormField buildNameField() {
    return TextFormField(
      initialValue: _editedProduct.name,
      decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập tên sản phẩm.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(name: value);
      },
    );
  }

  TextFormField buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: const InputDecoration(labelText: 'Mô tả'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập mô tả sản phẩm.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(description: value);
      },
    );
  }

  Widget buildProductPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(
            top: 8,
            right: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _imageUrlController.text.isEmpty
              ? const Text('URL')
              : FittedBox(
                  child: Image.network(
                    _imageUrlController.text,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Expanded(
          child: buildImageURLField(),
        ),
      ],
    );
  }

  TextFormField buildImageURLField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Hình ảnh'),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      controller: _imageUrlController,
      focusNode: _imageUrlFocusNode,
      onFieldSubmitted: (value) => _saveForm(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập đường dẫn hình ảnh.';
        }
        if (!_isValidImageUrl(value)) {
          return 'Vui lòng nhập đường dẫn hợp lệ.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(image: value);
      },
    );
  }
}
