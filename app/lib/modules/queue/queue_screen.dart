import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/pipeline.dart';
import '../../core/providers.dart';
import '../review/review_screen.dart';

/// Zivy prehled fronty: joby seskupene podle stavu, SSE drzi data cerstva.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  static const _order = [
    'new', 'remeshing', 'approved', 'converting', 'converted', 'packed',
    'failed', 'rejected', 'rerolled',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fronta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(jobsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('NAS nedostupny: $e')),
        data: (jobs) {
          final byStatus = <String, List<Job>>{};
          for (final j in jobs) {
            byStatus.putIfAbsent(j.status, () => []).add(j);
          }
          final sections = _order.where(byStatus.containsKey).toList();
          if (sections.isEmpty) {
            return ListView(children: const [
              _SparkSection(),
              Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Na NASu zatim nic - posli batch v Composeru.')),
              ),
            ]);
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(jobsProvider.notifier).refresh(),
            child: ListView(
              children: [
                const _SparkSection(),
                for (final status in sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      '${_label(status)} (${byStatus[status]!.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final job in byStatus[status]!) _JobTile(job: job),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _label(String s) => switch (s) {
        'new' => 'Ceka na triage',
        'remeshing' => 'Prepocitava se v TRELLIS (~4 min)',
        'approved' => 'Ve fronte na konverzi',
        'converting' => 'Konvertuje se',
        'converted' => 'Zkonvertovano - ceka na 3D review',
        'packed' => 'Zabaleno pro Studio',
        'failed' => 'Selhalo',
        'rejected' => 'Zamitnuto',
        'rerolled' => 'Rerollnuto',
        _ => s,
      };
}

class _JobTile extends ConsumerWidget {
  const _JobTile({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    final verdictColor = switch (job.verdict) {
      'PASS' => Colors.green,
      'WARN' => Colors.amber,
      'FAIL' => Colors.red,
      _ => null,
    };
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReviewScreen(job: job),
      )),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          api.previewUrl(job.id),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) =>
              const SizedBox(width: 48, child: Icon(Icons.category)),
        ),
      ),
      title: Text(job.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          job.category,
          job.collection,
          if (job.triCount != null) '${job.triCount} tris',
          if (job.error.isNotEmpty) job.error,
          'klepni pro 3D',
        ].join(' - '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.view_in_ar, size: 20),
          const SizedBox(width: 4),
          if (job.verdict.isNotEmpty)
            Chip(
              label: Text(job.verdict),
              backgroundColor: verdictColor?.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: verdictColor),
              visualDensity: VisualDensity.compact,
            ),
          if (job.status == 'converted' || job.status == 'failed')
            IconButton(
              tooltip: job.status == 'converted' ? 'Zabalit' : 'Zkusit znovu',
              icon: Icon(job.status == 'converted'
                  ? Icons.inventory_2
                  : Icons.replay),
              onPressed: () async {
                final action = job.status == 'converted'
                    ? api.approve(job.id)
                    : api.reconvert(job.id);
                try {
                  await action;
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
                ref.read(jobsProvider.notifier).refresh();
              },
            ),
        ],
      ),
    );
  }
}


/// Joby, ktere se prave vari na Sparku. Na NAS dorazi az hotove, takze
/// bez teto sekce appka behem generovani (~4 min) neukazuje nic.
class _SparkSection extends ConsumerWidget {
  const _SparkSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(pipelineJobsProvider).value ?? const <PipelineJob>[];
    if (jobs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('Vyrabi se na Sparku (${jobs.length})',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final j in jobs)
          ListTile(
            leading: const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            title: Text(j.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${j.category} - ${j.stageLabel}'),
          ),
        const Divider(height: 24),
      ],
    );
  }
}
