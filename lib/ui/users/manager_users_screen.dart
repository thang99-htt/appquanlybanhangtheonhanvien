import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'edit_user_screen.dart';
import 'manager_user_list_tile.dart';
import 'users_manager.dart';

class ManagerUsersScreen extends StatelessWidget {
  static const routeName = '/manager-users';
  const ManagerUsersScreen({super.key});

  Future<void> _refreshUsers(BuildContext context) async {
    await context.read<UsersManager>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('QL Người dùng'),
          actions: <Widget>[
            buildAddButton(context),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _refreshUsers(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _refreshUsers(context),
              child: buildManagerUserListView(),
            );
          },
        ));
  }

  Widget buildManagerUserListView() {
    return Consumer<UsersManager>(
      builder: (ctx, usersManager, child) {
        return ListView.builder(
          itemCount: usersManager.itemCount,
          itemBuilder: (ctx, i) => Column(
            children: [
              ManagerUserListTile(
                usersManager.items[i],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget buildAddButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          EditUserScreen.routeName,
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}