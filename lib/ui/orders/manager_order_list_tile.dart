import 'package:flutter/material.dart';
import 'order_detail_screen.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';

class ManagerOrderListTile extends StatelessWidget {
  final Order order;
  const ManagerOrderListTile(
    this.order, {
    super.key,
  });

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color topLeftBorderColor =
        Color.fromARGB(255, 229, 229, 229); // Mặc định màu grey cho góc trái
    Color borderColor = Color.fromARGB(
        255, 229, 229, 229); // Mặc định màu grey cho toàn bộ viền

    // Thiết lập màu cho góc trái dựa trên trạng thái của đơn hàng
    if (order.status == "Hoàn thành") {
      topLeftBorderColor =
          Color.fromARGB(255, 0, 161, 5); // Màu xanh lá cho hoàn thành
    } else if (order.status == "Chờ xác nhận") {
      topLeftBorderColor =
          Color.fromARGB(255, 227, 0, 0); // Màu đỏ cho chờ xác nhận
    } else if (order.status == "Đã xác nhận") {
      topLeftBorderColor =
          Color.fromARGB(255, 224, 190, 21); // Màu vàng cho đã xử lý
    } else if (order.status == "Bán tại cửa hàng") {
      topLeftBorderColor =
          Color.fromARGB(255, 75, 0, 140); // Màu tím cho bán tại cửa hàng
    }

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Khoảng cách giữa các mục
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 237, 237, 237)
                .withOpacity(0.5), // Màu và độ trong suốt của shadow
            spreadRadius: 2, // Bán kính lan truyền của shadow
            blurRadius: 5, // Bán kính mờ của shadow
            offset: Offset(0, 8), // Độ dịch chuyển của shadow
          ),
        ],
        border: Border.all(color: borderColor), // Viền toàn bộ với màu grey
        borderRadius: BorderRadius.circular(10.0), // Góc cong cho Container
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                color: topLeftBorderColor,
                width: 5.0), // Viền bên trái với màu tương ứng
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
          title: Row(
            children: <Widget>[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '#${order.id}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(order.totalValue),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.nameCustomer,
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.status}',
                    style: TextStyle(color: topLeftBorderColor),
                  ),
                  const SizedBox(
                      height:
                          20), // Khoảng cách giữa văn bản "status" và "time"
                  Text(
                    timeAgo(order.orderedAt!),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 83, 83, 83),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => OrderDetailScreen(order),
              ),
            );
          },
        ),
      ),
    );
  }
}
