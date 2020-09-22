import 'package:hummingbird_guest_apps/app/models/Photo.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wedding {
  int id;
  String code, groom, bride;
  Photo featureImage;

  bool hasAttendance = false;

  String get featureTitle => '$groom & $bride';

  String get heroKey => 'WEDDING-$id';

  Wedding({
    this.id,
    this.code,
    this.groom,
    this.bride,
    this.featureImage,
    this.hasAttendance,
  });

  Wedding.fromResponse(Map<String, dynamic> response) {
    if (response.containsKey('id')) id = response['id'];

    if (response.containsKey('code')) code = response['code'];

    Map<String, dynamic> _groom = response['groom'],
        _bride = response['bride'],
        _featureImage = response['featured_image'];

    groom = _groom['name'];
    bride = _bride['name'];
    featureImage = Photo(
      type: PhotoType.Network,
      path: _featureImage['url'],
    );

    if (response.containsKey('features') && response['features'] != null) {
      final List _features = response['features'];
      for (final feature in _features) {
        if (feature.containsKey('name') && feature['name'] != null) {
          final _featureName = feature['name'] as String;

          if (_featureName.isNotEmpty &&
              _featureName.trim().toLowerCase() == 'attendance') {
            hasAttendance = true;
            break;
          }
        }
      }
    }
  }

  static Future<Wedding> initialize() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      final weddingCode = _prefs.getString('weddingCode');
      if (weddingCode == null || weddingCode.isEmpty) return null;
      return await Service.getByCode(weddingCode);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> get statisticRequestBody => <String, dynamic>{
        'wedding_code': this.code,
      };
}
