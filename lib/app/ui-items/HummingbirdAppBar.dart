import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

class HummingbirdAppBar extends AppBar {
  final String label;
  final List<Widget> actions;
  final Widget leading, title;

  HummingbirdAppBar(
    BuildContext context,
    this.label, {
    this.actions,
    this.leading,
    this.title,
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
          title: title != null
              ? title
              : Text(
                  label,
                  style: TextStyle(
                    color: HummingbirdColor.orange,
                  ),
                ),
        );
}
