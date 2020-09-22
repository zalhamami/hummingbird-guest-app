import 'package:flutter/painting.dart';

class HummingbirdColor {
  static HummingbirdColor _instance;

  HummingbirdColor._();

  factory HummingbirdColor() {
    if (_instance == null) _instance = HummingbirdColor._();
    return _instance;
  }

  static const Color lightGrey = const Color(0xFFA4A4A4);
  static const Color grey = const Color(0xFF545454);
  static const Color white = const Color(0xFFFFFFFF);
  static const Color black = const Color(0xFF393939);
  static const Color orange = const Color(0xFFE9B189);

  static const Color transparent = const Color(0x00000000);
}
