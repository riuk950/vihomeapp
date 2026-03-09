import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

class BtnSecundary extends StatelessWidget {
  final String text;
  final String phone;
  final String message;
  const BtnSecundary({
    super.key,
    required this.text,
    required this.phone,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final text = Uri.encodeComponent(message);
        final url = Uri.parse("https://wa.me/$phone?text=$text");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(Icons.chat_outlined, size: 18),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
