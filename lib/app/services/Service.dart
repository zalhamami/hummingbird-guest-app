import 'dart:io';

import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';
import 'package:hummingbird_guest_apps/app/helper/service/GeneralResponse.dart';
import 'package:hummingbird_guest_apps/app/models/Contact.dart';
import 'package:hummingbird_guest_apps/app/models/Guest.dart';
import 'package:hummingbird_guest_apps/app/models/Wedding.dart';
import 'package:hummingbird_guest_apps/app/models/WeddingStatistic.dart';
import 'package:hummingbird_guest_apps/app/routing/RouteBuilder.dart';

class Service<T> {
  final String key;
  final T Function(Map<String, dynamic>) processItem;
  final String weddingCode;

  Service({
    this.key,
    this.processItem,
    this.weddingCode,
  });

  Future<GeneralResponse<T>> getAll<T>({
    GeneralResponse<T> generalResponse,
  }) async {
    generalResponse ??= GeneralResponse<T>();
    final _function = Router(this.key);

    var currentPage = generalResponse.currentPage + 1;
    _function
      ..withQuery('page', '$currentPage')
      ..withParam('code', '$weddingCode');

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

  static Future<List<Contact>> getContact() async {
    final response = await Router('config').withQuery('type', 'contact').get();
    final result = <Contact>[];
    final dataList = response['data'] as List;

    for (final data in dataList) result.add(Contact.fromResponse(data));

    return result;
  }

  static Future<Wedding> getByCode(String code) async {
    code = code.trim();
    code = 'WED-$code';

    final response = await Router('wedding.getByCode')
        .withParam('code', code)
        .withHeader(HttpHeaders.acceptHeader, ContentType.json.value)
        .get();

    final result = Wedding.fromResponse(response);

    if (!result.hasAttendance)
      throw GeneralException(
        '',
        'Fitur kehadiran tidak tersedia untuk kode wedding ini',
      );

    if (!result.hasTransaction)
      throw GeneralException(
        '',
        'Wedding not found',
      );

    return result;
  }

  static Future<Guest> scanQR(Map<String, dynamic> request) async {
    final requestBody = Router.encodeToJson(request);
    final response = await Router('guest.check')
        .withHeader(HttpHeaders.acceptHeader, ContentType.json.value)
        .withHeader(HttpHeaders.contentTypeHeader, ContentType.json.value)
        .post(requestBody);
    return Guest.fromResponse(response);
  }

  static Future<WeddingStatistic> getStatistic(Wedding wedding) async {
    final requestBody = Router.encodeToJson(wedding.statisticRequestBody);

    final response = await Router('guest.static')
        .withHeader(HttpHeaders.acceptHeader, ContentType.json.value)
        .withHeader(HttpHeaders.contentTypeHeader, ContentType.json.value)
        .post(requestBody);

    return WeddingStatistic.fromResponse(response);
  }
}
