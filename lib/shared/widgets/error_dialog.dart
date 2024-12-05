import 'package:flutter/material.dart';

/// 錯誤跳窗（有context）
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('確定'),
          ),
        ],
      );
    },
  );
}

/// 錯誤跳窗（沒有context）
void showDialogNC(String title, String message) {
  AlertDialog(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop;
        },
        child: const Text('確定'),
      ),
    ],
  );
}
