import 'package:hummingbird_guest_apps/app/models/Photo.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wedding {
  int id;
  String code, firstPerson, secondPerson;
  Photo featureImage;

  bool hasAttendance = false;
  bool hasTransaction = false;

  String get featureTitle {
    String _firstPerson, _secondPerson = '';

    _firstPerson = getFirstName(firstPerson);
    _secondPerson = getFirstName(secondPerson);

    return '$_firstPerson & $_secondPerson';
  }

  static String getFirstName(String value) {
    value = value.trim();
    final List<String> names = value.split(" ");

    return names.first;
  }

  String get heroKey => 'WEDDING-$id';

  Wedding({
    this.id,
    this.code,
    this.firstPerson,
    this.secondPerson,
    this.featureImage,
    this.hasAttendance,
    this.hasTransaction,
  });

  Wedding.fromResponse(Map<String, dynamic> response) {
    if (response.containsKey('id')) id = response['id'];

    if (response.containsKey('code')) code = response['code'];

    Map<String, dynamic> _featureImage = response['featured_image'];

    List<dynamic> _couple = response['couple'];

    firstPerson = _couple[0]['nickname'];
    secondPerson = _couple[1]['nickname'];
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

    if (response.containsKey('transaction') &&
        response['transaction'] != null) {
      final Map transaction = response['transaction'];

      if (transaction.containsKey('status') && transaction['status'] != null) {
        final Map transactionStatus = transaction['status'];

        if (transactionStatus.containsKey('status') &&
            transactionStatus['status'] != null) {
          String status = (transactionStatus['status'] as String).trim();

          if (status.isNotEmpty) {
            status = status.toLowerCase();

            if (status == 'approved') hasTransaction = true;
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
