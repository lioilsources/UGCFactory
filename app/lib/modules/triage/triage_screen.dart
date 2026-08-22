import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';

/// Srdce appky: swipe triage nad joby ve stavu `new`.
/// Doprava = approve (do Blender konverze), doleva = reject,
/// tlacitko = reroll (stejny prompt, novy seed pres NAS -> Spark).
class TriageScreen extends ConsumerWidget {
  const TriageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(triageQueueProvider);
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Triage${queue.isEmpty ? '' : ' (${queue.length})'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(jobsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: '$e'),
        data: (_) => queue.isEmpty
            ? const _EmptyView()
            : _TriageCard(job: queue.first, key: ValueKey(queue.first.id)),
      ),
    );
  }
}

class _TriageCard extends ConsumerWidget {
  const _TriageCard({required this.job, super.key});
  final Job job;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Future<Job> Function() action,
    String label,
  ) async {
    try {
      await action();
      if (context.mounted) _snack(context, label);
    } catch (e) {
      if (context.mounted) _snack(context, 'Chyba: $e');
    } finally {
      ref.read(jobsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Dismissible(
              key: ValueKey('dismiss-${job.id}'),
              direction: DismissDirection.horizontal,
              onDismissed: (dir) {
                if (dir == DismissDirection.startToEnd) {
                  _act(context, ref, () => api.approve(job.id), 'Schvaleno -> konverze');
                } else {
                  _act(context, ref, () => api.reject(job.id), 'Zamitnuto');
                }
              },
              background: const _SwipeHint(
                alignment: Alignment.centerLeft,
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'APPROVE',
              ),
              secondaryBackground: const _SwipeHint(
                alignment: Alignment.centerRight,
                icon: Icons.cancel,
                color: Colors.red,
                label: 'REJECT',
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        api.previewUrl(job.id),
                        fit: BoxFit.contain,
                        errorBuilder: (_, e, st) => const Center(
                          child: Icon(Icons.image_not_supported, size: 64),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(job.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${job.category} - ${job.style} - ${job.collection} - seed ${job.id.hashCode & 0xffff}'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundButton(
                icon: Icons.close,
                color: Colors.red,
                onTap: () => _act(context, ref, () => api.reject(job.id), 'Zamitnuto'),
              ),
              _RoundButton(
                icon: Icons.casino,
                color: Colors.amber,
                onTap: () => _act(context, ref, () => api.reroll(job.id), 'Reroll poslan na Spark'),
              ),
              _RoundButton(
                icon: Icons.check,
                color: Colors.green,
                onTap: () => _act(context, ref, () => api.approve(job.id), 'Schvaleno -> konverze'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.alignment,
    required this.icon,
    required this.color,
    required this.label,
  });
  final Alignment alignment;
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: icon.codePoint,
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color,
      onPressed: onTap,
      child: Icon(icon, size: 32),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all, size: 72),
          SizedBox(height: 12),
          Text('Vse roztrizeno. Poslat novy batch v Composeru?'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('NAS nedostupny:\n$error', textAlign: TextAlign.center),
      ),
    );
  }
}
