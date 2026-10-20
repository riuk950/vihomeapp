import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

class AlertDialogWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String cancelText;
  final String acceptText;
  final bool isDestructive;

  const AlertDialogWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.acceptText,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: isDestructive ? Colors.red : primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: isDestructive ? Colors.grey[700] : primaryColor),
          ),
        ),
        ElevatedButton(
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(acceptText),
        ),
      ],
    );
  }
}
