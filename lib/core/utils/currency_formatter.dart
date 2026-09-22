import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utilitario para formateo de moneda colombiana (COP) [RF-10.1]
class CurrencyFormatter {
  static final NumberFormat _copFormat = NumberFormat('#,##0', 'es_CO');

  /// Formatea un número como pesos colombianos con símbolo: `$ 2.500.000`
  static String formatCOP(num value) {
    if (value < 0) return '\$ 0';
    final formatted = _copFormat.format(value).replaceAll(',', '.');
    return '\$ $formatted';
  }

  /// Formatea un número solo con separador de miles: `2.500.000`
  static String formatNumber(num value) {
    if (value < 0) return '0';
    return _copFormat.format(value).replaceAll(',', '.');
  }

  /// Convierte una cadena formateada (`$ 2.500.000` o `2.500.000`) a un entero limpio
  static int parseCOP(String text) {
    if (text.contains('-')) return 0;
    final clean = text.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return 0;
    return int.tryParse(clean) ?? 0;
  }
}

/// Formateador para campos de texto interactivos que añade separadores de miles en tiempo real
class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly) ?? 0;
    final formatted = CurrencyFormatter.formatNumber(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
