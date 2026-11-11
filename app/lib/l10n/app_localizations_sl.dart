// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get navQueue => 'Vrsta';

  @override
  String get navCharacters => 'Liki';

  @override
  String get navSettings => 'Nastavitve';

  @override
  String get retry => 'Poskusi znova';

  @override
  String nasUnavailable(String error) {
    return 'NAS ni dosegljiv: $error';
  }

  @override
  String get promptLabel => 'Poziv za predmet';

  @override
  String get categoriesLabel => 'Kategorije';

  @override
  String get catHelmet => 'Čelada';

  @override
  String get catBack => 'Krila / hrbet';

  @override
  String get catSword => 'Meč';

  @override
  String get catFront => 'Prsni oklep';

  @override
  String get catHat => 'Kapa';

  @override
  String get catHair => 'Lasje (tvegano)';

  @override
  String get styleLabel => 'Slog';

  @override
  String get collectionLabel => 'Zbirka';

  @override
  String get radialTitle => 'Okras naokoli';

  @override
  String get radialSubtitle => 'radialna simetrija – torte, krone';

  @override
  String variantsPerCategory(int count) {
    return 'Različic na kategorijo: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ustvari $count predmetov',
      few: 'Ustvari $count predmete',
      two: 'Ustvari $count predmeta',
      one: 'Ustvari $count predmet',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Poslane naloge: $sent – Spark ustvarja (~4 min na kos, eno za drugo)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Poslano: $sent, napake: $errors';
  }

  @override
  String get queueEmpty =>
      'Na NAS-u še ni ničesar – pošlji paket iz Composerja.';

  @override
  String get stNew => 'Čaka na triažo';

  @override
  String get stRemeshing => 'Ponovno se računa v TRELLIS (~4 min)';

  @override
  String get stApproved => 'V vrsti za pretvorbo';

  @override
  String get stConverting => 'Pretvarja se';

  @override
  String get stConverted => 'Pretvorjeno – čaka na 3D pregled';

  @override
  String get stPacked => 'Zapakirano za Studio';

  @override
  String get stFailed => 'Ni uspelo';

  @override
  String get stRejected => 'Zavrnjeno';

  @override
  String get stRerolled => 'Ponovno ustvarjeno';

  @override
  String get tapFor3d => 'tapni za 3D';

  @override
  String get pack => 'Zapakiraj';

  @override
  String sparkSection(int count) {
    return 'Nastaja na Sparku ($count)';
  }

  @override
  String get sgQueued => 'čaka v vrsti';

  @override
  String get sgConcept => 'riše koncept';

  @override
  String get sgCleanplate => 'odstranjuje ozadje';

  @override
  String get sgMesh => 'modelira v 3D (~4 min)';

  @override
  String get sgPush => 'pošilja na NAS';

  @override
  String get sgDone => 'končano';

  @override
  String get sgFailed => 'ni uspelo';

  @override
  String get reviewTris => 'trikotniki';

  @override
  String get reviewTexture => 'tekstura';

  @override
  String get reviewSymmetry => 'simetrija';

  @override
  String get yes => 'da';

  @override
  String get no => 'ne';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (oglišča šiva: $count)';
  }

  @override
  String get reconvertAgain => 'Pretvori znova';

  @override
  String get reconvertSymmetry => 'Znova s simetrijo';

  @override
  String get radialMenu => 'Okras naokoli (radialno)';

  @override
  String get noSymmetry => 'Brez simetrije';

  @override
  String get backToConcept => 'Nazaj na koncept';

  @override
  String get show3d => 'Pokaži 3D model';

  @override
  String get rejectedToast => 'Zavrnjeno';

  @override
  String get rerollToast => 'Reroll poslan na Spark';

  @override
  String get approvedToast => 'Odobreno → pretvorba';

  @override
  String errorPrefix(String error) {
    return 'Napaka: $error';
  }

  @override
  String get allSorted => 'Vse razvrščeno. Pošljem nov paket iz Composerja?';

  @override
  String get newShort => 'Nov';

  @override
  String get charactersEmpty =>
      'Še ni nobenega lika.\nZačni s fotografijo ali sliko humanoidnega lika.';

  @override
  String get newCharacter => 'Nov lik';

  @override
  String get creating => 'Ustvarjam…';

  @override
  String get generate => 'Ustvari';

  @override
  String get nameLabel => 'Ime';

  @override
  String get prepPhoto => 'Pripravi fotografijo';

  @override
  String get prepPhotoHelp =>
      'Odstrani ozadje; če so roke prilepljene na telo, jih odmakne v A-pozo, če pa pod gležnji manjkajo noge, jih dopolni. Brez tega rig pri zraščenih udih pogosto odpove.';

  @override
  String get animationsLabel => 'Animacije';

  @override
  String libraryLoadFailed(String error) {
    return 'Knjižnice ni bilo mogoče naložiti: $error';
  }

  @override
  String get libraryEmpty =>
      'Knjižnica je prazna. Klipi se registrirajo s skriptom seed_animlib.py na NAS-u.';

  @override
  String get gallery => 'Galerija';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Lik';

  @override
  String get downloadGlb => 'Prenesi GLB';

  @override
  String get downloadFbx => 'Prenesi FBX';

  @override
  String get downloadZip => 'Prenesi vse (ZIP)';

  @override
  String get sendRoblox => 'Pošlji v Roblox';

  @override
  String get sendLuanti => 'Pošlji v Luanti';

  @override
  String exportQueued(String target) {
    return 'Izvoz v $target dodan v vrsto';
  }

  @override
  String get clipsTitle => 'Klipi';

  @override
  String get exportsTitle => 'Izvozi';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (poskus $attempt)';
  }

  @override
  String get retryStep => 'Poskusi korak znova';

  @override
  String stepOf(int step, int total) {
    return 'korak $step od $total';
  }

  @override
  String get cfAccessHelp =>
      'Potrebno samo za ugc.ol1n.com (dostop brez Tailscalea).';

  @override
  String get saveAndTest => 'Shrani in preizkusi';

  @override
  String connOk(int count) {
    return 'Povezava je v redu (naložene naloge: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Ni dosegljivo: $error';
  }
}
