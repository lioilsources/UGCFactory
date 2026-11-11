// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get navQueue => 'Sor';

  @override
  String get navCharacters => 'Karakterek';

  @override
  String get navSettings => 'Beállítások';

  @override
  String get retry => 'Próbáld újra';

  @override
  String nasUnavailable(String error) {
    return 'A NAS nem érhető el: $error';
  }

  @override
  String get promptLabel => 'Az elem promptja';

  @override
  String get categoriesLabel => 'Kategóriák';

  @override
  String get catHelmet => 'Sisak';

  @override
  String get catBack => 'Szárnyak / hát';

  @override
  String get catSword => 'Kard';

  @override
  String get catFront => 'Mellvért';

  @override
  String get catHat => 'Sapka';

  @override
  String get catHair => 'Haj (kockázatos)';

  @override
  String get styleLabel => 'Stílus';

  @override
  String get collectionLabel => 'Kollekció';

  @override
  String get radialTitle => 'Körkörös díszítés';

  @override
  String get radialSubtitle => 'sugaras szimmetria – torták, koronák';

  @override
  String variantsPerCategory(int count) {
    return 'Variánsok kategóriánként: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elem generálása',
      one: '$count elem generálása',
    );
    return '$_temp0 (~$minutes perc)';
  }

  @override
  String composerSent(int sent) {
    return 'Elküldött feladatok: $sent – a Spark generál (~4 perc darabonként, egymás után)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Elküldve: $sent, hibák: $errors';
  }

  @override
  String get queueEmpty =>
      'A NAS-on még nincs semmi – küldj egy köteget a Composerből.';

  @override
  String get stNew => 'Triázsra vár';

  @override
  String get stRemeshing => 'Újraszámolás a TRELLIS-ben (~4 perc)';

  @override
  String get stApproved => 'Konvertálásra vár a sorban';

  @override
  String get stConverting => 'Konvertálás folyamatban';

  @override
  String get stConverted => 'Konvertálva – 3D-ellenőrzésre vár';

  @override
  String get stPacked => 'Becsomagolva a Studióhoz';

  @override
  String get stFailed => 'Sikertelen';

  @override
  String get stRejected => 'Elutasítva';

  @override
  String get stRerolled => 'Újragenerálva';

  @override
  String get tapFor3d => 'koppints a 3D-hez';

  @override
  String get pack => 'Csomagolás';

  @override
  String sparkSection(int count) {
    return 'Készül a Sparkon ($count)';
  }

  @override
  String get sgQueued => 'sorban vár';

  @override
  String get sgConcept => 'rajzolja a koncepciót';

  @override
  String get sgCleanplate => 'eltávolítja a hátteret';

  @override
  String get sgMesh => '3D-ben modellez (~4 perc)';

  @override
  String get sgPush => 'küldi a NAS-ra';

  @override
  String get sgDone => 'kész';

  @override
  String get sgFailed => 'sikertelen';

  @override
  String get reviewTris => 'háromszögek';

  @override
  String get reviewTexture => 'textúra';

  @override
  String get reviewSymmetry => 'szimmetria';

  @override
  String get yes => 'igen';

  @override
  String get no => 'nem';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (varratpontok: $count)';
  }

  @override
  String get reconvertAgain => 'Konvertálás újra';

  @override
  String get reconvertSymmetry => 'Újra szimmetriával';

  @override
  String get radialMenu => 'Körkörös díszítés (sugaras)';

  @override
  String get noSymmetry => 'Szimmetria nélkül';

  @override
  String get backToConcept => 'Vissza a koncepcióhoz';

  @override
  String get show3d => '3D modell megjelenítése';

  @override
  String get rejectedToast => 'Elutasítva';

  @override
  String get rerollToast => 'A reroll elment a Sparkra';

  @override
  String get approvedToast => 'Jóváhagyva → konvertálás';

  @override
  String errorPrefix(String error) {
    return 'Hiba: $error';
  }

  @override
  String get allSorted =>
      'Minden szortírozva. Küldjünk új köteget a Composerből?';

  @override
  String get newShort => 'Új';

  @override
  String get charactersEmpty =>
      'Még nincs karakter.\nKezdd egy humanoid karakter fotójával vagy képével.';

  @override
  String get newCharacter => 'Új karakter';

  @override
  String get creating => 'Létrehozás…';

  @override
  String get generate => 'Generálás';

  @override
  String get nameLabel => 'Név';

  @override
  String get prepPhoto => 'Fotó előkészítése';

  @override
  String get prepPhotoHelp =>
      'Eltávolítja a hátteret; ha a karok a testhez tapadnak, A-pózba húzza őket, és ha hiányzik a láb a boka alatt, kiegészíti. Enélkül a rig összenőtt végtagoknál gyakran elbukik.';

  @override
  String get animationsLabel => 'Animációk';

  @override
  String libraryLoadFailed(String error) {
    return 'A könyvtár nem tölthető be: $error';
  }

  @override
  String get libraryEmpty =>
      'A könyvtár üres. A klipeket a NAS-on a seed_animlib.py szkript regisztrálja.';

  @override
  String get gallery => 'Galéria';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Karakter';

  @override
  String get downloadGlb => 'GLB letöltése';

  @override
  String get downloadFbx => 'FBX letöltése';

  @override
  String get downloadZip => 'Minden letöltése (ZIP)';

  @override
  String get sendRoblox => 'Küldés Robloxba';

  @override
  String get sendLuanti => 'Küldés Luantiba';

  @override
  String exportQueued(String target) {
    return 'Az exportálás ide: $target sorba állítva';
  }

  @override
  String get clipsTitle => 'Klipek';

  @override
  String get exportsTitle => 'Exportok';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step ($attempt. próbálkozás)';
  }

  @override
  String get retryStep => 'Lépés újrapróbálása';

  @override
  String stepOf(int step, int total) {
    return '$step. lépés / $total';
  }

  @override
  String get cfAccessHelp =>
      'Csak az ugc.ol1n.com-hoz kell (hozzáférés Tailscale nélkül).';

  @override
  String get saveAndTest => 'Mentés és teszt';

  @override
  String connOk(int count) {
    return 'A kapcsolat rendben (betöltött feladatok: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Nem érhető el: $error';
  }
}
