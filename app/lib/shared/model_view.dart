import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 3D nahled modelu.
///
/// [clip] prehraje pojmenovanou animaci (FC postavy). Na mobilu se prepina
/// pres window.fcPlay() ve strance prohlizece - reload s jinym parametrem by
/// pri kazdem tuknuti na klip stahoval cely GLB znovu.
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
    this.clip,
    this.autoRotate = true,
  });

  final String viewerUrl;
  final String glbUrl;
  final String alt;

  /// Nazev klipu v glTF; odpovida animation_id z knihovny, protoze
  /// fc_retarget.py pojmenovava NLA tracky prave jim.
  final String? clip;

  final bool autoRotate;

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
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (p) => setState(() => _progress = p),
            onWebResourceError: (e) => setState(() => _error = e.description),
          ),
        )
        ..loadRequest(Uri.parse(widget.viewerUrl), headers: widget.headers);
    }
  }

  @override
  void didUpdateWidget(ModelView old) {
    super.didUpdateWidget(old);
    if (!kIsWeb && widget.clip != old.clip && widget.clip != null) {
      // Stranka uz muze byt nactena, nebo taky ne; kdyz jeste neni, klip
      // si vezme z ?clip= pri prvnim nacteni, takze selhani tady nevadi.
      _controller?.runJavaScript("window.fcPlay && fcPlay('${widget.clip}')");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return ModelViewer(
        src: widget.glbUrl,
        alt: widget.alt,
        autoRotate: widget.autoRotate,
        autoPlay: widget.clip != null,
        animationName: widget.clip,
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
