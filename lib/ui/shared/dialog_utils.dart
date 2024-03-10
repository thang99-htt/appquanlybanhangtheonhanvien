import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, String message){
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Bạn có chắc?'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('Không'),
          onPressed: (){
            Navigator.of(ctx).pop(false);
          },
        ),
        TextButton(
            onPressed: (){
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Có'),
        ),
      ],
    ),
  );
}

Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Có lỗi xảy ra!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Đồng ý'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }