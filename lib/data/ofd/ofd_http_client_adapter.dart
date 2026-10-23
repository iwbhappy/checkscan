import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

/// Supplies the intermediate omitted by this one server's TLS handshake.
/// The normal TLS verifier still checks the chain, hostname and validity.
class OfdHttpClientAdapter implements HttpClientAdapter {
  OfdHttpClientAdapter({
    HttpClientAdapter? standardAdapter,
    Future<HttpClientAdapter> Function()? consumerAdapterFactory,
  }) : _standardAdapter = standardAdapter ?? IOHttpClientAdapter(),
       _consumerAdapterFactory =
           consumerAdapterFactory ?? _createConsumerAdapter;

  static const certificateAsset = 'assets/certificates/gogetssl_rsa_dv_ca.pem';

  final HttpClientAdapter _standardAdapter;
  final Future<HttpClientAdapter> Function() _consumerAdapterFactory;
  Future<HttpClientAdapter>? _consumerLoading;
  HttpClientAdapter? _consumerAdapter;
  bool _closed = false;
  bool _closeForce = false;

  static Future<HttpClientAdapter> _createConsumerAdapter() async {
    final issuer = await rootBundle.loadString(certificateAsset);
    final context = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(utf8.encode(issuer));
    return IOHttpClientAdapter(
      createHttpClient: () => HttpClient(context: context),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) throw StateError('OFD transport has been closed');
    final uri = options.uri;
    final scoped =
        uri.scheme == 'https' &&
        uri.host == 'consumer.oofd.kz' &&
        uri.port == 443 &&
        uri.userInfo.isEmpty;
    final HttpClientAdapter adapter;
    if (scoped) {
      adapter = await (_consumerLoading ??= _consumerAdapterFactory().then((
        value,
      ) {
        _consumerAdapter = value;
        if (_closed) value.close(force: _closeForce);
        return value;
      }));
    } else {
      adapter = _standardAdapter;
    }
    return adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _closed = true;
    _closeForce = force;
    _standardAdapter.close(force: force);
    _consumerAdapter?.close(force: force);
  }
}
