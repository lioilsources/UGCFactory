import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/model_view.dart';

import '../../core/models.dart';
import '../../core/providers.dart';

/// 3D Review: otoc si model, pod nim cisla z konverze a rozhodnuti.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    final report = job.report ?? const <String, dynamic>{};
    final tris = report['tri_count'];
    final maxTris = report['max_tris'];
    final verdictColor = switch (job.verdict) {
      'PASS' => Colors.green,
      'WARN' => Colors.amber,
      'FAIL' => Colors.red,
      _ => Colors.grey,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(job.category),
        actions: [
          if (job.verdict.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(job.verdict),
                backgroundColor: verdictColor.withValues(alpha: 0.15),
                labelStyle: TextStyle(color: verdictColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ModelView(
              key: ValueKey('mv-${job.id}'),
              viewerUrl: api.viewerUrl(job.id),
              glbUrl: api.glbUrl(job.id),
              alt: job.prompt,
              headers: api.authHeaders,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.prompt,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (tris != null)
                      _Stat(
                        label: 'trojuhelniky',
                        value: '$tris${maxTris != null ? " / $maxTris" : ""}',
                        ok: maxTris == null || (tris as int) <= (maxTris as int),
                      ),
                    if (report['uv_ok'] != null)
                      _Stat(
                        label: 'UV',
                        value: report['uv_ok'] == true ? 'ano' : 'ne',
                        ok: report['uv_ok'] == true,
                      ),
                    if (report['watertight'] != null)
                      _Stat(
                        label: 'watertight',
                        value: report['watertight'] == true ? 'ano' : 'ne',
                        ok: report['watertight'] == true,
                      ),
                    if (report['texture_size'] != null)
                      _Stat(
                        label: 'textura',
                        value: '${report['texture_size']} px',
                        ok: true,
                      ),
                  ],
                ),
                for (final r
                    in (report['verdict_reasons'] as List<dynamic>? ?? const []))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• $r',
                        style: TextStyle(color: verdictColor, fontSize: 12)),
                  ),
              ],
            ),
          ),
          if (job.status == 'converted' || job.status == 'failed')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: const Text('Konvertovat znovu'),
                      onPressed: () async {
                        await api.reconvert(job.id);
                        ref.read(jobsProvider.notifier).refresh();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Zabalit'),
                      onPressed: job.status != 'converted'
                          ? null
                          : () async {
                              await api.approve(job.id);
                              ref.read(jobsProvider.notifier).refresh();
                              if (context.mounted) Navigator.pop(context);
                            },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.ok});
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final c = ok ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value', style: TextStyle(color: c, fontSize: 12)),
    );
  }
}
