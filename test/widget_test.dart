import 'package:flutter_test/flutter_test.dart';
import 'package:ugc_studio/core/models.dart';

void main() {
  test('Job parses ugc-api JSON', () {
    final job = Job.fromJson({
      'id': 'ugc-1',
      'status': 'converted',
      'prompt': 'ornate samurai kabuto helmet',
      'category': 'helmet',
      'collection': 'Samurai Neon',
      'verdict': 'PASS',
      'report': {'tri_count': 3600},
      'created_at': '2026-08-21T16:00:00Z',
      'updated_at': '2026-08-21T16:05:00Z',
    });
    expect(job.status, 'converted');
    expect(job.triCount, 3600);
    expect(job.verdict, 'PASS');
  });

  test('Item parses with defaults', () {
    final item = Item.fromJson({'id': 'x', 'name': 'kabuto', 'state': 'packed'});
    expect(item.priceRobux, 0);
    expect(item.state, 'packed');
  });
}
