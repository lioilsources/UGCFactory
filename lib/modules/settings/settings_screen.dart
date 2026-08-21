import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ref.read(baseUrlProvider));
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastaveni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'ugc-api URL',
              helperText:
                  'LAN: http://192.168.88.88:8095 - pres tunnel: https://ugc.ol1n.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final url = _urlCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
              await ref.read(prefsProvider).setString('baseUrl', url);
              ref.read(baseUrlProvider.notifier).state = url;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ulozeno')));
              }
            },
            child: const Text('Ulozit'),
          ),
        ],
      ),
    );
  }
}
