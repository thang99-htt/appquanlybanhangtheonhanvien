import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import 'products_manager.dart';
import '../shared/dialog_utils.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  final Product? product;

  const EditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;
  var _isLoading = false;

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
    _editedProduct = widget.product ??
        Product(
            id: null,
            name: '',
            description: '',
            image: '',
            pricePurchase: 0,
            priceSale: 0,
            quantity: 0,
            stock: 0,
            time: null);
    _imageUrlController.text = _editedProduct.image;
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
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

    try {
      final productsManager = context.read<ProductsManager>();
      if (_editedProduct.id != null) {
        await productsManager.updateProduct(_editedProduct);
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
        title: const Text('Edit Product'),
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
                key: _editForm,
                child: ListView(
                  children: <Widget>[
                    buildNameField(),
                    buildPricePurchaseField(),
                    buildPriceSaleField(),
                    buildQuantityField(),
                    buildDescriptionField(),
                    buildMomentField(context),
                    buildProductPreview(),
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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  TextFormField buildMomentField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _editedProduct.id != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_editedProduct.time!)
            : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      ),
      onTap: () {
        _selectDate(context);
        _selectTime(context);
      },
      decoration: const InputDecoration(
        labelText: 'Ngày giờ',
      ),
      onSaved: (value) {
        // Xử lý giá trị ngày giờ sau khi lưu
      },
    );
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

  TextFormField buildPricePurchaseField() {
    return TextFormField(
      initialValue: _editedProduct.pricePurchase.toString(),
      decoration: const InputDecoration(labelText: 'Giá nhập'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập giá nhập hàng.';
        }
        if (double.tryParse(value) == null) {
          return 'Giá nhập phải là số.';
        }
        if (double.parse(value) <= 0) {
          return 'Vui lòng nhập giá trị lớn hơn 0.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct =
            _editedProduct.copyWith(pricePurchase: int.parse(value!));
      },
    );
  }

  TextFormField buildPriceSaleField() {
    return TextFormField(
      initialValue: _editedProduct.priceSale.toString(),
      decoration: const InputDecoration(labelText: 'Giá bán'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập giá bán hàng.';
        }
        if (double.tryParse(value) == null) {
          return 'Giá bán phải là số.';
        }
        if (double.parse(value) <= 0) {
          return 'Vui lòng nhập giá trị lớn hơn 0.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(priceSale: int.parse(value!));
      },
    );
  }

  TextFormField buildQuantityField() {
    return TextFormField(
      initialValue: _editedProduct.quantity.toString(),
      decoration: const InputDecoration(labelText: 'Số lượng'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập số lượng.';
        }
        if (double.tryParse(value) == null) {
          return 'Số lượng phải là số.';
        }
        if (double.parse(value) <= 0) {
          return 'Vui lòng nhập giá trị lớn hơn 0.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(quantity: int.parse(value!));
      },
    );
  }

  TextFormField buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: const InputDecoration(labelText: 'Mô tả'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập mô tả.';
        }
        if (value.length < 10) {
          return 'Mô tả phải lớn hơn 10 ký tự.';
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
