import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import 'orders_manager.dart';

class OrderDetailScreen extends StatefulWidget {
  static const routeName = '/order-detail';
  final Order order;

  const OrderDetailScreen(
    this.order, {
    Key? key,
  }) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _currentStatus;
  late Order _addedOrder;

  @override
  void initState() {
    _addedOrder = Order(
        id: widget.order.id,
        userId: 0,
        status: '',
        details: [],
        nameCustomer: '',
        phoneCustomer: '',
        products: [],
        totalValue: 0);
    _currentStatus = widget.order.status ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              _buildDetailText('Mã Đơn hàng: ', '${widget.order.id}'),
              const SizedBox(height: 10),
              _buildStatusDropdown(),
              const SizedBox(height: 10),
              _buildDetailText('Nhân viên: ', '${widget.order.userName}'),
              const SizedBox(height: 10),
              const Divider(),
              _buildDetailText(
                  'Ngày đặt: ',
                  widget.order.orderedAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(widget.order.orderedAt!)
                      : ''),
              const SizedBox(height: 10),
              _buildDetailText(
                  'Ngày nhận: ',
                  widget.order.receivedAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(widget.order.receivedAt!)
                      : ''),
              const Divider(),
              const SizedBox(height: 10),
              _buildDetailText('Người nhận: ', widget.order.nameCustomer),
              const SizedBox(height: 10),
              _buildDetailText('Số điện thoại: ', widget.order.phoneCustomer),
              const SizedBox(height: 10),
              _buildDetailText('Địa chỉ: ', widget.order.addressCustomer ?? ''),
              const SizedBox(height: 20),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.details.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      widget.order.details[index]
                          .productName, // Thay đổi thành tên sản phẩm
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.order.details[index].price)} x ${widget.order.details[index].quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    leading: Image.network(widget.order.details[index]
                        .productImage), // Thêm hình ảnh sản phẩm
                  );
                },
              ),
              const SizedBox(height: 30),
              _buildDetailText(
                  'Tổng giá trị: ',
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(widget.order.totalValue)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Row(
      children: [
        const Text(
          'Trạng thái: ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _currentStatus,
          onChanged: (String? newValue) async {
            setState(() {
              _currentStatus = newValue!;
              _addedOrder = _addedOrder.copyWith(status: _currentStatus);
            });

            final ordersManager = context.read<OrdersManager>();
            await ordersManager.updateStatusOrder(context, _addedOrder);
            setState(() {
              widget.order.updateStatus(_currentStatus);
            });
          },
          items: <String>['Chờ xác nhận', 'Đã xác nhận', 'Hoàn thành']
              .map<DropdownMenuItem<String>>((String value) {
            Color? textColor;
            switch (value) {
              case 'Chờ xác nhận':
                textColor = const Color.fromARGB(255, 226, 1, 1);
                break;
              case 'Đã xác nhận':
                textColor = const Color.fromARGB(
                    255, 220, 176, 0); // Màu xanh cho trạng thái đã xác nhận
                break;
              case 'Hoàn thành':
                textColor = const Color.fromARGB(255, 0, 179,
                    6); // Màu xanh lá cây cho trạng thái hoàn thành
                break;
              default:
                textColor = Colors.black; // Màu mặc định
            }
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: textColor),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
