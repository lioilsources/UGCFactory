import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'providers.dart';

/// Job, ktery se prave vari na Sparku (koncept -> cleanplate -> mesh).
/// Na NAS dorazi az po dokonceni, takze bez tohohle appka mezitim
/// neukazuje nic.
class PipelineJob {
  PipelineJob({
    required this.id,
    required this.stage,
    required this.category,
    required this.prompt,
    required this.collection,
    required this.error,
  });

  final String id;
  final String stage;
  final String category;
  final String prompt;
  final String collection;
  final String error;

  factory PipelineJob.fromJson(Map<String, dynamic> j) {
    final req = (j['request'] as Map<String, dynamic>?) ?? const {};
    return PipelineJob(
      id: j['id'] as String? ?? '',
      stage: j['stage'] as String? ?? '',
      category: req['category'] as String? ?? '',
      prompt: req['prompt'] as String? ?? '',
      collection: req['collection'] as String? ?? '',
      error: j['error'] as String? ?? '',
    );
  }

  bool get inFlight =>
      stage == 'queued' ||
      stage == 'concept' ||
      stage == 'cleanplate' ||
      stage == 'mesh' ||
      stage == 'push';

  String get stageLabel => switch (stage) {
        'queued' => 'ceka ve fronte',
        'concept' => 'kresli koncept',
        'cleanplate' => 'odmazava pozadi',
        'mesh' => 'modeluje 3D (~4 min)',
        'push' => 'posila na NAS',
        'done' => 'hotovo',
        'failed' => 'selhalo',
        _ => stage,
      };

  int get stageIndex => switch (stage) {
        'queued' => 0,
        'concept' => 1,
        'cleanplate' => 2,
        'mesh' => 3,
        'push' => 4,
        _ => 5,
      };
}

/// Poll kazdych 10 s - Spark nema SSE a stage se meni v minutach.
final pipelineJobsProvider = StreamProvider<List<PipelineJob>>((ref) async* {
  final base = ref.watch(baseUrlProvider);
  while (true) {
    try {
      final resp = await http
          .get(Uri.parse('$base/pipeline/jobs'))
          .timeout(const Duration(seconds: 12));
      final list = jsonDecode(resp.body) as List<dynamic>;
      yield list
          .map((e) => PipelineJob.fromJson(e as Map<String, dynamic>))
          .where((j) => j.inFlight)
          .toList()
        ..sort((a, b) => b.stageIndex.compareTo(a.stageIndex));
    } catch (_) {
      yield const <PipelineJob>[];
    }
    await Future<void>.delayed(const Duration(seconds: 10));
  }
});
