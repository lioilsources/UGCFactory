// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get navQueue => 'Kø';

  @override
  String get navCharacters => 'Figurer';

  @override
  String get navSettings => 'Indstillinger';

  @override
  String get retry => 'Prøv igen';

  @override
  String nasUnavailable(String error) {
    return 'NAS ikke tilgængelig: $error';
  }

  @override
  String get promptLabel => 'Prompt til emnet';

  @override
  String get categoriesLabel => 'Kategorier';

  @override
  String get catHelmet => 'Hjelm';

  @override
  String get catBack => 'Vinger / ryg';

  @override
  String get catSword => 'Sværd';

  @override
  String get catFront => 'Brystplade';

  @override
  String get catHat => 'Hue';

  @override
  String get catHair => 'Hår (risikabelt)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Kollektion';

  @override
  String get radialTitle => 'Pynt hele vejen rundt';

  @override
  String get radialSubtitle => 'radial symmetri – kager, kroner';

  @override
  String variantsPerCategory(int count) {
    return 'Varianter pr. kategori: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generér $count emner',
      one: 'Generér $count emne',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Sendte opgaver: $sent – Spark genererer (~4 min pr. stk., én ad gangen)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Sendt: $sent, fejl: $errors';
  }

  @override
  String get queueEmpty => 'Intet på NAS endnu – send et batch fra Composer.';

  @override
  String get stNew => 'Venter på triage';

  @override
  String get stRemeshing => 'Genberegnes i TRELLIS (~4 min)';

  @override
  String get stApproved => 'I kø til konvertering';

  @override
  String get stConverting => 'Konverterer';

  @override
  String get stConverted => 'Konverteret – venter på 3D-gennemgang';

  @override
  String get stPacked => 'Pakket til Studio';

  @override
  String get stFailed => 'Mislykkedes';

  @override
  String get stRejected => 'Afvist';

  @override
  String get stRerolled => 'Genrullet';

  @override
  String get tapFor3d => 'tryk for 3D';

  @override
  String get pack => 'Pak';

  @override
  String sparkSection(int count) {
    return 'Laves på Spark ($count)';
  }

  @override
  String get sgQueued => 'venter i køen';

  @override
  String get sgConcept => 'tegner konceptet';

  @override
  String get sgCleanplate => 'fjerner baggrunden';

  @override
  String get sgMesh => 'modellerer i 3D (~4 min)';

  @override
  String get sgPush => 'sender til NAS';

  @override
  String get sgDone => 'færdig';

  @override
  String get sgFailed => 'mislykkedes';

  @override
  String get reviewTris => 'trekanter';

  @override
  String get reviewTexture => 'tekstur';

  @override
  String get reviewSymmetry => 'symmetri';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nej';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (sømhjørner: $count)';
  }

  @override
  String get reconvertAgain => 'Konvertér igen';

  @override
  String get reconvertSymmetry => 'Igen med symmetri';

  @override
  String get radialMenu => 'Pynt hele vejen rundt (radial)';

  @override
  String get noSymmetry => 'Uden symmetri';

  @override
  String get backToConcept => 'Tilbage til konceptet';

  @override
  String get show3d => 'Vis 3D-modellen';

  @override
  String get rejectedToast => 'Afvist';

  @override
  String get rerollToast => 'Reroll sendt til Spark';

  @override
  String get approvedToast => 'Godkendt → konvertering';

  @override
  String errorPrefix(String error) {
    return 'Fejl: $error';
  }

  @override
  String get allSorted => 'Alt sorteret. Send et nyt batch fra Composer?';

  @override
  String get newShort => 'Ny';

  @override
  String get charactersEmpty =>
      'Ingen figurer endnu.\nStart med et foto eller et billede af en humanoid figur.';

  @override
  String get newCharacter => 'Ny figur';

  @override
  String get creating => 'Opretter…';

  @override
  String get generate => 'Generér';

  @override
  String get nameLabel => 'Navn';

  @override
  String get prepPhoto => 'Klargør fotoet';

  @override
  String get prepPhotoHelp =>
      'Fjerner baggrunden; hvis armene sidder fast på kroppen, trækker den dem ud i en A-positur, og hvis benene mangler under anklerne, digter den dem til. Uden det fejler riggen ofte på sammenvoksede lemmer.';

  @override
  String get animationsLabel => 'Animationer';

  @override
  String libraryLoadFailed(String error) {
    return 'Biblioteket kunne ikke indlæses: $error';
  }

  @override
  String get libraryEmpty =>
      'Biblioteket er tomt. Klip registreres med scriptet seed_animlib.py på NAS.';

  @override
  String get gallery => 'Galleri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Figur';

  @override
  String get downloadGlb => 'Download GLB';

  @override
  String get downloadFbx => 'Download FBX';

  @override
  String get downloadZip => 'Download alt (ZIP)';

  @override
  String get sendRoblox => 'Send til Roblox';

  @override
  String get sendLuanti => 'Send til Luanti';

  @override
  String exportQueued(String target) {
    return 'Eksport til $target sat i kø';
  }

  @override
  String get clipsTitle => 'Klip';

  @override
  String get exportsTitle => 'Eksporter';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (forsøg $attempt)';
  }

  @override
  String get retryStep => 'Prøv trinnet igen';

  @override
  String stepOf(int step, int total) {
    return 'trin $step af $total';
  }

  @override
  String get cfAccessHelp =>
      'Kun nødvendigt til ugc.ol1n.com (adgang uden Tailscale).';

  @override
  String get saveAndTest => 'Gem og test';

  @override
  String connOk(int count) {
    return 'Forbindelse OK (indlæste opgaver: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Utilgængelig: $error';
  }
}
