import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/model_view.dart';

import '../../core/models.dart';
import '../../core/providers.dart';

/// Srdce appky: swipe triage nad joby ve stavu `new`.
/// Doprava = approve (do Blender konverze), doleva = reject,
/// tlacitko = reroll (stejny prompt, novy seed pres NAS -> Spark).
class TriageScreen extends ConsumerStatefulWidget {
  const TriageScreen({super.key});

  @override
  ConsumerState<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends ConsumerState<TriageScreen> {
  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(triageQueueProvider);
    final jobsAsync = ref.watch(jobsProvider);

    // Drz se rozdelaneho jobu i kdyz do fronty pribydou dalsi kusy.
    final currentId = ref.watch(currentTriageIdProvider);
    Job? current;
    if (currentId != null) {
      for (final j in queue) {
        if (j.id == currentId) {
          current = j;
          break;
        }
      }
    }
    if (current == null && queue.isNotEmpty) {
      current = queue.first;
      // Zamknout hned pri prvnim zobrazeni, jinak by se karta menila
      // s kazdou zmenou fronty, dokud uzivatel poprve nerozhodne.
      final lock = current.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(currentTriageIdProvider) != lock) {
          ref.read(currentTriageIdProvider.notifier).state = lock;
        }
      });
    }

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
        data: (_) => current == null
            ? const _EmptyView()
            : _TriageCard(job: current, key: ValueKey(current.id)),
      ),
    );
  }
}

class _TriageCard extends ConsumerStatefulWidget {
  const _TriageCard({required this.job, super.key});
  final Job job;

  @override
  ConsumerState<_TriageCard> createState() => _TriageCardState();
}

class _TriageCardState extends ConsumerState<_TriageCard> {
  // 3D model existuje uz pri triage (Spark ho posila spolu s konceptem),
  // takze se da rozhodovat podle meshe, ne jen podle obrazku.
  bool _show3d = false;

  Job get job => widget.job;

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
    _advance(ref);
    try {
      await action();
      if (context.mounted) _snack(context, label);
    } catch (e) {
      if (context.mounted) _snack(context, 'Chyba: $e');
    } finally {
      ref.read(jobsProvider.notifier).refresh();
    }
  }

  /// Posun na dalsi kus ve fronte. Vola se pred odeslanim akce, aby triage
  /// nezustala viset na jobu, ktery uz je rozhodnuty.
  void _advance(WidgetRef ref) {
    final queue = ref.read(triageQueueProvider);
    final idx = queue.indexWhere((j) => j.id == job.id);
    final next = (idx >= 0 && idx + 1 < queue.length) ? queue[idx + 1].id : null;
    ref.read(currentTriageIdProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _show3d
                        ? ModelView(
                            key: ValueKey('triage-3d-${job.id}'),
                            viewerUrl: api.viewerUrl(job.id),
                            glbUrl: api.glbUrl(job.id),
                            alt: job.prompt,
                            headers: api.authHeaders,
                          )
                        : Image.network(
                            api.previewUrl(job.id),
                            fit: BoxFit.contain,
                            errorBuilder: (_, e, st) => const Center(
                              child: Icon(Icons.image_not_supported, size: 64),
                            ),
                          ),
                  ),
                  ListTile(
                    title: Text(job.prompt,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${job.category} - ${job.style} - ${job.collection}'),
                    trailing: IconButton.filledTonal(
                      tooltip: _show3d ? 'Zpet na koncept' : 'Ukaz 3D model',
                      icon: Icon(_show3d ? Icons.image : Icons.view_in_ar),
                      onPressed: () => setState(() => _show3d = !_show3d),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Swipe tu byl driv, ale koliduje s otacenim 3D modelu - orbit
          // gesto a "dismiss" jsou totez tazeni. Rozhoduje se tlacitky.
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
