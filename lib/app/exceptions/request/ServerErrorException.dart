import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';

class ServerErrorException implements GeneralException {
  final String errorCode;
  final String message;

  static List<int> httpCodes = [500, 502, 504];

  ServerErrorException(this.errorCode, this.message);

  @override
  String localize() => 'ServerErrorException';
}
