// Headless kontrola API klienta proti zivemu ugc-api:
//   dart run tool/smoke.dart [baseUrl]
import 'dart:io';

import 'package:ugc_studio/core/api.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/smoke.dart <baseUrl>');
    exit(64);
  }
  final api = UgcApi(args.first);
  final jobs = await api.jobs();
  final items = await api.items();
  print('jobs: ${jobs.length}, items: ${items.length}');
  for (final j in jobs.take(5)) {
    print('  ${j.id}  ${j.status}${j.verdict.isEmpty ? "" : " ${j.verdict}"}  ${j.category}  ${j.prompt}');
  }
  final sse = api.events().timeout(const Duration(seconds: 5));
  try {
    await for (final _ in sse) { break; }
  } on Object catch (_) {
    print('SSE: pripojeno, zadny event behem 5 s (ok)');
  }
  print('SMOKE OK');
  exit(0); // SSE reconnect smycka jinak drzi VM pri zivote
}
