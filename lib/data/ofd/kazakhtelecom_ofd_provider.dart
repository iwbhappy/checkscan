import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/qr_receipt.dart';
import 'kazakhtelecom_receipt_parser.dart';
import 'ofd_http_client_adapter.dart';
import 'ofd_provider.dart';

class KazakhtelecomOfdProvider implements OfdProvider {
  KazakhtelecomOfdProvider({
    Dio? dio,
    bool retainDebugRaw = false,
    Future<void> Function(Duration)? delay,
  }) : _dio = dio ?? (Dio()..httpClientAdapter = OfdHttpClientAdapter()),
       _retainDebugRaw = kDebugMode && retainDebugRaw,
       _delay = delay ?? Future<void>.delayed {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);
  }

  final Dio _dio;
  final bool _retainDebugRaw;
  final Future<void> Function(Duration) _delay;
  static const apiPath = '/api/consumer-proxy/api/tickets/get-by-url';

  @override
  bool canHandle(Uri qrUri) => QrReceipt.tryParse(qrUri.toString()) != null;

  @override
  Future<ParsedReceipt> fetch(Uri qrUri) async {
    final qr = QrReceipt.parse(qrUri.toString());
    final endpoint = Uri(
      scheme: 'https',
      host: qr.uri.host,
      path: apiPath,
      queryParameters: {
        for (final key in ['i', 'f', 's', 't'])
          key: qr.uri.queryParameters[key]!,
      },
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final raw = await _loadWithFallback(endpoint);
        return const KazakhtelecomReceiptParser().parse(
          raw,
          sourceUri: qr.uri,
          retainDebugRaw: _retainDebugRaw,
        );
      } on DioException catch (error) {
        final failure = _networkFailure(error);
        if (attempt == 2 || !failure.isRetryable) throw failure;
      } on ServerFailure {
        if (attempt == 2) rethrow;
      }
      await _delay(Duration(milliseconds: 300 * (1 << attempt)));
    }
    throw const NetworkFailure();
  }

  Future<String> _loadWithFallback(Uri endpoint) async {
    try {
      return await _request(endpoint);
    } on DioException catch (error) {
      if (endpoint.host == 'consumer.oofd.kz' && _isTransportError(error)) {
        return _request(endpoint.replace(scheme: 'http'));
      }
      rethrow;
    }
  }

  Future<String> _request(Uri endpoint) async {
    var current = endpoint;
    for (var redirects = 0; redirects <= 5; redirects++) {
      final response = await _dio.getUri<String>(
        current,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (_) => true,
          headers: {
            'User-Agent': 'Mozilla/5.0 CheckScan/1.0',
            'Accept-Language': 'ru',
            'Accept': 'application/json',
          },
        ),
      );
      final status = response.statusCode ?? 0;
      if ([301, 302, 303, 307, 308].contains(status)) {
        final location = response.headers.value('location');
        if (location == null || redirects == 5) throw const UnsafeUrlFailure();
        Uri next;
        try {
          next = current.resolve(location);
        } on FormatException {
          throw const UnsafeUrlFailure();
        }
        if (!isSafeOfdUri(next) ||
            next.host != endpoint.host ||
            (current.scheme == 'https' && next.scheme != 'https') ||
            (next.scheme == 'http' && next.host != 'consumer.oofd.kz')) {
          throw const UnsafeUrlFailure();
        }
        current = next;
        continue;
      }
      if (status == 404 || status == 204) throw const ReceiptNotFoundFailure();
      if (status >= 500 || status == 429) throw ServerFailure(status);
      if (status < 200 || status >= 300) {
        throw ParseFailure(debugRaw: _retainDebugRaw ? response.data : null);
      }
      return response.data ?? '';
    }
    throw const UnsafeUrlFailure();
  }

  static bool _isTransportError(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => true,
    // The native adapter leaves TLS and some socket exceptions as `unknown`.
    _ => error.error is TlsException || error.error is SocketException,
  };

  static AppFailure _networkFailure(DioException error) {
    if (error.type == DioExceptionType.badCertificate ||
        error.error is TlsException) {
      return const TlsFailure();
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.badResponse => ServerFailure(error.response?.statusCode),
      _ => const NetworkFailure(),
    };
  }
}
