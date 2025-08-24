//lib/utils/sanitized_text_form_field.dart

import 'package:flutter/material.dart';
import 'sanitizer.dart'; // sanitizer function

class SanitizedTextFormField extends StatelessWidget {
  final String? labelText;
  final String? initialValue;
  final String? hintText;
  final Function(String?) onSaved;
  final Function(String) onChanged;
  final String? Function(String?)? validator;

  const SanitizedTextFormField({
    super.key,
    this.labelText,
    this.initialValue,
    required this.hintText,
    required this.onSaved,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ),
      onChanged: (val) => onChanged(sanitizeInput(val)),
      onSaved: (val) => onSaved(val != null ? sanitizeInput(val) : null),
      validator: validator,
    );
  }
}
