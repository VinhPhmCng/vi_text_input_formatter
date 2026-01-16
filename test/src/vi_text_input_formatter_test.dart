// Not required for test files

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_text_input_formatter/vi_text_input_formatter.dart';

void main() {
  group('ViTextInputFormatter', () {
    late ViTextInputFormatter formatter;

    setUp(() {
      formatter = ViTextInputFormatter();
    });

    test('correctly formats insertion', () {
      const oldValue = TextEditingValue(
        text: 'khóa',
        selection: TextSelection.collapsed(offset: 4),
      );
      const newValue = TextEditingValue(
        text: 'khóan',
        selection: TextSelection.collapsed(offset: 5),
      );
      const expectedValue = TextEditingValue(
        text: 'khoán',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result, equals(expectedValue));
    });

    test('correctly formats deletion', () {
      const oldValue = TextEditingValue(
        text: 'khoán',
        selection: TextSelection.collapsed(offset: 5),
      );
      const newValue = TextEditingValue(
        text: 'khoá',
        selection: TextSelection.collapsed(offset: 4),
      );
      const expectedValue = TextEditingValue(
        text: 'khóa',
        selection: TextSelection.collapsed(offset: 4),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result, equals(expectedValue));
    });
  });
}
