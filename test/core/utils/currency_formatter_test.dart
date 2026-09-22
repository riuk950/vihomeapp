import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  group('CurrencyFormatter [RF-10.1]', () {
    test('should format integer to COP currency string with symbol', () {
      expect(CurrencyFormatter.formatCOP(2500000), equals('\$ 2.500.000'));
      expect(CurrencyFormatter.formatCOP(0), equals('\$ 0'));
      expect(CurrencyFormatter.formatCOP(100), equals('\$ 100'));
      expect(CurrencyFormatter.formatCOP(123456789), equals('\$ 123.456.789'));
    });

    test('should format number without symbol', () {
      expect(CurrencyFormatter.formatNumber(2500000), equals('2.500.000'));
      expect(CurrencyFormatter.formatNumber(0), equals('0'));
    });

    test('should parse formatted string back to clean int', () {
      expect(CurrencyFormatter.parseCOP('\$ 2.500.000'), equals(2500000));
      expect(CurrencyFormatter.parseCOP('2.500.000'), equals(2500000));
      expect(CurrencyFormatter.parseCOP(''), equals(0));
      expect(CurrencyFormatter.parseCOP('abc'), equals(0));
    });

    test('should throw or return 0 for negative values gracefully', () {
      expect(CurrencyFormatter.formatCOP(-500), equals('\$ 0'));
      expect(CurrencyFormatter.parseCOP('-500.000'), equals(0));
    });

    test('CurrencyTextInputFormatter formats text input in real-time', () {
      final formatter = CurrencyTextInputFormatter();
      
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '2500000',
        selection: TextSelection.collapsed(offset: 7),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('2.500.000'));
      expect(result.selection.baseOffset, equals(result.text.length));
    });

    test('CurrencyTextInputFormatter strips non-digit characters', () {
      final formatter = CurrencyTextInputFormatter();
      
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '2a5b0c0d',
        selection: TextSelection.collapsed(offset: 8),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('2.500'));
    });
  });
}
