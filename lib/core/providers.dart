import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'models.dart';

/// Vychozi je LAN adresa JODA; az pojede tunnel, prepne se v Nastaveni
/// na https://ugc.ol1n.com.
const defaultBaseUrl = 'http://192.168.88.88:8095';

final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main'),
);

final baseUrlProvider = StateProvider<String>((ref) {
  return ref.watch(prefsProvider).getString('baseUrl') ?? defaultBaseUrl;
});

final apiProvider = Provider<UgcApi>((ref) {
  return UgcApi(ref.watch(baseUrlProvider));
});

/// Zivy seznam jobu: fetch pri startu + refetch po kazdem SSE eventu.
/// SSE nese cele joby, ale refetch drzi jednu cestu pravdy (levny, radove
/// stovky radku).
final jobsProvider =
    AsyncNotifierProvider<JobsNotifier, List<Job>>(JobsNotifier.new);

class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    final api = ref.watch(apiProvider);
    final sub = api.events().listen((_) => refresh());
    ref.onDispose(sub.cancel);
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

/// Joby cekajici na triage (status new), nejstarsi prvni.
final triageQueueProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsProvider).value ?? const <Job>[];
  final fresh = jobs.where((j) => j.status == 'new').toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return fresh;
});
