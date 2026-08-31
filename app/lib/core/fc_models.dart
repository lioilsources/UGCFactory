/// Datove modely fantasy-character casti API (nas/characters.go).
///
/// Oddelene od models.dart zamerne: UGC joby a FC postavy jsou dve domeny
/// jedne tovarny, ktere spolu nesdili ani stav, ani auth scope.
library;

class FcCharacter {
  final String id;
  final String name;
  final String status;
  final String error;
  final int triCount;
  final bool autoAPose;
  final DateTime createdAt;

  FcCharacter({
    required this.id,
    required this.name,
    required this.status,
    required this.error,
    required this.triCount,
    required this.autoAPose,
    required this.createdAt,
  });

  factory FcCharacter.fromJson(Map<String, dynamic> j) => FcCharacter(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    status: j['status'] as String? ?? '',
    error: j['error'] as String? ?? '',
    triCount: (j['tri_count'] as num?)?.toInt() ?? 0,
    autoAPose: j['auto_apose'] as bool? ?? true,
    createdAt:
        DateTime.tryParse(j['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Kroky pipeline v poradi, jak je posila backend. Slouzi stepperu -
  /// index stavu je zaroven pocet hotovych kroku.
  static const pipeline = [
    'uploaded',
    'preprocessed',
    'meshed',
    'cleaned',
    'rigged',
    'animated',
    'exported',
    'done',
  ];

  bool get isFailed => status == 'failed';
  bool get isDone => status == 'done';

  /// -1 pro 'failed': u nej stepper ukazuje chybu, ne pozici.
  int get step => pipeline.indexOf(status);

  double get progress {
    final i = step;
    if (i < 0) return 0;
    return i / (pipeline.length - 1);
  }
}

/// Klip zapeceny do postavy. [frameStart]/[frameEnd] vyplni retarget.py na
/// slozene timeline; Luanti je pouziva primo, glTF viewer si vystaci se jmenem.
class FcClip {
  final String animationId;
  final String name;
  final String category;
  final bool loop;
  final int frameStart;
  final int frameEnd;

  FcClip({
    required this.animationId,
    required this.name,
    required this.category,
    required this.loop,
    required this.frameStart,
    required this.frameEnd,
  });

  factory FcClip.fromJson(Map<String, dynamic> j) => FcClip(
    animationId: j['animation_id'] as String,
    name: j['name'] as String? ?? '',
    category: j['category'] as String? ?? '',
    loop: j['loop'] as bool? ?? false,
    frameStart: (j['frame_start'] as num?)?.toInt() ?? 0,
    frameEnd: (j['frame_end'] as num?)?.toInt() ?? 0,
  );

  String get label => name.isEmpty ? animationId : name;

  /// Dokud retarget nedobehne, jsou rozsahy nulove - klip existuje, ale v
  /// modelu jeste neni.
  bool get hasFrames => frameEnd > frameStart;
}

/// Polozka knihovny animaci (/v1/fc/animations).
class FcAnimation {
  final String id;
  final String name;
  final String category;
  final String source;
  final String license;
  final int frames;
  final int fps;
  final bool loop;

  FcAnimation({
    required this.id,
    required this.name,
    required this.category,
    required this.source,
    required this.license,
    required this.frames,
    required this.fps,
    required this.loop,
  });

  factory FcAnimation.fromJson(Map<String, dynamic> j) => FcAnimation(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    category: j['category'] as String? ?? 'misc',
    source: j['source'] as String? ?? '',
    license: j['license'] as String? ?? '',
    frames: (j['frames'] as num?)?.toInt() ?? 0,
    fps: (j['fps'] as num?)?.toInt() ?? 30,
    loop: j['loop'] as bool? ?? false,
  );

  String get label => name.isEmpty ? id : name;
}

/// Jeden pokus o krok pipeline. Backend drzi kazdy pokus zvlast, aby po
/// retry zustala videt puvodni chyba.
class FcStep {
  final int id;
  final String step;
  final String status;
  final String error;
  final int attempt;

  FcStep({
    required this.id,
    required this.step,
    required this.status,
    required this.error,
    required this.attempt,
  });

  factory FcStep.fromJson(Map<String, dynamic> j) => FcStep(
    id: (j['id'] as num).toInt(),
    step: j['step'] as String? ?? '',
    status: j['status'] as String? ?? '',
    error: j['error'] as String? ?? '',
    attempt: (j['attempt'] as num?)?.toInt() ?? 1,
  );

  bool get isFailed => status == 'failed';
}

class FcExport {
  final String id;
  final String target;
  final String status;
  final String externalId;
  final String error;

  FcExport({
    required this.id,
    required this.target,
    required this.status,
    required this.externalId,
    required this.error,
  });

  factory FcExport.fromJson(Map<String, dynamic> j) => FcExport(
    id: j['id'] as String,
    target: j['target'] as String? ?? '',
    status: j['status'] as String? ?? '',
    externalId: j['external_id'] as String? ?? '',
    error: j['error'] as String? ?? '',
  );
}

/// Odpoved GET /v1/fc/characters/{id}: postava plus vsechno kolem ni.
class FcDetail {
  final FcCharacter character;
  final List<FcClip> clips;
  final List<FcStep> steps;
  final List<FcExport> exports;

  /// Klic je nazev artefaktu (final_glb, thumb_png, ...), hodnota cesta na
  /// API. Backend sem dava jen to, co uz na disku opravdu je, takze appka
  /// nemusi hadat podle stavu, co uz jde nabidnout.
  final Map<String, String> artifacts;

  FcDetail({
    required this.character,
    required this.clips,
    required this.steps,
    required this.exports,
    required this.artifacts,
  });

  factory FcDetail.fromJson(Map<String, dynamic> j) => FcDetail(
    character: FcCharacter.fromJson(j['character'] as Map<String, dynamic>),
    clips: ((j['animations'] as List<dynamic>?) ?? const [])
        .map((e) => FcClip.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    steps: ((j['steps'] as List<dynamic>?) ?? const [])
        .map((e) => FcStep.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    exports: ((j['exports'] as List<dynamic>?) ?? const [])
        .map((e) => FcExport.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    artifacts: ((j['artifacts'] as Map<String, dynamic>?) ?? const {}).map(
      (k, v) => MapEntry(k, v as String),
    ),
  );

  bool get hasModel => artifacts.containsKey('final_glb');

  /// Posledni selhavsi krok - to je ten, ktery retry zaradi znovu.
  FcStep? get failedStep {
    for (final s in steps.reversed) {
      if (s.isFailed) return s;
    }
    return null;
  }
}
