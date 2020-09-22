class Category {
  int id;
  String name;

  Category.fromResponse(Map<String, dynamic> response) {
    id = response['id'];
    name = response['name'];
  }
}
