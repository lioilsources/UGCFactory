import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fc_models.dart';
import '../../core/providers.dart';
import '../../shared/model_view.dart';
import 'fc_list_screen.dart' show FcStatusBadge;

/// Detail postavy: 3D nahled, seznam klipu (tuknuti = prehrat), stav
/// pipeline a exporty.
class FcDetailScreen extends ConsumerStatefulWidget {
  const FcDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<FcDetailScreen> createState() => _FcDetailScreenState();
}

class _FcDetailScreenState extends ConsumerState<FcDetailScreen> {
  String? _clip;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(fcDetailProvider(widget.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.character.name ?? 'Postava'),
        actions: [
          if (detail.valueOrNull?.hasModel ?? false)
            PopupMenuButton<String>(
              icon: const Icon(Icons.ios_share),
              onSelected: (v) => _onAction(v, detail.value!),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'glb', child: Text('Stahnout GLB')),
                PopupMenuItem(value: 'fbx', child: Text('Stahnout FBX')),
                PopupMenuItem(value: 'zip', child: Text('Stahnout vse (ZIP)')),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'roblox',
                  child: Text('Poslat do Robloxu'),
                ),
                PopupMenuItem(value: 'luanti', child: Text('Poslat do Luanti')),
              ],
            ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', textAlign: TextAlign.center),
          ),
        ),
        data: (d) => _Body(
          detail: d,
          clip: _clip,
          onClip: (id) => setState(() => _clip = id),
          onRetry: () => _retry(d),
        ),
      ),
    );
  }

  Future<void> _retry(FcDetail d) async {
    final api = ref.read(fcApiProvider);
    try {
      await api.retry(d.character.id);
      ref.invalidate(fcDetailProvider(widget.id));
    } on Object catch (e) {
      _toast('$e');
    }
  }

  Future<void> _onAction(String action, FcDetail d) async {
    final api = ref.read(fcApiProvider);
    if (action == 'roblox' || action == 'luanti') {
      try {
        await api.export(d.character.id, action);
        _toast('Export do $action zarazen');
        ref.invalidate(fcDetailProvider(widget.id));
      } on Object catch (e) {
        _toast('$e');
      }
      return;
    }
    // Stazeni resi platforma: URL je stejne to jedine, co appka predava dal.
    _toast(api.downloadUrl(d.character.id, action));
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, maxLines: 3)));
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.detail,
    required this.clip,
    required this.onClip,
    required this.onRetry,
  });

  final FcDetail detail;
  final String? clip;
  final ValueChanged<String> onClip;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(fcApiProvider);
    final c = detail.character;
    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: detail.hasModel
              ? ModelView(
                  viewerUrl: api.viewerUrl(c.id, clip: clip),
                  glbUrl: api.glbUrl(c.id),
                  alt: c.name,
                  headers: api.accessHeaders,
                  clip: clip,
                  autoRotate: clip == null,
                )
              : _Pending(character: c, onRetry: onRetry),
        ),
        if (detail.clips.isNotEmpty) ...[
          const _SectionTitle('Klipy'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cl in detail.clips)
                  ChoiceChip(
                    label: Text(cl.label),
                    selected: clip == cl.animationId,
                    // dokud retarget nedobehne, klip v modelu jeste neni
                    onSelected: detail.hasModel && cl.hasFrames
                        ? (_) => onClip(cl.animationId)
                        : null,
                    avatar: cl.loop ? const Icon(Icons.loop, size: 16) : null,
                  ),
              ],
            ),
          ),
        ],
        const _SectionTitle('Pipeline'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FcStatusBadge(character: c),
        ),
        for (final s in detail.steps.where((s) => s.isFailed))
          ListTile(
            dense: true,
            leading: const Icon(Icons.error_outline, color: Colors.redAccent),
            title: Text('${s.step} (pokus ${s.attempt})'),
            subtitle: Text(s.error),
          ),
        if (c.isFailed)
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Zkusit krok znovu'),
            ),
          ),
        if (detail.exports.isNotEmpty) ...[
          const _SectionTitle('Exporty'),
          for (final e in detail.exports)
            ListTile(
              dense: true,
              title: Text(e.target),
              subtitle: Text(
                e.externalId.isNotEmpty
                    ? e.externalId
                    : (e.error.isNotEmpty ? e.error : e.status),
              ),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Nahrada 3D nahledu, dokud model neexistuje - stepper misto prazdna.
class _Pending extends StatelessWidget {
  const _Pending({required this.character, required this.onRetry});
  final FcCharacter character;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF14161A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (character.isFailed) ...[
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(character.error, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Zkusit znovu'),
                ),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(character.status),
                const SizedBox(height: 4),
                Text(
                  'krok ${character.step + 1} z ${FcCharacter.pipeline.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
