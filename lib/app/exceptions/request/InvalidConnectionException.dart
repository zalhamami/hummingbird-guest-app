import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';

class InvalidConnectionException implements GeneralException {
  String errorCode;
  String message;

  @override
  String localize() {
    return 'Device cannot establish connection';
  }
}
