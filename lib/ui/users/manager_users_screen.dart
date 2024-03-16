import 'package:flutter/cupertino.dart';
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
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'QL Người dùng',
          style: TextStyle(color: Colors.white),
        ),
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
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              EditUserScreen.routeName,
            );
          },
          backgroundColor: Colors.blue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30), // Thiết lập bán kính của nút
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white, // Đặt màu trắng cho icon
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
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
}
