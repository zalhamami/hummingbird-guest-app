import 'package:flutter/widgets.dart';
import 'package:hummingbird_guest_apps/app/states/application/ApplicationState.dart';

class ApplicationStateProvider extends InheritedWidget {
  final ApplicationState applicationState;

  ApplicationStateProvider({
    Key key,
    ApplicationState applicationState,
    Widget child,
  })  : applicationState = applicationState ?? ApplicationState(),
        super(
          key: key,
          child: child,
        );

  static ApplicationState of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ApplicationStateProvider>()
      .applicationState;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
