import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';

class InvalidRequestException implements GeneralException {
  final String message;
  final String errorCode;

  InvalidRequestException(
    this.errorCode,
    this.message,
  );

  static List<int> httpCodes = [400, 404, 409];

  @override
  String localize() {
    if (errorCode == '400') return 'Authorization error';
    return '';
  }
}
