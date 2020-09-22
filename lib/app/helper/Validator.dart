class Validator {
  static String email(String value) {
    value = value.trim();
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong!';
    if (!value.contains('@') || !value.contains('.'))
      return 'Format email harus benar!';
    return null;
  }
}
