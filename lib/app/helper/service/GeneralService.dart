import 'package:hummingbird_guest_apps/app/helper/service/GeneralResponse.dart';
import 'package:hummingbird_guest_apps/app/helper/service/GeneralServiceUrls.dart';
import 'package:hummingbird_guest_apps/app/routing/RouteBuilder.dart';

abstract class GeneralService<T> {
  String prefix;
  GeneralServiceUrls urls;

  GeneralService(this.prefix, {Map<String, String> urls})
      : this.urls = GeneralServiceUrls.build(
          prefix: prefix,
          url: urls,
        );

  String _url(String key) {
    return urls.get(key);
  }

  Future<GeneralResponse<T>> getAll<T>({
    GeneralResponse<T> generalResponse,
  }) async {
    generalResponse ??= GeneralResponse<T>();
    final getUrl = _url('all');
    final _function = Router(getUrl);

    var currentPage = generalResponse.currentPage + 1;
    _function..withQuery('page', '$currentPage');

    final filter = generalResponse.filter;
    if (filter != null && filter.hasQuery) _function..withQueries(filter.query);

    final Map<String, dynamic> response = await _function.get();

    final items = <T>[];
    if (response != null && response.containsKey('data')) {
      final List dataList = response['data'];
      for (final result in dataList) {
        final T data = processItem(result) as T;
        items.add(data);
      }
    }

    currentPage = response['current_page'];
    final lastPage = response['last_page'];
    final perPage = response['per_page'];
    final totalData = response['total'];

    return GeneralResponse<T>(
      items: items,
      filter: filter,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      totalData: totalData,
    );
  }

  Future<T> getById<T>(int id) async {
    final getUrl = _url('getById');
    final result = await Router(getUrl).withParam('id', '$id').get();
    final T data = processItem(result) as T;
    return data;
  }

  T processItem(item);
}
