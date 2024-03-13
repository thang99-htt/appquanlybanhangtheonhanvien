import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../notifications/notifications_manager.dart'; // Import NotificationsManager
import '../orders/manager_orders_screen.dart';

class NotificationListTile extends StatelessWidget {
  final Notifications notification;
  const NotificationListTile(
    this.notification, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng thời gian
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () async {
            final notificationsManager = context.read<NotificationsManager>();
            await notificationsManager.updateNotification(
                context, notification.id!); // Cập nhật trạng thái thông báo
            Navigator.of(context)
                .pushReplacementNamed(ManagerOrdersScreen.routeName);
          },
          tileColor: notification.readed == 1
              ? Colors.white
              : const Color.fromARGB(255, 209, 226, 235),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${notification.sendby}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        width: 8), // Khoảng cách giữa sendby và message
                    Text(
                      '${notification.message}',
                    ),
                  ],
                ),
              ),
              Text(
                notification.date != null
                    ? timeAgo(notification.date!)
                    : 'Không có ngày',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
