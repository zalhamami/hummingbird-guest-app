import 'package:hummingbird_guest_apps/app/helper/service/Filter.dart';
import 'package:hummingbird_guest_apps/app/routing/RouteBuilder.dart';

class GeneralService<T> {
  final String key;
  final T Function(Map<String, dynamic>) processItem;

  GeneralService(
    this.key,
    this.processItem,
  );

  Future<GeneralResponse<T>> getAll<T>({
    GeneralResponse<T> generalResponse,
  }) async {
    generalResponse ??= GeneralResponse<T>();
    final getUrl = this.key;
    final _function = Router(getUrl);

    var currentPage = generalResponse.currentPage ?? 0 + 1;
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
}

class GeneralResponse<T> with ApiPageMixin {
  List<T> items;
  Filter filter;

  GeneralResponse({
    this.items,
    this.filter,
    int currentPage = 0,
    int perPage = 30,
    int lastPage = 1,
    int totalData,
  }) {
    this.currentPage = currentPage;
    this.perPage = perPage;
    this.lastPage = lastPage;
    this.totalData = totalData;
  }

  bool get hasFilter => filter != null && filter.hasQuery;
}

mixin ApiPageMixin {
  int currentPage;
  int perPage;
  int lastPage;
  int totalData;

  bool get hasNext => lastPage != currentPage;
}
