import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hummingbird_guest_apps/app/pages/GuestCheckerPage.dart';
import 'file:///D:/Projects/Flutter/hummingbird_guest_apps/lib/app/pages/MainPage.dart';
import 'package:hummingbird_guest_apps/app/states/application/ApplicationState.dart';
import 'package:hummingbird_guest_apps/app/states/application/ApplicationStateProvider.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

void main() {
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  Widget app;
  Widget currentPage;
  ApplicationState applicationState;

  @override
  void initState() {
    if (!mounted) return;
    currentPage = Container(
      decoration: BoxDecoration(color: const Color(0xFF393939)),
      child: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                HummingbirdColor.white,
              ),
            ),
            Container(
              height: 100.0,
            ),
          ],
        ),
      ),
    );
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = MaterialApp(
      title: 'Hummingbird Guest Apps',
      color: HummingbirdColor.black,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: HummingbirdColor.black,
        primaryTextTheme: Theme.of(context).textTheme.apply(
              bodyColor: HummingbirdColor.lightGrey,
              displayColor: HummingbirdColor.lightGrey,
            ),
        fontFamily: 'Raleway',
      ),
      home: SafeArea(
        child: currentPage,
      ),
    );

    if (applicationState == null) return app;
    return ApplicationStateProvider(
      applicationState: applicationState,
      child: app,
    );
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    applicationState = ApplicationState();
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await applicationState.initialize();
    setState(() {
      if (applicationState.wedding != null)
        currentPage = GuestCheckerPage(wedding: applicationState.wedding);
      else
        currentPage = MainPage();
    });
  }
}
