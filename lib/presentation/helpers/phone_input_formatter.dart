import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    if (newText.isEmpty) return newValue;

    // Extraer solo los números
    String digits = newText.replaceAll(RegExp(r'\D'), '');

    // Asegurar prefijo 57
    if (digits.isNotEmpty) {
      if (!digits.startsWith('57')) {
        if (digits.startsWith('5')) {
          digits = '57${digits.substring(1)}';
        } else {
          digits = '57$digits';
        }
      }
    }

    final buffer = StringBuffer();
    int selectionIndex = 0;

    // Determinar cuántos dígitos había antes del cursor en el texto ingresado
    int digitsBeforeCursor = newValue.text
        .substring(0, newValue.selection.end)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Si el texto original no tenía el 57 y se lo agregamos,
    // desplazamos los dígitos antes del cursor.
    final originalDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (originalDigits.isNotEmpty && !originalDigits.startsWith('57')) {
      if (originalDigits.startsWith('5')) {
        digitsBeforeCursor += 1;
      } else {
        digitsBeforeCursor += 2;
      }
    }

    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 8) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
      if (i + 1 == digitsBeforeCursor) {
        selectionIndex = buffer.length;
      }
    }

    // Asegurar que el índice de selección no exceda el largo del texto
    if (selectionIndex > buffer.length) {
      selectionIndex = buffer.length;
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
