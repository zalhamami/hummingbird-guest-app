class DefaultApi {
  const DefaultApi();

  static const _routes = DefaultApiRoutes();

  String protocol() => 'https';

  String baseUrl() => 'dev.api.hummingbird.id';

  String apiVersion() => 'api';

  String apiUrl() => '${protocol()}://${baseUrl()}/${apiVersion()}';

  DefaultApiRoutes routes() => _routes;
}

class DefaultApiRoutes {
  static const Map<String, String> routes = {
    // get by code
    'wedding.getByCode': 'wedding/:code',

    // guest -> scan qr
    'guest.check': 'wedding-guest/check',

    // guest -> get statistic
    'guest.static': 'wedding-guest/statistic',

    // guest -> get all by wedding
    'guest.getAllByWedding': 'wedding/:code/guest',

    // guest category > get all by wedding
    'guestCategory.getAllByWedding': 'wedding/:code/guest-category',

    // guest category > get all by wedding
    'config': 'config',
  };

  String getModuleUrl(String name) =>
      routes.containsKey(name) ? routes[name] : '';

  const DefaultApiRoutes();
}
