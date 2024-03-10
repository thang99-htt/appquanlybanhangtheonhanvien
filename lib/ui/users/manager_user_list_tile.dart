import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'edit_user_screen.dart';
import 'user_detail_screen.dart';

class ManagerUserListTile extends StatelessWidget {
  final User user;
  const ManagerUserListTile(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Người quản lý: ${user.manager}',
                  style: const TextStyle(
                    color: Colors.grey,
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
          children: <Widget>[
            buildEditButton(context),
            buildDeleteButton(context),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => UserDetailScreen(user),
          ),
        );
      },
    );
  }

  Widget buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        print('Go to delete product screen');
        // context.read<ProductsManager>().deleteProduct(product.id!);
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Product deleted',
                textAlign: TextAlign.center,
              ),
            ),
          );
      },
      color: Theme.of(context).colorScheme.error,
    );
  }

  Widget buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context).pushNamed(
          EditUserScreen.routeName,
          arguments: user.id,
        );
      },
      color: Theme.of(context).primaryColor,
    );
  }
}
