import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

class HummingbirdAppBar extends AppBar {
  final String label;
  final List<Widget> actions;

  HummingbirdAppBar(
    BuildContext context,
    this.label, {
    this.actions,
  }) : super(
          actions: actions,
          toolbarHeight: 100.0,
          centerTitle: true,
          shadowColor: HummingbirdColor.transparent,
          backgroundColor: HummingbirdColor.black,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: HummingbirdColor.white,
              size: 32.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            label,
            style: TextStyle(color: HummingbirdColor.orange, fontSize: 20.0),
          ),
        );
}
