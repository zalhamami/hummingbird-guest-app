class GeneralServiceUrls {
  Map<String, String> urls = {};

  GeneralServiceUrls.build({
    String prefix,
    String all = 'getAll',
    String getById = 'getById',
    Map<String, String> url,
  }) {
    if (urls == null) urls = {};

    if (prefix.isNotEmpty) prefix = '$prefix.';

    if (all != null && all.isNotEmpty) urls['all'] = '$prefix$all';

    if (getById != null && getById.isNotEmpty)
      urls['getById'] = '$prefix$getById';

    if (url != null && url.isNotEmpty)
      url.forEach((key, value) => urls[key] = '$prefix$value');
  }

  bool containsKey(String key) => urls.containsKey(key);

  String get(String key) => urls.containsKey(key) ? urls[key] : null;

  operator [](String key) => get(key);
}
