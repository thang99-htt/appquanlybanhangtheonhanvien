import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../notifications/notifications_manager.dart';
import 'orders_manager.dart';
import '../shared/dialog_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UserAddOrderScreen extends StatefulWidget {
  static const routeName = '/user-add-order';

  final Product product;

  const UserAddOrderScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<UserAddOrderScreen> createState() => _UserAddOrderScreenState();
}

class _UserAddOrderScreenState extends State<UserAddOrderScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _addForm = GlobalKey<FormState>();
  late Order _addedOrder;
  var _isLoading = false;
  late IO.Socket socket;

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
    _addedOrder = Order(
        id: 0,
        userId: 0,
        totalValue: widget.product.priceSale,
        nameCustomer: '',
        phoneCustomer: '',
        addressCustomer: '',
        details: [],
        status: 'Chờ xử lý',
        products: [widget.product],
        orderedAt: DateTime.now());

    super.initState();

    socket = IO.io(
        'http://10.0.2.2:8000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
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

    setState(() {
      _isLoading = true;
    });

    try {
      final ordersManager = context.read<OrdersManager>();
      await ordersManager.addOrderUser(context, _addedOrder);

      var data = {
        "message": "vừa đặt hàng",
        "sendby": _addedOrder.nameCustomer,
        "date": (_addedOrder.orderedAt)?.toIso8601String()
      };

      socket.emit('message', data);
      final notificationsManager = context.read<NotificationsManager>();
      await notificationsManager.addNotificationAll(context, data);
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
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của bạn'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 56.0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _addForm,
                        child: Column(
                          children: <Widget>[
                            buildNameCutomerField(),
                            buildPhoneCustomerField(),
                            buildAddressCustomerField(),
                            const SizedBox(height: 20),
                            buildInfoProductField(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white, // Màu nền của container
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildTotalValueField(),
                        TextButton(
                          onPressed: _saveForm,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.blue), // Đổi màu ở đây
                          ),
                          child: const Text(
                            'MUA HÀNG',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  bool _isValidImageUrl(String value) {
    return (value.startsWith('http') || value.startsWith('https')) &&
        (value.endsWith('.png') ||
            value.endsWith('.jpg') ||
            value.endsWith('.jpeg'));
  }

  TextFormField buildNameCutomerField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Họ Tên *',
      ),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập họ tên.';
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
      decoration: const InputDecoration(labelText: 'Số điện thoại *'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập số điện thoại.';
        }
        return null;
      },
      onSaved: (value) {
        _addedOrder = _addedOrder.copyWith(phoneCustomer: value);
      },
    );
  }

  TextFormField buildAddressCustomerField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Địa chỉ *'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vui lòng nhập địa chỉ.';
        }
        return null;
      },
      onSaved: (value) {
        _addedOrder = _addedOrder.copyWith(addressCustomer: value);
      },
    );
  }

  Widget buildTotalValueField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('(1 sản phẩm)'),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(widget.product.priceSale),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ])
      ],
    );
  }

  Widget buildInfoProductField() {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: Image.network(
          widget.product.image,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(widget.product.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Giá bán: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.product.priceSale)}'),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Số lượng'),
            keyboardType: TextInputType.number,
            initialValue: '1',
            onChanged: (value) {},
            enabled: false,
          ),
        ],
      ),
    );
  }
}
