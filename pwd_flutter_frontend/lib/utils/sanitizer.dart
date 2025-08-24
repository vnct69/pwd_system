// lib/utils/sanitizer.dart

String sanitizeInput(String input) {
  // 1. Strip HTML tags
  String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');

  // 2. Remove disallowed characters, but allow common ones for names/addresses
  final allowedPattern = RegExp(r"[^a-zA-Z0-9\s.,#/\-+']", unicode: true);
  sanitized = sanitized.replaceAll(allowedPattern, '');

  return sanitized.trim();
}
