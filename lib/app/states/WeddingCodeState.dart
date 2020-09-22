import 'dart:async';

import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';
import 'package:hummingbird_guest_apps/app/models/Wedding.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:hummingbird_guest_apps/app/states/globals/ActionState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeddingCodeState {
  Sink<String> get weddingCode => _weddingCode.sink;
  final _weddingCode = StreamController<String>();

  Stream<ActionState> get state => _state.stream;
  final _state = StreamController<ActionState>.broadcast();

  WeddingCodeState() {
    _weddingCode.stream.listen((weddingCode) async {
      weddingCode = weddingCode.trim();
      _state.add(LoadingState());
      try {
        final _result = await Service.getByCode(weddingCode);
        final _prefs = await SharedPreferences.getInstance();
        await _prefs.setString('weddingCode', weddingCode);
        _state.add(SuccessState<Wedding>(value: _result));
      } catch (e) {
        var errorMessage = '';

        if (e is GeneralException)
          errorMessage = e.message;
        else
          errorMessage = 'Unknown Error, $e';

        _state.addError(errorMessage);
      }
    });
  }

  void dispose() {
    _weddingCode.close();
    _state.close();
  }
}
