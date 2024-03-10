import 'package:flutter/material.dart';
import 'order_detail_screen.dart';
import 'orders_manager.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';

class ManagerOrderListTile extends StatelessWidget {
  final Order order;
  const ManagerOrderListTile(
    this.order, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white; // Mặc định màu trắng

    // Kiểm tra trạng thái của đơn hàng
    if (order.status == "Hoàn Thành") {
      backgroundColor = const Color.fromARGB(
          255, 217, 253, 218); // Đặt màu xanh lá cho đơn hàng hoàn thành
    }

    if (order.status == "Chờ xác nhận") {
      backgroundColor = const Color.fromARGB(
          255, 253, 217, 217); // Đặt màu xanh lá cho đơn hàng hoàn thành
    }

    if (order.status == "Đã xử lý") {
      backgroundColor = const Color.fromARGB(
          255, 253, 249, 217); // Đặt màu xanh lá cho đơn hàng hoàn thành
    }

    if (order.status == "Bán tại cửa hàng") {
      backgroundColor = const Color.fromARGB(
          255, 238, 219, 255); // Đặt màu xanh lá cho đơn hàng hoàn thành
    }

    return Container(
      color: backgroundColor, // Sử dụng màu nền được xác định
      child: ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Mã đơn hàng: ${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy HH:mm:ss').format(order.orderedAt!),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 83, 83, 83),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(order.totalValue),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => OrderDetailScreen(order),
            ),
          );
        },
      ),
    );
  }
}
