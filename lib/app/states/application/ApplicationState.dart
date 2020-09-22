import 'package:hummingbird_guest_apps/app/models/Wedding.dart';

class ApplicationState {
  Wedding wedding;

  Future<void> initialize() async {
    wedding = await Wedding.initialize();
  }

  void dispose() {}
}
