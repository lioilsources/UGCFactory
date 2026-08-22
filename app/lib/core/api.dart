import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Klient ugc-api (NAS). Jedno API, jedna auth - appka nikdy nemluvi
/// primo se Sparkem (UGC_STUDIO_APP_PLAN).
class UgcApi {
  UgcApi(this.baseUrl, {this.clientId = '', this.clientSecret = ''});

  final String baseUrl;

  /// Cloudflare Access service token. Prazdny na tailnetu/LAN, vyplneny
  /// kdyz appka jde pres ugc.ol1n.com. CF na prvni request s temito
  /// hlavickami vrati cookie CF_Authorization (24 h), takze WebView pak
  /// projde i na model a skript.
  final String clientId;
  final String clientSecret;

  final http.Client _client = http.Client();

  Map<String, String> get authHeaders => clientId.isEmpty
      ? const {}
      : {
          'CF-Access-Client-Id': clientId,
          'CF-Access-Client-Secret': clientSecret,
        };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: q);

  Future<List<Job>> jobs({String? status, int limit = 200}) async {
    final resp = await _client.get(_u('/jobs', {
      if (status != null) 'status': status,
      'limit': '$limit',
    }), headers: authHeaders);
    _check(resp);
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list
        .map((e) => Job.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Item>> items() async {
    final resp = await _client.get(_u('/items'), headers: authHeaders);
    _check(resp);
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Job> approve(String id) => _post('/jobs/$id/approve');
  Future<Job> reject(String id) => _post('/jobs/$id/reject');
  Future<Job> reroll(String id) => _post('/jobs/$id/reroll');
  Future<Job> reconvert(String id) => _post('/jobs/$id/reconvert');

  Future<Job> _post(String path) async {
    final resp = await _client.post(_u(path), headers: authHeaders);
    _check(resp);
    return Job.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// Batch composer: proxy pres NAS na Spark /ugc/generate.
  Future<void> generate({
    required String prompt,
    required String category,
    required String style,
    required String collection,
    int? seed,
  }) async {
    final resp = await _client.post(
      _u('/generate'),
      headers: {'Content-Type': 'application/json', ...authHeaders},
      body: jsonEncode({
        'prompt': prompt,
        'category': category,
        'style': style,
        'collection': collection,
        if (seed != null) 'seed': seed,
      }),
    );
    _check(resp);
  }

  String previewUrl(String id) => '$baseUrl/jobs/$id/preview';

  /// GLB pro 3D prohlizec. Na webu je baseUrl prazdny (stejny origin),
  /// takze model-viewer potrebuje absolutni cestu od korene.
  String glbUrl(String id) =>
      baseUrl.isEmpty ? '/jobs/$id/glb' : '$baseUrl/jobs/$id/glb';

  /// Stranka 3D prohlizece servirovana primo ugc-api. Model i skript jsou
  /// na stejnem originu jako ona, takze odpadaji vsechny platformni pasti
  /// lokalni proxy (cleartext localhost na Androidu, ATS ve WKWebView na
  /// iOS, CORS vsude).
  String viewerUrl(String id) =>
      baseUrl.isEmpty ? '/viewer/$id' : '$baseUrl/viewer/$id';

  /// SSE stream /events - kazdy event je {"event": "...", "data": {...}}.
  /// Pri vypadku se reconnectuje s backoff; stream nikdy nekonci sam.
  Stream<Map<String, dynamic>> events() async* {
    var backoff = const Duration(seconds: 1);
    while (true) {
      try {
        final req = http.Request('GET', _u('/events'))
          ..headers['Accept'] = 'text/event-stream'
          ..headers.addAll(authHeaders);
        final resp = await _client.send(req);
        backoff = const Duration(seconds: 1);
        final lines = resp.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());
        await for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final payload = jsonDecode(line.substring(6));
          if (payload is Map<String, dynamic>) yield payload;
        }
      } catch (_) {
        // spadly socket / NAS restart - pockat a zkusit znovu
      }
      await Future<void>.delayed(backoff);
      backoff = Duration(seconds: (backoff.inSeconds * 2).clamp(1, 30));
    }
  }

  void _check(http.Response resp) {
    if (resp.statusCode >= 300) {
      String msg = resp.body;
      try {
        msg = (jsonDecode(resp.body) as Map)['error'] as String? ?? msg;
      } catch (_) {}
      throw UgcApiException(resp.statusCode, msg);
    }
  }
}

class UgcApiException implements Exception {
  UgcApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => 'HTTP $status: $message';
}
