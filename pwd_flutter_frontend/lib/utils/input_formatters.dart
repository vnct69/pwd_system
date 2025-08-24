import 'package:flutter/services.dart';

/// Formats PWD ID into groups (2-4-3-7) with hyphens
class PwdIdInputFormatter extends TextInputFormatter {
  final List<int> groups = [2, 4, 3, 7];
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    var buffer = StringBuffer();
    int start = 0;

    for (var g in groups) {
      if (start >= filtered.length) break;
      final end = (start + g) <= filtered.length ? (start + g) : filtered.length;
      if (buffer.isNotEmpty) buffer.write('-');
      buffer.write(filtered.substring(start, end).toUpperCase());
      start = end;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
