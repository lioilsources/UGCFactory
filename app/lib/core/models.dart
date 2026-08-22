/// Datove modely zrcadli JSON ugc-api (ugc-backend/main.go).
class Job {
  final String id;
  final String status;
  final String prompt;
  final String category;
  final String style;
  final String backend;
  final String collection;
  final String verdict;
  final String error;
  final Map<String, dynamic>? report;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.status,
    required this.prompt,
    required this.category,
    required this.style,
    required this.backend,
    required this.collection,
    required this.verdict,
    required this.error,
    required this.report,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> j) => Job(
        id: j['id'] as String,
        status: j['status'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        category: j['category'] as String? ?? '',
        style: j['style'] as String? ?? '',
        backend: j['backend'] as String? ?? '',
        collection: j['collection'] as String? ?? '',
        verdict: j['verdict'] as String? ?? '',
        error: j['error'] as String? ?? '',
        report: j['report'] as Map<String, dynamic>?,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );

  int? get triCount => report?['tri_count'] as int?;
}

class Item {
  final String id;
  final String name;
  final String category;
  final String collection;
  final String state;
  final int priceRobux;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.collection,
    required this.state,
    required this.priceRobux,
  });

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        category: j['category'] as String? ?? '',
        collection: j['collection'] as String? ?? '',
        state: j['state'] as String? ?? '',
        priceRobux: (j['price_robux'] as num?)?.toInt() ?? 0,
      );
}
