class Filter {
  final Map<String, String> query;

  Filter() : query = <String, String>{};

  Filter addFilter(String key, value) {
    query[key] = value;
    return this;
  }

  Filter addFilters(Map<String, String> filters) {
    query.addEntries(filters.entries);
    return this;
  }

  bool get hasQuery => query != null && query.isNotEmpty;

  bool queryContainKey(String key) => query.containsKey(key);
  String getQuery(String key) => query[key];
}
