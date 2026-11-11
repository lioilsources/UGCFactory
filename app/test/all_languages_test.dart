import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ugc_studio/core/providers.dart';
import 'package:ugc_studio/l10n/app_localizations.dart';
import 'package:ugc_studio/modules/composer/composer_screen.dart';
import 'package:ugc_studio/modules/settings/settings_screen.dart';

/// The 45 interface languages: every one must load, differ from the Czech
/// template, and lay out the screens without overflow, also right to left
/// (ar, he, ur).
const _expected = [
  'ar',
  'bn',
  'ca',
  'cs',
  'da',
  'de',
  'el',
  'en',
  'es',
  'fi',
  'fr',
  'gu',
  'he',
  'hi',
  'hr',
  'hu',
  'id',
  'it',
  'ja',
  'kn',
  'ko',
  'ml',
  'mr',
  'ms',
  'nb',
  'nl',
  'or',
  'pa',
  'pl',
  'pt',
  'ro',
  'ru',
  'sk',
  'sl',
  'sv',
  'ta',
  'te',
  'th',
  'tr',
  'uk',
  'ur',
  'vi',
  'zh',
];

Widget _app(SharedPreferences prefs, Locale l, Widget child) => ProviderScope(
  overrides: [prefsProvider.overrideWithValue(prefs)],
  child: MaterialApp(
    locale: l,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  test('all 45 languages are supported (pt-BR/pt-PT, zh-Hans/zh-Hant)', () {
    final codes = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    expect(codes, containsAll(_expected));
    final tags = AppLocalizations.supportedLocales.map((l) => l.toString());
    expect(tags, containsAll(['pt_PT', 'pt_BR', 'zh_Hant', 'zh_Hans']));
  });

  test('no translation is empty or still the Czech template', () async {
    final cs = await AppLocalizations.delegate.load(const Locale('cs'));
    for (final l in AppLocalizations.supportedLocales) {
      if (l.languageCode == 'cs') continue;
      final t = await AppLocalizations.delegate.load(l);
      expect(t.prepPhotoHelp, isNot(cs.prepPhotoHelp), reason: '$l');
      expect(t.allSorted, isNot(cs.allSorted), reason: '$l');
      expect(t.stepOf(2, 6), allOf(contains('2'), contains('6')), reason: '$l');
      expect(t.exportQueued('roblox'), contains('roblox'), reason: '$l');
      // one/two forms of ar and he spell the number out as a word
      for (final n in [0, 3, 5, 11, 21, 100]) {
        expect(t.generateItems(n, n * 4), contains('$n'), reason: '$l $n');
      }
    }
  });

  for (final l in AppLocalizations.supportedLocales) {
    testWidgets('composer and settings lay out in $l', (t) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      t.view.physicalSize = const Size(800, 1600);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final rtl = ['ar', 'he', 'ur'].contains(l.languageCode);

      await t.pumpWidget(_app(prefs, l, const ComposerScreen()));
      await t.pump();
      expect(
        Directionality.of(t.element(find.byType(Scaffold).first)),
        rtl ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(t.takeException(), isNull, reason: '$l composer');

      await t.pumpWidget(_app(prefs, l, const SettingsScreen()));
      await t.pump();
      expect(t.takeException(), isNull, reason: '$l settings');
    });
  }
}
