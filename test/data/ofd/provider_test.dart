import 'dart:io';
import 'dart:typed_data';

import 'package:checkscan/core/errors/app_failure.dart';
import 'package:checkscan/data/ofd/kazakhtelecom_ofd_provider.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.handler);
  final ResponseBody Function(RequestOptions, int) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options, requests.length);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final raw = File(
    'test/fixtures/ofd_responses/ticket.json',
  ).readAsStringSync();
  final qr = Uri.parse(
    'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259',
  );
  late ScriptedAdapter adapter;
  late List<Duration> waits;
  KazakhtelecomOfdProvider provider(
    ResponseBody Function(RequestOptions, int) handler,
  ) {
    adapter = ScriptedAdapter(handler);
    waits = [];
    return KazakhtelecomOfdProvider(
      dio: Dio()..httpClientAdapter = adapter,
      delay: (duration) async => waits.add(duration),
    );
  }

  ResponseBody ok() => ResponseBody.fromString(raw, 200);

  test(
    'calls confirmed JSON API over HTTPS with original parameters',
    () async {
      final client = provider((options, _) => ok());
      final parsed = await client.fetch(qr);
      expect(parsed.totalMinor, 200200);
      expect(adapter.requests, hasLength(1));
      final request = adapter.requests.single;
      expect(request.uri.scheme, 'https');
      expect(request.uri.host, qr.host);
      expect(request.uri.path, KazakhtelecomOfdProvider.apiPath);
      expect(request.uri.queryParameters, qr.queryParameters);
      expect(request.headers['Accept-Language'], 'ru');
      expect(request.followRedirects, isFalse);
      expect(request.connectTimeout, const Duration(seconds: 15));
      expect(request.receiveTimeout, const Duration(seconds: 15));
      expect(parsed.debugRaw, isNull);
    },
  );

  test(
    'server 5xx retries twice with backoff, without HTTP downgrade',
    () async {
      final client = provider(
        (options, count) =>
            count < 3 ? ResponseBody.fromString('unavailable', 503) : ok(),
      );
      expect((await client.fetch(qr)).items, hasLength(4));
      expect(adapter.requests, hasLength(3));
      expect(
        adapter.requests.every((request) => request.uri.scheme == 'https'),
        isTrue,
      );
      expect(waits, [
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 600),
      ]);
    },
  );

  test('exhausted 5xx and 404 are typed failures', () async {
    final failing = provider(
      (options, _) => ResponseBody.fromString('unavailable', 500),
    );
    await expectLater(failing.fetch(qr), throwsA(isA<ServerFailure>()));
    expect(adapter.requests, hasLength(3));
    final missing = provider((options, _) => ResponseBody.fromString('', 404));
    await expectLater(
      missing.fetch(qr),
      throwsA(isA<ReceiptNotFoundFailure>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('consumer transport failure permits HTTP fallback', () async {
    final client = provider((options, count) {
      if (count == 1) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return ok();
    });
    await client.fetch(qr);
    expect(adapter.requests.map((request) => request.uri.scheme), [
      'https',
      'http',
    ]);
  });

  test(
    'native unknown TLS and socket errors permit consumer fallback',
    () async {
      for (final cause in [
        const HandshakeException('CERTIFICATE_VERIFY_FAILED'),
        const SocketException('Connection reset'),
      ]) {
        final client = provider((options, count) {
          if (count == 1) {
            throw DioException(requestOptions: options, error: cause);
          }
          return ok();
        });
        expect((await client.fetch(qr)).totalMinor, 200200);
        expect(adapter.requests.map((request) => request.uri.scheme), [
          'https',
          'http',
        ]);
      }
    },
  );

  test('TLS failure after HTTP redirects back to HTTPS stays typed', () async {
    final client = provider((options, _) {
      if (options.uri.scheme == 'http') {
        return ResponseBody.fromString(
          '',
          301,
          headers: {
            'location': [options.uri.replace(scheme: 'https').toString()],
          },
        );
      }
      throw DioException(
        requestOptions: options,
        error: const HandshakeException('CERTIFICATE_VERIFY_FAILED'),
      );
    });
    await expectLater(
      client.fetch(qr),
      throwsA(
        isA<TlsFailure>().having(
          (failure) => failure.isRetryable,
          'retryable',
          isTrue,
        ),
      ),
    );
    expect(adapter.requests, hasLength(9));
    expect(waits, hasLength(2));
  });

  test('TLS errors on other hosts cannot trigger HTTP fallback', () async {
    final client = provider(
      (options, _) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.badCertificate,
      ),
    );
    await expectLater(
      client.fetch(qr.replace(host: 'tickets.oofd.kz')),
      throwsA(isA<TlsFailure>()),
    );
    expect(adapter.requests, hasLength(3));
    expect(
      adapter.requests.every((request) => request.uri.scheme == 'https'),
      isTrue,
    );
  });

  test('other oofd subdomains never downgrade to HTTP', () async {
    final client = provider(
      (options, _) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    await expectLater(
      client.fetch(qr.replace(host: 'tickets.oofd.kz')),
      throwsA(isA<TimeoutFailure>()),
    );
    expect(adapter.requests, hasLength(3));
    expect(
      adapter.requests.every((request) => request.uri.scheme == 'https'),
      isTrue,
    );
  });

  test(
    'offline consumer retries transport pairs then remains pending',
    () async {
      final client = provider(
        (options, _) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        client.fetch(qr),
        throwsA(
          isA<NetworkFailure>().having(
            (failure) => failure.isRetryable,
            'isRetryable',
            isTrue,
          ),
        ),
      );
      expect(adapter.requests, hasLength(6));
      expect(waits, hasLength(2));
    },
  );

  test('same-host relative redirects are followed manually', () async {
    final client = provider(
      (options, count) => count == 1
          ? ResponseBody.fromString(
              '',
              307,
              headers: {
                'location': ['/api/receipt-result'],
              },
            )
          : ok(),
    );
    await client.fetch(qr);
    expect(adapter.requests.last.uri.path, '/api/receipt-result');
    expect(
      adapter.requests.every((request) => request.uri.host == qr.host),
      isTrue,
    );
  });

  test(
    'cross-host, downgrade, userinfo and port redirects never send a request',
    () async {
      for (final destination in [
        'https://evil.org/ticket',
        'https://other.oofd.kz/ticket',
        'http://consumer.oofd.kz/ticket',
        'https://user@consumer.oofd.kz/ticket',
        'https://consumer.oofd.kz:8443/ticket',
        'file:///etc/passwd',
      ]) {
        final client = provider(
          (options, _) => ResponseBody.fromString(
            '',
            302,
            headers: {
              'location': [destination],
            },
          ),
        );
        await expectLater(client.fetch(qr), throwsA(isA<UnsafeUrlFailure>()));
        expect(adapter.requests, hasLength(1));
      }
    },
  );

  test(
    'redirect loops are bounded and malformed responses are not retried',
    () async {
      final looping = provider(
        (options, _) => ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['/loop'],
          },
        ),
      );
      await expectLater(looping.fetch(qr), throwsA(isA<UnsafeUrlFailure>()));
      expect(adapter.requests, hasLength(6));
      final malformed = provider(
        (options, _) => ResponseBody.fromString('<html>challenge</html>', 200),
      );
      await expectLater(malformed.fetch(qr), throwsA(isA<ParseFailure>()));
      expect(adapter.requests, hasLength(1));
    },
  );

  test(
    'registry and provider reject unsupported addresses before network',
    () async {
      final client = provider((options, _) => ok());
      final registry = OfdProviderRegistry([client]);
      expect(registry.providerFor(qr), same(client));
      final unsafe = qr.replace(host: 'fakeoofd.kz');
      expect(client.canHandle(unsafe), isFalse);
      expect(registry.providerFor(unsafe), isNull);
      expect(
        () => registry.fetch(unsafe),
        throwsA(isA<UnsupportedQrFailure>()),
      );
      await expectLater(
        client.fetch(unsafe),
        throwsA(isA<UnsupportedQrFailure>()),
      );
      expect(adapter.requests, isEmpty);
      expect((await registry.fetch(qr)).totalMinor, 200200);
    },
  );
}
