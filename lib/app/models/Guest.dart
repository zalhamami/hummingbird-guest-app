import 'package:hummingbird_guest_apps/app/models/Category.dart';

class Guest {
  int id;
  String name, description;

  Category category;

  bool scanStatus;

  Guest({
    this.id,
    this.name,
    this.category,
    this.description,
    this.scanStatus,
  });

  Guest.fromResponse(Map<String, dynamic> response) {
    id = response['id'];
    description = response['description'];

    if (response.containsKey('scan_status') && response['scan_status'] != null)
      scanStatus = response['scan_status'];

    if (response.containsKey('user') && response['user'] != null) {
      final _user = response['user'];
      name = _user['name'];
    }

    if (response.containsKey('category') && response['category'] != null)
      category = Category.fromResponse(response['category']);

    if (description == null || description.isEmpty) description = '-';
    if (name == null || name.isEmpty) name = '-';
    if (scanStatus == null) scanStatus = false;
  }
}
