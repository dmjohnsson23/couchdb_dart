/// Library that provide http methods for connecting with CouchDB from server
///
/// Only **Basic Authentication** is implemented at that moment.
/// **Cookie Authentication** isn't implemented yet.
///
/// By default all methods set to request `Accept` header with value `application/json`
/// and if body presented - `Content-Type` header with `application/json` value
library couchdb_server_client;

import 'dart:convert';
import 'dart:io';

import 'src/clients/base/couchdb_base_client.dart';
import 'src/entities/db_response.dart';
import 'src/exceptions/couchdb_exception.dart';

/// Client for interacting with database via server-side applications
class CouchDbServerClient extends CouchDbBaseClient {
  /// Creates only one instance of [CouchDbServerClient] per multiple calls.
  factory CouchDbServerClient(
          {String username,
          String password,
          String host = '127.0.0.1',
          int port = 5984}) =>
      _client ??= CouchDbServerClient._create(username, password, host, port);

  CouchDbServerClient._create(
      this.username, this.password, this.host, this.port);

  static CouchDbServerClient _client;

  /// Host
  String host;

  /// Port
  int port;

  /// Username of database user
  String username;

  /// Password of database user
  String password;

  @override
  String get connectUri => 'http://$username:$password@$host:$port';

  @override
  Future<DbResponse> head(String path, {Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};

    final req = await HttpClient().headUrl(Uri.parse('$connectUri/$path'))
      ..headers.set('Accept', 'application/json');

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }

    final res = await req.close();

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode);
    }

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    return DbResponse(headers: resHeaders);
  }

  @override
  Future<DbResponse> get(String path, {Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};
    Map<String, Object> json;

    final uriString = path.isNotEmpty ? '$connectUri/$path' : '$connectUri';

    final req = await HttpClient().getUrl(Uri.parse(uriString))
      ..headers.set('Accept', 'application/json');

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }

    final res = await req.close();
    final raw = await res.transform(utf8.decoder).join();

    if (res.headers.contentType.mimeType == 'application/json') {
      final resBody = jsonDecode(raw);

      if (resBody is int) {
        json = <String, Object>{'limit': resBody};
      } else if (resBody is List) {
        json = <String, Object>{'results': List<Object>.from(resBody)};
      } else {
        json = Map<String, Object>.from(resBody);
      }
    } else {
      json = <String, String>{'raw': raw};
    }

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    json['headers'] = resHeaders;

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode,
          response: DbResponse.fromJson(json));
    }

    return DbResponse.fromJson(json);
  }

  @override
  Future<DbResponse> put(String path,
      {Object body, Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};

    final req = await HttpClient().putUrl(Uri.parse('$connectUri/$path'))
      ..headers.set('Accept', 'application/json')
      ..headers.contentType = ContentType.json;

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }
    if (body != null) {
      body is Map ? req.write(jsonEncode(body)) : req.write(body);
    }

    final res = await req.close();
    final resBody = jsonDecode(await res.transform(utf8.decoder).join());
    final json = Map<String, Object>.from(resBody);

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    json['headers'] = resHeaders;

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode,
          response: DbResponse.fromJson(json));
    }

    return DbResponse.fromJson(json);
  }

  @override
  Future<DbResponse> post(String path,
      {Object body, Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};

    final req = await HttpClient().postUrl(Uri.parse('$connectUri/$path'))
      ..headers.set('Accept', 'application/json')
      ..headers.contentType = ContentType.json;

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }
    if (body != null) {
      body is Map ? req.write(jsonEncode(body)) : req.write(body);
    }

    final res = await req.close();
    final resBody = jsonDecode(await res.transform(utf8.decoder).join());

    Map<String, Object> json;
    if (resBody is List) {
      json = <String, Object>{'results': List<Object>.from(resBody)};
    } else {
      json = Map<String, Object>.from(resBody);
    }

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    json['headers'] = resHeaders;

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode,
          response: DbResponse.fromJson(json));
    }

    return DbResponse.fromJson(json);
  }

  @override
  Future<DbResponse> delete(String path,
      {Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};

    final req = await HttpClient().deleteUrl(Uri.parse('$connectUri/$path'))
      ..headers.set('Accept', 'application/json')
      ..headers.contentType = ContentType.json;

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }

    final res = await req.close();
    final resBody = jsonDecode(await res.transform(utf8.decoder).join());
    final json = Map<String, Object>.from(resBody);

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    json['headers'] = resHeaders;

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode,
          response: DbResponse.fromJson(json));
    }

    return DbResponse.fromJson(json);
  }

  @override
  Future<DbResponse> copy(String path, {Map<String, String> reqHeaders}) async {
    final resHeaders = <String, List<String>>{};

    final req =
        await HttpClient().openUrl('COPY', Uri.parse('$connectUri/$path'))
          ..headers.set('Accept', 'application/json');

    if (reqHeaders != null) {
      reqHeaders.forEach((header, value) => req.headers.set(header, value));
    }

    final res = await req.close();
    final resBody = jsonDecode(await res.transform(utf8.decoder).join());
    final json = Map<String, Object>.from(resBody);

    res.headers.forEach((header, heads) => resHeaders[header] = heads);
    json['headers'] = resHeaders;

    if (res.statusCode != HttpStatus.ok &&
        res.statusCode != HttpStatus.created &&
        res.statusCode != HttpStatus.accepted) {
      throw CouchDbException(res.statusCode,
          response: DbResponse.fromJson(json));
    }

    return DbResponse.fromJson(json);
  }
}
