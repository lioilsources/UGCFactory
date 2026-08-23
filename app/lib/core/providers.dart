import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'models.dart';

/// Vychozi je tailnet adresa JODA: funguje doma i z mobilnich dat, protoze
/// Tailscale bezi na NASu, Sparku, Macu i telefonu. Zadny Cloudflare tunnel
/// k tomu neni potreba. LAN alternativa: http://192.168.88.88:8095
const defaultBaseUrl = 'http://joda.tailde0de8.ts.net:8095';

/// Web build servíruje samo ugc-api na /app/, takze API je na stejnem
/// originu - prazdny base URL znamena relativni cesty a zadne CORS ani
/// druhou auth (Access cookie plati pro cely origin).
String get initialBaseUrl => kIsWeb ? '' : defaultBaseUrl;

/// Cloudflare Access service token pro pristup pres ugc.ol1n.com bez
/// Tailscale. Predava se pri buildu (--dart-define), aby nebyl ve zdrojacich
/// na verejnem GitHubu; v Nastaveni jde prepsat.
const _buildClientId = String.fromEnvironment('CF_CLIENT_ID');
const _buildClientSecret = String.fromEnvironment('CF_CLIENT_SECRET');

final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main'),
);

final baseUrlProvider = StateProvider<String>((ref) {
  return ref.watch(prefsProvider).getString('baseUrl') ?? initialBaseUrl;
});

final cfClientIdProvider = StateProvider<String>((ref) =>
    ref.watch(prefsProvider).getString('cfClientId') ?? _buildClientId);

final cfClientSecretProvider = StateProvider<String>((ref) =>
    ref.watch(prefsProvider).getString('cfClientSecret') ?? _buildClientSecret);

final apiProvider = Provider<UgcApi>((ref) {
  return UgcApi(
    ref.watch(baseUrlProvider),
    clientId: ref.watch(cfClientIdProvider),
    clientSecret: ref.watch(cfClientSecretProvider),
  );
});

/// Zivy seznam jobu. SSE je hlavni signal, ale NESMI byt jediny: kdyz
/// spojeni spadne (restart ugc-api, uspani telefonu, prepnuti site),
/// appka by jinak navzdy ukazovala stara data - presne tak zustaly ve
/// fronte viset FAILy, ktere uz na serveru davno nebyly.
/// Proto jeste periodicky refresh a refresh pri navratu appky do popredi.
final jobsProvider =
    AsyncNotifierProvider<JobsNotifier, List<Job>>(JobsNotifier.new);

class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    final api = ref.watch(apiProvider);

    final sub = api.events().listen((_) => refresh());
    ref.onDispose(sub.cancel);

    final timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    ref.onDispose(timer.cancel);

    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(lifecycle.dispose);

    return api.jobs();
  }

  Future<void> refresh() async {
    final api = ref.read(apiProvider);
    try {
      state = AsyncData(await api.jobs());
    } catch (e, st) {
      // necha posledni dobra data, jen zaloguje chybu do stavu pri prvnim fetch
      if (state.value == null) state = AsyncError(e, st);
    }
  }
}

final itemsProvider = FutureProvider<List<Item>>((ref) {
  ref.watch(jobsProvider); // items se meni jen kdyz se hybou joby
  return ref.watch(apiProvider).items();
});

/// Job, ktery ma triage prave ukazovat. Bez toho se bere prvni z fronty -
/// jenze fronta se prubezne doplnuje o nove kusy ze Sparku, takze se karta
/// pod rukama meni. Drzime se jednoho jobu, dokud o nem uzivatel nerozhodne.
final currentTriageIdProvider = StateProvider<String?>((ref) => null);

/// Joby cekajici na triage (status new), nejstarsi prvni.
final triageQueueProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsProvider).value ?? const <Job>[];
  final fresh = jobs.where((j) => j.status == 'new').toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return fresh;
});
