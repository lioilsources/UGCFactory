// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get navQueue => 'Kø';

  @override
  String get navCharacters => 'Figurer';

  @override
  String get navSettings => 'Innstillinger';

  @override
  String get retry => 'Prøv igjen';

  @override
  String nasUnavailable(String error) {
    return 'NAS er utilgjengelig: $error';
  }

  @override
  String get promptLabel => 'Prompt for elementet';

  @override
  String get categoriesLabel => 'Kategorier';

  @override
  String get catHelmet => 'Hjelm';

  @override
  String get catBack => 'Vinger / rygg';

  @override
  String get catSword => 'Sverd';

  @override
  String get catFront => 'Brystplate';

  @override
  String get catHat => 'Lue';

  @override
  String get catHair => 'Hår (risikabelt)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Kolleksjon';

  @override
  String get radialTitle => 'Pynt hele veien rundt';

  @override
  String get radialSubtitle => 'radiell symmetri – kaker, kroner';

  @override
  String variantsPerCategory(int count) {
    return 'Varianter per kategori: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generer $count elementer',
      one: 'Generer $count element',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Sendte oppgaver: $sent – Spark genererer (~4 min per stk., én om gangen)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Sendt: $sent, feil: $errors';
  }

  @override
  String get queueEmpty =>
      'Ingenting på NAS ennå – send en batch fra Composer.';

  @override
  String get stNew => 'Venter på triage';

  @override
  String get stRemeshing => 'Beregnes på nytt i TRELLIS (~4 min)';

  @override
  String get stApproved => 'I kø for konvertering';

  @override
  String get stConverting => 'Konverterer';

  @override
  String get stConverted => 'Konvertert – venter på 3D-gjennomgang';

  @override
  String get stPacked => 'Pakket for Studio';

  @override
  String get stFailed => 'Mislyktes';

  @override
  String get stRejected => 'Avvist';

  @override
  String get stRerolled => 'Generert på nytt';

  @override
  String get tapFor3d => 'trykk for 3D';

  @override
  String get pack => 'Pakk';

  @override
  String sparkSection(int count) {
    return 'Lages på Spark ($count)';
  }

  @override
  String get sgQueued => 'venter i køen';

  @override
  String get sgConcept => 'tegner konseptet';

  @override
  String get sgCleanplate => 'fjerner bakgrunnen';

  @override
  String get sgMesh => 'modellerer i 3D (~4 min)';

  @override
  String get sgPush => 'sender til NAS';

  @override
  String get sgDone => 'ferdig';

  @override
  String get sgFailed => 'mislyktes';

  @override
  String get reviewTris => 'trekanter';

  @override
  String get reviewTexture => 'tekstur';

  @override
  String get reviewSymmetry => 'symmetri';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nei';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (sømpunkter: $count)';
  }

  @override
  String get reconvertAgain => 'Konverter på nytt';

  @override
  String get reconvertSymmetry => 'På nytt med symmetri';

  @override
  String get radialMenu => 'Pynt hele veien rundt (radiell)';

  @override
  String get noSymmetry => 'Uten symmetri';

  @override
  String get backToConcept => 'Tilbake til konseptet';

  @override
  String get show3d => 'Vis 3D-modellen';

  @override
  String get rejectedToast => 'Avvist';

  @override
  String get rerollToast => 'Reroll sendt til Spark';

  @override
  String get approvedToast => 'Godkjent → konvertering';

  @override
  String errorPrefix(String error) {
    return 'Feil: $error';
  }

  @override
  String get allSorted => 'Alt er sortert. Sende en ny batch fra Composer?';

  @override
  String get newShort => 'Ny';

  @override
  String get charactersEmpty =>
      'Ingen figurer ennå.\nStart med et bilde eller foto av en humanoid figur.';

  @override
  String get newCharacter => 'Ny figur';

  @override
  String get creating => 'Oppretter…';

  @override
  String get generate => 'Generer';

  @override
  String get nameLabel => 'Navn';

  @override
  String get prepPhoto => 'Klargjør bildet';

  @override
  String get prepPhotoHelp =>
      'Fjerner bakgrunnen; hvis armene sitter fast på kroppen, trekker den dem ut i en A-positur, og hvis bena mangler under anklene, fyller den dem inn. Uten dette feiler riggen ofte på sammenvokste lemmer.';

  @override
  String get animationsLabel => 'Animasjoner';

  @override
  String libraryLoadFailed(String error) {
    return 'Biblioteket kunne ikke lastes: $error';
  }

  @override
  String get libraryEmpty =>
      'Biblioteket er tomt. Klipp registreres med skriptet seed_animlib.py på NAS.';

  @override
  String get gallery => 'Galleri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Figur';

  @override
  String get downloadGlb => 'Last ned GLB';

  @override
  String get downloadFbx => 'Last ned FBX';

  @override
  String get downloadZip => 'Last ned alt (ZIP)';

  @override
  String get sendRoblox => 'Send til Roblox';

  @override
  String get sendLuanti => 'Send til Luanti';

  @override
  String exportQueued(String target) {
    return 'Eksport til $target satt i kø';
  }

  @override
  String get clipsTitle => 'Klipp';

  @override
  String get exportsTitle => 'Eksporter';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (forsøk $attempt)';
  }

  @override
  String get retryStep => 'Prøv trinnet igjen';

  @override
  String stepOf(int step, int total) {
    return 'trinn $step av $total';
  }

  @override
  String get cfAccessHelp =>
      'Trengs bare for ugc.ol1n.com (tilgang uten Tailscale).';

  @override
  String get saveAndTest => 'Lagre og test';

  @override
  String connOk(int count) {
    return 'Tilkobling OK (lastede oppgaver: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Utilgjengelig: $error';
  }
}
