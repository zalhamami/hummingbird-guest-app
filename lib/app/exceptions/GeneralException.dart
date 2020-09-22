class GeneralException implements Exception {
  final String errorCode;
  final String message;

  static List<int> httpCodes;

  GeneralException(
    this.errorCode,
    this.message,
  );

  String localize() {
    if (errorCode == '400') return 'Authorization error';
    return '';
  }
}
