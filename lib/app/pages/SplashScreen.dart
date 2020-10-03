import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: HummingbirdColor.black),
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
  }
}
