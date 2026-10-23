import 'dart:async';
import 'dart:typed_data';

import 'package:checkscan/data/ofd/ofd_http_client_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <Uri>[];
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (closed) throw StateError('closed');
    requests.add(options.uri);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) => closed = true;
}

void main() {
  test('additional issuer is scoped to exact HTTPS host and port', () async {
    final standard = RecordingAdapter();
    final scoped = RecordingAdapter();
    var loads = 0;
    final adapter = OfdHttpClientAdapter(
      standardAdapter: standard,
      consumerAdapterFactory: () async {
        loads++;
        return scoped;
      },
    );
    for (final url in [
      'https://consumer.oofd.kz/api/test',
      'https://tickets.oofd.kz/api/test',
      'https://consumer.oofd.kz.evil.test/api/test',
      'https://eviloofd.kz/api/test',
      'https://consumer.oofd.kz:8443/api/test',
      'https://user@consumer.oofd.kz/api/test',
      'http://consumer.oofd.kz/api/test',
    ]) {
      await adapter.fetch(RequestOptions(path: url), null, null);
    }
    expect(scoped.requests, [Uri.parse('https://consumer.oofd.kz/api/test')]);
    expect(standard.requests, hasLength(6));
    expect(loads, 1);
    adapter.close(force: true);
    expect(standard.closed, isTrue);
    expect(scoped.closed, isTrue);
  });

  test('concurrent consumer requests load the issuer once', () async {
    final ready = Completer<HttpClientAdapter>();
    final scoped = RecordingAdapter();
    var loads = 0;
    final adapter = OfdHttpClientAdapter(
      standardAdapter: RecordingAdapter(),
      consumerAdapterFactory: () {
        loads++;
        return ready.future;
      },
    );
    final first = adapter.fetch(
      RequestOptions(path: 'https://consumer.oofd.kz/a'),
      null,
      null,
    );
    final second = adapter.fetch(
      RequestOptions(path: 'https://consumer.oofd.kz/b'),
      null,
      null,
    );
    ready.complete(scoped);
    await Future.wait([first, second]);
    expect(loads, 1);
    expect(scoped.requests, hasLength(2));
    adapter.close();
    await expectLater(
      adapter.fetch(
        RequestOptions(path: 'https://consumer.oofd.kz/c'),
        null,
        null,
      ),
      throwsStateError,
    );
  });
}
