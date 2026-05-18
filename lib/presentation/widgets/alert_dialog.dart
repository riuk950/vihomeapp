import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

class AlertDialogWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String cancelText;
  final String acceptText;

  const AlertDialogWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.acceptText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText, style: TextStyle(color: primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(acceptText),
        ),
      ],
    );
  }
}
