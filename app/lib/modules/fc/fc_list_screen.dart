import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/fc_models.dart';
import '../../core/providers.dart';

/// Galerie postav. Stav je na kartach videt primo, protoze pipeline ma sest
/// kroku a "generuje se" by u tri minut cekani nestacilo.
class FcListScreen extends ConsumerWidget {
  const FcListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(fcCharactersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Postavy')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/fc/new'),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nova'),
      ),
      body: characters.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Error(
          message: '$e',
          onRetry: () => ref.invalidate(fcCharactersProvider),
        ),
        data: (list) {
          if (list.isEmpty) return const _Empty();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(fcCharactersProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) => _CharacterCard(character: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CharacterCard extends ConsumerWidget {
  const _CharacterCard({required this.character});
  final FcCharacter character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(fcApiProvider);
    return InkWell(
      onTap: () => context.go('/fc/${character.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                api.thumbUrl(character.id),
                headers: api.accessHeaders,
                fit: BoxFit.cover,
                // thumb vznika az v poslednim kroku; do te doby placeholder
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFF1E2126),
                  child: Icon(
                    Icons.person_outline,
                    size: 48,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  FcStatusBadge(character: character),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Odznak stavu. Neuspech dostane cervenou a jmeno kroku, protoze "failed"
/// samo o sobe uzivateli nerekne, jestli ma zkusit znovu, nebo zmenit foto.
class FcStatusBadge extends StatelessWidget {
  const FcStatusBadge({super.key, required this.character});
  final FcCharacter character;

  @override
  Widget build(BuildContext context) {
    if (character.isFailed) {
      return Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              character.error.isEmpty ? 'selhalo' : character.error,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ),
        ],
      );
    }
    if (character.isDone) {
      return const Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: Colors.greenAccent),
          SizedBox(width: 4),
          Text(
            'hotovo',
            style: TextStyle(fontSize: 11, color: Colors.greenAccent),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: character.progress, minHeight: 3),
        const SizedBox(height: 3),
        Text(character.status, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'Zatim zadna postava.\nZacni fotkou nebo obrazkem humanoidni postavy.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Zkusit znovu')),
        ],
      ),
    ),
  );
}
