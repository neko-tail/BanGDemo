import 'package:flutter/material.dart';

/// 普通输入框
InputDecoration simpleLabel(String label) {
  return InputDecoration(
    labelText: label,
  );
}

/// 带有 info 按钮的输入框
InputDecoration moreInfoLabel(BuildContext context, String label, String info) {
  return InputDecoration(
    labelText: label,
    suffixIcon: IconButton(
      icon: const Icon(Icons.info),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(label),
              content: Text(info),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("确定"),
                )
              ],
            );
          },
        );
      },
    ),
  );
}