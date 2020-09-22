import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hummingbird_guest_apps/app/exceptions/request/InvalidConnectionException.dart';
import 'package:hummingbird_guest_apps/app/exceptions/request/InvalidRequestException.dart';
import 'package:hummingbird_guest_apps/app/exceptions/request/ServerErrorException.dart';
import 'package:hummingbird_guest_apps/app/exceptions/request/UnauthorizedException.dart';
import 'package:hummingbird_guest_apps/app/routing/DefaultApi.dart';
import 'package:http/http.dart' as http;

class Router {
  static Map<String, String> _globalHeaders = Map<String, String>();

  static void addGlobalHeader(String key, String value) {
    _globalHeaders[key] = value;
  }

  static void addGlobalHeaders(Map<String, String> globalHeaders) {
    _globalHeaders.addAll(globalHeaders);
  }

  static void removeGlobalHeader(String key) {
    _globalHeaders.remove(key);
  }

  static void removeGlobalHeaders(List<String> keys) {
    for (var key in keys) _globalHeaders.remove(key);
  }

  static const JsonEncoder encoder = const JsonEncoder();
  static const JsonDecoder decoder = const JsonDecoder();

  static String encodeToJson(dynamic content) => encoder.convert(content);

  static dynamic decodeFromJson(String input) => decoder.convert(input);

  Map<String, String> _headers;
  Map<String, String> _queries;
  Map<String, String> _parameters;
  String _moduleUrl = '';
  String _name = '';

  DefaultApi _getCurrentApi() => DefaultApi();

  String _baseUrl() => _getCurrentApi().apiUrl();

  get isProd => !isDev;

  get isDev => _baseUrl() != 'https://dev.api.hummingbird.id/api';

  get url => _buildUrl();

  get httpHeaders => _buildHeaders();

  get headers => _headers;

  get queries => _queries;

  get parameters => _parameters;

  Router(String name) {
    _name = name;
    _moduleUrl = _getCurrentApi().routes().getModuleUrl(_name);
    _headers = Map();
    _queries = Map();
    _parameters = Map();
  }

  Router withQuery(String key, String value) {
    _queries[key] = value;
    return this;
  }

  Router withParam(String key, String value) {
    _parameters[key] = value;
    return this;
  }

  Router withHeader(String key, String value) {
    _headers[key] = value;
    return this;
  }

  Router withQueries(Map<String, String> queries) {
    _queries.addAll(queries);
    return this;
  }

  Router withParams(Map<String, String> parameters) {
    _parameters.addAll(parameters);
    return this;
  }

  Router withHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
    return this;
  }

  Router removeQuery(String key) {
    _queries.remove(key);
    return this;
  }

  Router removeParam(String key) {
    _parameters.remove(key);
    return this;
  }

  Router removeHeader(String key) {
    _headers.remove(key);
    return this;
  }

  Router removeQueries(List<String> keys) {
    for (var key in keys) _queries.remove(key);
    return this;
  }

  Router removeParams(List<String> keys) {
    for (var key in keys) _parameters.remove(key);
    return this;
  }

  Router removeHeaders(List<String> keys) {
    for (var key in keys) _headers.remove(key);
    return this;
  }

  String _buildUrl() {
    var moduleUrl = _moduleUrl;
    _parameters.forEach((key, value) {
      key = ':$key';
      moduleUrl = moduleUrl.replaceAll(key, value);
    });

    final queries = <String>[];
    if (_queries.isNotEmpty)
      _queries.forEach((key, value) => queries.add('$key=$value'));

    if (queries.isNotEmpty) {
      final queryString = queries.join('&');
      moduleUrl = '$moduleUrl?$queryString';
    }

    return '${_baseUrl()}/$moduleUrl';
  }

  Map<String, String> _buildHeaders() {
    final httpHeaders = Map.fromEntries(_headers.entries);
    httpHeaders.addAll(_globalHeaders);
    return httpHeaders;
  }

  Future<dynamic> get() async => http
      .get(url, headers: _buildHeaders())
      .then(_handleResponse)
      .catchError(_handleError);

  Future<dynamic> rawGet() async => http.get(url, headers: _buildHeaders());

  Future<dynamic> post(dynamic content) async => http
      .post(url, headers: _buildHeaders(), body: content)
      .then(_handleResponse)
      .catchError(_handleError);

  Future<dynamic> rawPost(dynamic content) async =>
      http.post(url, headers: _buildHeaders(), body: content);

  Future<dynamic> put(dynamic content) async => http
      .put(url, headers: _buildHeaders(), body: content)
      .catchError(_handleError);

  Future<dynamic> rawPut(dynamic content) async =>
      http.put(url, headers: _buildHeaders(), body: content);

  Future<void> delete() async => http
      .delete(url, headers: _buildHeaders())
      .then(_handleResponse)
      .catchError(_handleError);

  Future<dynamic> rawDelete() async =>
      http.delete(url, headers: _buildHeaders());

  FutureOr _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;

    if (ServerErrorException.httpCodes.contains(statusCode))
      throw ServerErrorException('$statusCode', response.body);

    if (UnauthorizedException.httpCodes.contains(statusCode))
      throw UnauthorizedException();

    if (InvalidRequestException.httpCodes.contains(statusCode)) {
      int code = statusCode;
      String message = response.body;
      Map<String, dynamic> errors;

      try {
        final Map<String, dynamic> decoded = decodeFromJson(message);
        if (decoded.containsKey('code')) code = decoded['code'];
        if (decoded.containsKey('message')) message = decoded['message'];
        if (decoded.containsKey('errors') && decoded['errors'] != null) {
          errors = decoded['errors'];
          message = errors.values.first[0];
        }
      } catch (e) {
        throw InvalidRequestException('$e', e);
      }

      throw InvalidRequestException('$code', message);
    }

    if (response.body != null && response.body.isNotEmpty) {
      try {
        final dynamic decodedResponse = decodeFromJson(response.body);
        if (decodedResponse == null) return response.statusCode;
        return decodedResponse;
      } on FormatException {
        return response.body;
      }
    }

    return response.statusCode;
  }

  _handleError(Object e) {
    if (e is SocketException) throw InvalidConnectionException();
    throw e;
  }
}
