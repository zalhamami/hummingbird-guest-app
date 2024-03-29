import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/pages/GuestCheckerPage.dart';
import 'package:hummingbird_guest_apps/app/states/application/ApplicationStateProvider.dart';
import 'package:hummingbird_guest_apps/app/states/globals/ActionState.dart';
import 'package:hummingbird_guest_apps/app/states/WeddingCodeState.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _formKey = GlobalKey<FormState>();
  final _textEditingController = new TextEditingController();
  final _pageState = WeddingCodeState();

  @override
  void initState() {
    _pageState.state.listen((event) {
      if (event is SuccessState)
        ApplicationStateProvider.of(context).initialize().then(
              (value) => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GuestCheckerPage(
                    wedding: event.value,
                  ),
                ),
              ),
            );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: Center(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontFamily: 'Raleway',
              color: HummingbirdColor.lightGrey,
            ),
            textAlign: TextAlign.center,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overScroll) {
                overScroll.disallowGlow();
                return;
              },
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                children: <Widget>[
                  _buildTitle(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: _buildEnterWeddingCodeField(),
                  ),
                  Text(
                    'Wedding Code adalah kode unik yang dimiliki setiap undangan pernikahan',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: _buildShowWeddingCodeButton(),
                  ),
                  _buildEnterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnterButton() {
    return Column(
      children: <Widget>[
        StreamBuilder<ActionState>(
          stream: _pageState.state,
          initialData: IdleState(),
          builder: (context, snapshot) {
            Widget button = _buildButton(
              label: 'Masuk',
              onTap: () {
                _pageState.weddingCode.add(validateWeddingCode());
              },
            );

            Widget errorMessage = Container();

            if (snapshot.hasError)
              errorMessage = Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  '${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );

            if (snapshot.hasData) {
              final data = snapshot.data;

              if (data is LoadingState) button = _buildButton();

              if (data is SuccessState && data.value != null)
                button = _buildButton(label: 'Masuk');
            }

            return Column(
              children: <Widget>[
                button,
                errorMessage,
              ],
            );
          },
        )
      ],
    );
  }

  Widget _buildButton({String label, VoidCallback onTap}) {
    return FlatButton(
      color: HummingbirdColor.grey,
      padding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 15.0,
      ),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: label == null || label.isEmpty
          ? CircularProgressIndicator()
          : Text(
              label,
              style: TextStyle(
                color: HummingbirdColor.white,
                fontSize: 16.0,
              ),
            ),
    );
  }

  Widget _buildShowWeddingCodeButton() {
    return GestureDetector(
      onTap: () async {
        final _url = 'https://hummingbird.id/user/undangan';
        if (await canLaunch(_url)) await launch(_url);
      },
      child: Text(
        'Lihat Wedding Code',
        style: TextStyle(decoration: TextDecoration.underline, fontSize: 12.0),
      ),
    );
  }

  Widget _buildEnterWeddingCodeField() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: HummingbirdColor.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: const EdgeInsets.all(15.0),
        child: TextFormField(
          controller: _textEditingController,
          textAlign: TextAlign.center,
          decoration: InputDecoration.collapsed(
            border: InputBorder.none,
            hintText: 'Masukan Code',
            hintStyle: TextStyle(
              color: HummingbirdColor.grey,
            ),
          ),
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(FocusNode()),
        ),
      ),
    );
  }

  String validateWeddingCode() {
    var weddingCode = _textEditingController.text.toUpperCase();

    if (!isNumeric(weddingCode)) {
      if (weddingCode.toUpperCase().contains('WED')) {
        if (weddingCode.contains('-'))
          weddingCode = weddingCode.split('-')[1];
        else
          weddingCode = weddingCode.substring(3);
      }
    }

    return weddingCode.trim();
  }

  bool isNumeric(String value) {
    if (value == null || value.isEmpty) return false;

    return double.tryParse(value) != null;
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Wedding Code',
        style: TextStyle(
          color: HummingbirdColor.orange,
          fontWeight: FontWeight.w600,
          fontSize: 25.0,
        ),
      ),
    );
  }
}
