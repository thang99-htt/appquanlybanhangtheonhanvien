import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/app_drawer.dart';
import 'notification_list_tile.dart';
import 'notifications_manager.dart';

class NotificationsOverviewScreen extends StatelessWidget {
  static const routeName = '/manager-notifications';
  const NotificationsOverviewScreen({super.key});

  Future<void> _refreshNotifications(BuildContext context) async {
    await context.read<NotificationsManager>().fetchNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _refreshNotifications(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _refreshNotifications(context),
              child: buildNotificationListView(),
            );
          },
        ));
  }

  Widget buildNotificationListView() {
    return Consumer<NotificationsManager>(
      builder: (ctx, notificationsManager, child) {
        return ListView.builder(
          itemCount: notificationsManager.itemCount,
          itemBuilder: (ctx, i) => Column(
            children: [
              NotificationListTile(
                notificationsManager.items[i],
              ),
            ],
          ),
        );
      },
    );
  }
}
