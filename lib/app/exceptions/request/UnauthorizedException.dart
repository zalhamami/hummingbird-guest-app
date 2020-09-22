import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';

class UnauthorizedException implements GeneralException {
  final String message;
  final String errorCode;

  UnauthorizedException({
    this.errorCode,
    this.message,
  });

  static List<int> httpCodes = [401];

  @override
  String localize() => 'UnauthorizedException';
}
