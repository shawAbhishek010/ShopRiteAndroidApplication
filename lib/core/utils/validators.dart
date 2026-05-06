class Validators {
  const Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = required(value, fieldName: 'Email');
    if (requiredMessage != null) return requiredMessage;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = required(value, fieldName: 'Password');
    if (requiredMessage != null) return requiredMessage;

    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
