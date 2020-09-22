import 'package:hummingbird_guest_apps/app/helper/service/Filter.dart';
import 'package:hummingbird_guest_apps/app/mixin/ApiPageMixin.dart';

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
