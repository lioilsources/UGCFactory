import 'package:flutter_test/flutter_test.dart';
import 'package:ugc_studio/core/fc_models.dart';

void main() {
  test('FcDetail parses the /v1/fc/characters/{id} payload', () {
    final d = FcDetail.fromJson({
      'character': {
        'id': 'abc123',
        'name': 'Sir Testalot',
        'status': 'animated',
        'tri_count': 7812,
        'auto_apose': true,
        'created_at': '2026-08-31T10:00:00Z',
      },
      'animations': [
        {
          'animation_id': 'idle_01',
          'name': 'Idle',
          'category': 'idle',
          'loop': true,
          'frame_start': 1,
          'frame_end': 60,
        },
        {'animation_id': 'walk_forward', 'frame_start': 0, 'frame_end': 0},
      ],
      'steps': [
        {'id': 1, 'step': 'char.mesh', 'status': 'done', 'attempt': 1},
        {
          'id': 2,
          'step': 'char.rig',
          'status': 'failed',
          'error': 'no mixamorig bones',
          'attempt': 1,
        },
      ],
      'exports': [
        {
          'id': 'e1',
          'target': 'roblox',
          'status': 'done',
          'external_id': 'rbxassetid://123',
        },
      ],
      'artifacts': {'final_glb': '/v1/fc/characters/abc123/file/final_glb'},
    });

    expect(d.character.name, 'Sir Testalot');
    expect(d.character.triCount, 7812);
    expect(d.hasModel, isTrue);
    expect(d.clips, hasLength(2));
    expect(d.clips.first.label, 'Idle');
    expect(d.clips.first.hasFrames, isTrue);
    // klip bez rozsahu jeste neni v modelu - detail ho nesmi nabidnout k hrani
    expect(d.clips.last.hasFrames, isFalse);
    expect(d.clips.last.label, 'walk_forward');
    expect(d.failedStep?.step, 'char.rig');
    expect(d.exports.single.externalId, 'rbxassetid://123');
  });

  test('character progress follows the pipeline order', () {
    FcCharacter at(String status) => FcCharacter.fromJson({
      'id': 'x',
      'name': 'x',
      'status': status,
      'created_at': '',
    });

    expect(at('uploaded').progress, 0);
    expect(at('done').progress, 1);
    expect(at('rigged').progress, greaterThan(at('meshed').progress));
    // failed neni pozice v pipeline, stepper na nej ukazuje chybu
    expect(at('failed').step, -1);
    expect(at('failed').progress, 0);
    expect(at('failed').isFailed, isTrue);
  });

  test('missing optional fields do not throw', () {
    final c = FcCharacter.fromJson({'id': 'x', 'created_at': 'nonsense'});
    expect(c.name, '');
    expect(c.autoAPose, isTrue);
    expect(c.createdAt.millisecondsSinceEpoch, 0);
  });
}
