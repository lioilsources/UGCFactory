import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/fc_models.dart';
import '../../core/providers.dart';

/// Zalozeni postavy: obrazek, jmeno, vyber klipu.
///
/// Klipy se vybiraji uz tady, protoze retarget je soucast te same pipeline -
/// pridat je pozdeji jde (`/animations` prepocita jen animate+export), ale
/// prvni beh je levnejsi s nimi.
class FcCreateScreen extends ConsumerStatefulWidget {
  const FcCreateScreen({super.key});

  @override
  ConsumerState<FcCreateScreen> createState() => _FcCreateScreenState();
}

class _FcCreateScreenState extends ConsumerState<FcCreateScreen> {
  final _name = TextEditingController();
  final _picker = ImagePicker();
  final _selected = <String>{};

  XFile? _image;
  Uint8List? _bytes;
  bool _autoAPose = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 2048);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _image = file;
      _bytes = bytes;
      if (_name.text.isEmpty) _name.text = _nameFrom(file.name);
    });
  }

  /// Z nazvu souboru udela lidsky nazev - "knight_01.png" -> "Knight 01".
  static String _nameFrom(String filename) {
    final base = filename.split('/').last.split('.').first;
    final words = base
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1));
    return words.join(' ');
  }

  bool get _canSubmit =>
      !_busy &&
      _bytes != null &&
      _name.text.trim().isNotEmpty &&
      _selected.isNotEmpty;

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final character = await ref
          .read(fcApiProvider)
          .create(
            name: _name.text.trim(),
            imageBytes: _bytes!,
            filename: _image!.name,
            animationIds: _selected.toList(),
            autoAPose: _autoAPose,
          );
      ref.invalidate(fcCharactersProvider);
      if (!mounted) return;
      context.go('/fc/${character.id}');
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$e', maxLines: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final animations = ref.watch(fcAnimationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nova postava')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: _canSubmit ? _submit : null,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_busy ? 'Zakladam...' : 'Vygenerovat'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ImagePicker(
            bytes: _bytes,
            onGallery: () => _pick(ImageSource.gallery),
            onCamera: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Jmeno',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            value: _autoAPose,
            onChanged: (v) => setState(() => _autoAPose = v),
            title: const Text('Auto A-pose'),
            subtitle: const Text(
              'Prekresli postavu do A-pose. Bez toho rig u akcnich poz casto selze.',
            ),
          ),
          const Divider(),
          Text('Animace', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          animations.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Knihovnu se nepodarilo nacist: $e'),
            data: (list) => list.isEmpty
                ? const Text(
                    'Knihovna je prazdna. Klipy se registruji skriptem '
                    'seed_animlib.py na NASu.',
                  )
                : _AnimationPicker(
                    animations: list,
                    selected: _selected,
                    onToggle: (id) => setState(() {
                      _selected.contains(id)
                          ? _selected.remove(id)
                          : _selected.add(id);
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.bytes,
    required this.onGallery,
    required this.onCamera,
  });

  final Uint8List? bytes;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2126),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes == null
                ? const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.white24,
                    ),
                  )
                : Image.memory(bytes!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Fotoaparat'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimationPicker extends StatelessWidget {
  const _AnimationPicker({
    required this.animations,
    required this.selected,
    required this.onToggle,
  });

  final List<FcAnimation> animations;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, List<FcAnimation>>{};
    for (final a in animations) {
      byCategory.putIfAbsent(a.category, () => []).add(a);
    }
    final categories = byCategory.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in categories) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              category,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in byCategory[category]!)
                FilterChip(
                  label: Text(a.label),
                  selected: selected.contains(a.id),
                  onSelected: (_) => onToggle(a.id),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
