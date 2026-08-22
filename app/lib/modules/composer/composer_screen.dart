import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Batch Composer: matice kategorie x prompt -> POST /generate per kombinace.
/// Styl a kolekce drzi vizualni jednotu (style-lock kolekce).
class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({super.key});
  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  // Produkci overene kategorie napred (smoke test 2026-08-21); hair je
  // zname riziko - Illustrious neumi vlasy bez hlavy.
  static const categories = [
    ('helmet', 'Helma', true),
    ('back', 'Kridla / zada', true),
    ('sword', 'Mec', true),
    ('front', 'Hrudni plat', false),
    ('hat', 'Cepice', false),
    ('hair', 'Vlasy (riziko)', false),
  ];

  static const stylePresets = [
    'cyberpunk neon',
    'medieval fantasy',
    'dark gothic',
    'pastel kawaii',
    'steampunk brass',
    'ice crystal',
  ];

  final _promptCtrl = TextEditingController();
  final _collectionCtrl = TextEditingController();
  final Set<String> _selected = {'helmet'};
  String _style = stylePresets.first;
  int _variants = 1;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsProvider);
    _promptCtrl.text = prefs.getString('composer.prompt') ?? '';
    _collectionCtrl.text = prefs.getString('composer.collection') ?? '';
    _style = prefs.getString('composer.style') ?? stylePresets.first;
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _collectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final prompt = _promptCtrl.text.trim();
    final collection = _collectionCtrl.text.trim();
    if (prompt.isEmpty || _selected.isEmpty) return;

    final prefs = ref.read(prefsProvider);
    await prefs.setString('composer.prompt', prompt);
    await prefs.setString('composer.collection', collection);
    await prefs.setString('composer.style', _style);

    setState(() => _sending = true);
    final api = ref.read(apiProvider);
    var sent = 0;
    final errors = <String>[];
    for (final cat in _selected) {
      for (var v = 0; v < _variants; v++) {
        try {
          // Prompt muze obsahovat {category} placeholder.
          await api.generate(
            prompt: prompt.replaceAll('{category}', cat),
            category: cat,
            style: _style,
            collection: collection,
            seed: DateTime.now().microsecondsSinceEpoch % 2147483647 + v,
          );
          sent++;
        } catch (e) {
          errors.add('$cat: $e');
        }
      }
    }
    setState(() => _sending = false);
    if (!mounted) return;
    final msg = errors.isEmpty
        ? 'Odeslano $sent jobu - Spark generuje (~4 min/kus, serializovane)'
        : 'Odeslano $sent, chyby: ${errors.join('; ')}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final total = _selected.length * _variants;
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Composer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _promptCtrl,
            decoration: const InputDecoration(
              labelText: 'Prompt itemu',
              hintText: 'ornate samurai {category} with neon accents',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('Kategorie', style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              for (final (key, label, ready) in categories)
                FilterChip(
                  label: Text(label),
                  avatar: ready ? const Icon(Icons.verified, size: 16) : null,
                  selected: _selected.contains(key),
                  onSelected: (sel) => setState(() {
                    sel ? _selected.add(key) : _selected.remove(key);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: _style,
            label: const Text('Styl'),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final s in stylePresets) DropdownMenuEntry(value: s, label: s),
            ],
            onSelected: (s) => setState(() => _style = s ?? _style),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _collectionCtrl,
            decoration: const InputDecoration(
              labelText: 'Kolekce',
              hintText: 'Samurai Neon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Varianty na kategorii: $_variants'),
              Expanded(
                child: Slider(
                  value: _variants.toDouble(),
                  min: 1,
                  max: 4,
                  divisions: 3,
                  onChanged: (v) => setState(() => _variants = v.round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _sending || total == 0 ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.rocket_launch),
            label: Text('Vygenerovat $total ${total == 1 ? "item" : "itemy"}'
                ' (~${(total * 4)} min)'),
          ),
        ],
      ),
    );
  }
}
