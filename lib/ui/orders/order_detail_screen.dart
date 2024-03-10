import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  static const routeName = '/order-detail';
  final Order order;

  const OrderDetailScreen(
    this.order, {
    Key? key,
  }) : super(key: key);

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
              _buildDetailText('Mã Đơn hàng: ', '${order.id}'),
              const SizedBox(height: 10),
              _buildDetailText('Nhân viên: ', '${order.userName}'),
              const SizedBox(height: 10),
              _buildDetailText(
                  'Ngày đặt: ',
                  order.orderedAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(order.orderedAt!)
                      : ''),
              const SizedBox(height: 10),
              _buildDetailText(
                  'Ngày nhận: ',
                  order.receivedAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(order.receivedAt!)
                      : ''),
              const SizedBox(height: 10),
              _buildDetailText(
                  'Tổng giá trị: ',
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(order.totalValue)),
              const SizedBox(height: 10),
              _buildDetailText('Người nhận: ', order.nameCustomer),
              const SizedBox(height: 10),
              _buildDetailText('Số điện thoại: ', order.phoneCustomer),
              const SizedBox(height: 10),
              _buildDetailText('Địa chỉ: ', order.addressCustomer ?? ''),
              const SizedBox(height: 10),
              _buildDetailText('Trạng thái: ', order.status ?? ''),
              const SizedBox(height: 20),
              const Text(
                'Chi tiết đơn hàng:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.details.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      'Sản phẩm: ${order.details[index].productName}', // Thay đổi thành tên sản phẩm
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order.details[index].price)} - Số lượng: ${order.details[index].quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    leading: Image.network(order
                        .details[index].productImage), // Thêm hình ảnh sản phẩm
                  );
                },
              ),
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
}
