import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 3D nahled modelu.
///
/// Na mobilu nacita stranku prohlizece z ugc-api (same-origin: stranka,
/// model i skript), protoze lokalni proxy model_viewer_plus narazi na jinou
/// platformni past na kazdem systemu - cleartext localhost na Androidu,
/// ATS ve WKWebView na iOS, CORS vsude. Na webu je appka sama same-origin
/// s API, takze tam staci ModelViewer primo.
class ModelView extends StatefulWidget {
  const ModelView({
    super.key,
    required this.viewerUrl,
    required this.glbUrl,
    this.alt = '',
    this.headers = const {},
  });

  final String viewerUrl;
  final String glbUrl;
  final String alt;

  /// Cloudflare Access hlavicky. Staci je poslat s prvni strankou - CF
  /// odpovi cookie CF_Authorization, kterou WebView pouzije i pro model
  /// a skript (subresources uz vlastni hlavicky neprenesou).
  final Map<String, String> headers;

  @override
  State<ModelView> createState() => _ModelViewState();
}

class _ModelViewState extends State<ModelView> {
  WebViewController? _controller;
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF14161A))
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
          onWebResourceError: (e) => setState(() => _error = e.description),
        ))
        ..loadRequest(Uri.parse(widget.viewerUrl), headers: widget.headers);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return ModelViewer(
        src: widget.glbUrl,
        alt: widget.alt,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: const Color(0xFF14161A),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '3D se nenacetlo:\n${_error!}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
      ],
    );
  }
}
