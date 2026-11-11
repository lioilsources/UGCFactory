import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// Nastaveni pripojeni: kam appka mluvi a cim se prokazuje.
///
/// Tailnet adresa nepotrebuje nic navic, ugc.ol1n.com chce Cloudflare
/// Access service token (jde predat i pri buildu pres --dart-define).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _secretCtrl;
  String? _status;
  bool _statusOk = false;
  bool _testing = false;

  static const _tailnet = tailnetUrl;
  static const _tunnel = 'https://ugc.ol1n.com';

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ref.read(baseUrlProvider));
    _idCtrl = TextEditingController(text: ref.read(cfClientIdProvider));
    _secretCtrl = TextEditingController(text: ref.read(cfClientSecretProvider));
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _idCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool test = true}) async {
    final l = AppLocalizations.of(context);
    final prefs = ref.read(prefsProvider);
    final url = _urlCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString('baseUrl', url);
    await prefs.setString('cfClientId', _idCtrl.text.trim());
    await prefs.setString('cfClientSecret', _secretCtrl.text.trim());
    ref.read(baseUrlProvider.notifier).state = url;
    ref.read(cfClientIdProvider.notifier).state = _idCtrl.text.trim();
    ref.read(cfClientSecretProvider.notifier).state = _secretCtrl.text.trim();

    if (!test) return;
    setState(() {
      _testing = true;
      _status = null;
    });
    try {
      final jobs = await ref.read(apiProvider).jobs(limit: 1);
      setState(() {
        _statusOk = true;
        _status = l.connOk(jobs.length);
      });
      ref.read(jobsProvider.notifier).refresh();
    } catch (e) {
      setState(() {
        _statusOk = false;
        _status = l.connFailed('$e');
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ok = _statusOk;
    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: _tailnet,
                label: Text('Tailscale'),
                icon: Icon(Icons.vpn_lock),
              ),
              ButtonSegment(
                value: _tunnel,
                label: Text('Internet'),
                icon: Icon(Icons.public),
              ),
            ],
            selected: {
              _urlCtrl.text.startsWith('https://') ? _tunnel : _tailnet,
            },
            onSelectionChanged: (sel) =>
                setState(() => _urlCtrl.text = sel.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'ugc-api URL',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            maxLines: null,
          ),
          const SizedBox(height: 20),
          Text(
            'Cloudflare Access',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            l.cfAccessHelp,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _idCtrl,
            decoration: const InputDecoration(
              labelText: 'Client ID',
              hintText: '....access',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _secretCtrl,
            decoration: const InputDecoration(
              labelText: 'Client Secret',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _testing ? null : _save,
            icon: _testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(l.saveAndTest),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _status!,
                style: TextStyle(color: ok ? Colors.green : Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
