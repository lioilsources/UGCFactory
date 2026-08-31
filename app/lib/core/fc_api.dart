import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'fc_models.dart';

/// Klient fantasy-character casti ugc-api (`/v1/fc/`).
///
/// Vlastni trida, ne metody na UgcApi: FC ma podle planu vlastni klicovy
/// scope, takze si nese svuj X-API-Key vedle Access hlavicek, ktere plati
/// pro cely origin.
class FcApi {
  FcApi(this.baseUrl, {this.apiKey = '', this.accessHeaders = const {}});

  final String baseUrl;

  /// FC_API_KEYS na serveru. Kdyz je tam prazdno, scope je otevreny a tenhle
  /// klic se ignoruje - proto se hlavicka posila jen kdyz opravdu neco je.
  final String apiKey;

  /// Cloudflare Access service token, sdileny se zbytkem appky.
  final Map<String, String> accessHeaders;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    ...accessHeaders,
    if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
  };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: q);

  Future<List<FcCharacter>> characters({String? owner, String? status}) async {
    final resp = await _client.get(
      _u('/v1/fc/characters', {
        if (owner != null && owner.isNotEmpty) 'owner': owner,
        if (status != null && status.isNotEmpty) 'status': status,
      }),
      headers: _headers,
    );
    _check(resp);
    return (jsonDecode(resp.body) as List<dynamic>)
        .map((e) => FcCharacter.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<FcDetail> character(String id) async {
    final resp = await _client.get(
      _u('/v1/fc/characters/$id'),
      headers: _headers,
    );
    _check(resp);
    return FcDetail.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<List<FcAnimation>> animations({String? category, String? tag}) async {
    final resp = await _client.get(
      _u('/v1/fc/animations', {
        if (category != null && category.isNotEmpty) 'category': category,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      }),
      headers: _headers,
    );
    _check(resp);
    return (jsonDecode(resp.body) as List<dynamic>)
        .map((e) => FcAnimation.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Zaklada postavu. [imageBytes] je PNG/JPG z galerie nebo fotoaparatu.
  Future<FcCharacter> create({
    required String name,
    required List<int> imageBytes,
    required String filename,
    required List<String> animationIds,
    String ownerId = '',
    bool autoAPose = true,
  }) async {
    final req = http.MultipartRequest('POST', _u('/v1/fc/characters'))
      ..headers.addAll(_headers)
      ..fields['name'] = name
      ..fields['auto_apose'] = autoAPose ? 'true' : 'false'
      ..files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename),
      );
    if (ownerId.isNotEmpty) req.fields['owner_id'] = ownerId;
    // opakovane pole; backend snese i jednu hodnotu oddelenou carkami
    for (final id in animationIds) {
      req.files.add(http.MultipartFile.fromString('animation_ids', id));
    }
    final resp = await http.Response.fromStream(await _client.send(req));
    _check(resp);
    return FcCharacter.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<FcCharacter> retry(String id, {String? fromStep}) async {
    final resp = await _client.post(
      _u('/v1/fc/characters/$id/retry'),
      headers: {'Content-Type': 'application/json', ..._headers},
      body: jsonEncode({'from_step': ?fromStep}),
    );
    _check(resp);
    return FcCharacter.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// Prehodi vyber klipu a pusti znovu jen animate+export - mesh se
  /// nepocita znovu.
  Future<FcCharacter> setAnimations(
    String id,
    List<String> animationIds,
  ) async {
    final resp = await _client.post(
      _u('/v1/fc/characters/$id/animations'),
      headers: {'Content-Type': 'application/json', ..._headers},
      body: jsonEncode({'animation_ids': animationIds}),
    );
    _check(resp);
    return FcCharacter.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<FcExport> export(String id, String target) async {
    final resp = await _client.post(
      _u('/v1/fc/characters/$id/export'),
      headers: {'Content-Type': 'application/json', ..._headers},
      body: jsonEncode({'target': target}),
    );
    _check(resp);
    return FcExport.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final resp = await _client.delete(
      _u('/v1/fc/characters/$id'),
      headers: _headers,
    );
    _check(resp);
  }

  String _abs(String path) => baseUrl.isEmpty ? path : '$baseUrl$path';

  String thumbUrl(String id) => _abs('/v1/fc/characters/$id/file/thumb_png');
  String glbUrl(String id) => _abs('/v1/fc/characters/$id/file/final_glb');
  String downloadUrl(String id, String format) =>
      _abs('/v1/fc/characters/$id/download?format=$format');

  /// Stranka 3D prohlizece pro postavu. Stejny duvod jako u jobu: model i
  /// skript jsou na jejim originu, takze WebView nenarazi na CORS ani na
  /// cleartext/ATS vyjimky.
  String viewerUrl(String id, {String? clip}) => _abs(
    '/v1/fc/characters/$id/viewer${clip == null || clip.isEmpty ? '' : '?clip=$clip'}',
  );

  /// SSE jen pro jednu postavu - telefon sledujici jednu generaci nema byt
  /// budeny provozem cele tovarny.
  Stream<Map<String, dynamic>> events(String id) async* {
    var backoff = const Duration(seconds: 1);
    while (true) {
      try {
        final req = http.Request('GET', _u('/v1/fc/characters/$id/events'))
          ..headers['Accept'] = 'text/event-stream'
          ..headers.addAll(_headers);
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
        // spadly socket / restart API - pockat a zkusit znovu
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
      throw FcApiException(resp.statusCode, msg);
    }
  }
}

class FcApiException implements Exception {
  FcApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => 'HTTP $status: $message';
}
