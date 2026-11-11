// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get navQueue => 'Kö';

  @override
  String get navCharacters => 'Figurer';

  @override
  String get navSettings => 'Inställningar';

  @override
  String get retry => 'Försök igen';

  @override
  String nasUnavailable(String error) {
    return 'NAS är inte tillgänglig: $error';
  }

  @override
  String get promptLabel => 'Prompt för objektet';

  @override
  String get categoriesLabel => 'Kategorier';

  @override
  String get catHelmet => 'Hjälm';

  @override
  String get catBack => 'Vingar / rygg';

  @override
  String get catSword => 'Svärd';

  @override
  String get catFront => 'Bröstplåt';

  @override
  String get catHat => 'Mössa';

  @override
  String get catHair => 'Hår (riskabelt)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Kollektion';

  @override
  String get radialTitle => 'Dekor hela vägen runt';

  @override
  String get radialSubtitle => 'radiell symmetri – tårtor, kronor';

  @override
  String variantsPerCategory(int count) {
    return 'Varianter per kategori: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generera $count objekt',
      one: 'Generera $count objekt',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Skickade uppdrag: $sent – Spark genererar (~4 min per st., ett i taget)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Skickade: $sent, fel: $errors';
  }

  @override
  String get queueEmpty => 'Inget på NAS ännu – skicka en batch från Composer.';

  @override
  String get stNew => 'Väntar på triage';

  @override
  String get stRemeshing => 'Beräknas om i TRELLIS (~4 min)';

  @override
  String get stApproved => 'I kö för konvertering';

  @override
  String get stConverting => 'Konverteras';

  @override
  String get stConverted => 'Konverterad – väntar på 3D-granskning';

  @override
  String get stPacked => 'Paketerad för Studio';

  @override
  String get stFailed => 'Misslyckades';

  @override
  String get stRejected => 'Avvisad';

  @override
  String get stRerolled => 'Genererad på nytt';

  @override
  String get tapFor3d => 'tryck för 3D';

  @override
  String get pack => 'Paketera';

  @override
  String sparkSection(int count) {
    return 'Tillverkas på Spark ($count)';
  }

  @override
  String get sgQueued => 'väntar i kön';

  @override
  String get sgConcept => 'ritar konceptet';

  @override
  String get sgCleanplate => 'tar bort bakgrunden';

  @override
  String get sgMesh => 'modellerar i 3D (~4 min)';

  @override
  String get sgPush => 'skickar till NAS';

  @override
  String get sgDone => 'klar';

  @override
  String get sgFailed => 'misslyckades';

  @override
  String get reviewTris => 'trianglar';

  @override
  String get reviewTexture => 'textur';

  @override
  String get reviewSymmetry => 'symmetri';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nej';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (sömhörn: $count)';
  }

  @override
  String get reconvertAgain => 'Konvertera igen';

  @override
  String get reconvertSymmetry => 'Igen med symmetri';

  @override
  String get radialMenu => 'Dekor hela vägen runt (radiell)';

  @override
  String get noSymmetry => 'Utan symmetri';

  @override
  String get backToConcept => 'Tillbaka till konceptet';

  @override
  String get show3d => 'Visa 3D-modellen';

  @override
  String get rejectedToast => 'Avvisad';

  @override
  String get rerollToast => 'Reroll skickad till Spark';

  @override
  String get approvedToast => 'Godkänd → konvertering';

  @override
  String errorPrefix(String error) {
    return 'Fel: $error';
  }

  @override
  String get allSorted => 'Allt är sorterat. Skicka en ny batch från Composer?';

  @override
  String get newShort => 'Ny';

  @override
  String get charactersEmpty =>
      'Inga figurer ännu.\nBörja med ett foto eller en bild av en humanoid figur.';

  @override
  String get newCharacter => 'Ny figur';

  @override
  String get creating => 'Skapar…';

  @override
  String get generate => 'Generera';

  @override
  String get nameLabel => 'Namn';

  @override
  String get prepPhoto => 'Förbered fotot';

  @override
  String get prepPhotoHelp =>
      'Tar bort bakgrunden; sitter armarna fast på kroppen drar den ut dem i en A-pose, och saknas benen under anklarna fyller den i dem. Utan detta misslyckas riggen ofta på hopväxta lemmar.';

  @override
  String get animationsLabel => 'Animationer';

  @override
  String libraryLoadFailed(String error) {
    return 'Biblioteket kunde inte laddas: $error';
  }

  @override
  String get libraryEmpty =>
      'Biblioteket är tomt. Klipp registreras med skriptet seed_animlib.py på NAS.';

  @override
  String get gallery => 'Galleri';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Figur';

  @override
  String get downloadGlb => 'Ladda ner GLB';

  @override
  String get downloadFbx => 'Ladda ner FBX';

  @override
  String get downloadZip => 'Ladda ner allt (ZIP)';

  @override
  String get sendRoblox => 'Skicka till Roblox';

  @override
  String get sendLuanti => 'Skicka till Luanti';

  @override
  String exportQueued(String target) {
    return 'Export till $target lades i kö';
  }

  @override
  String get clipsTitle => 'Klipp';

  @override
  String get exportsTitle => 'Exporter';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (försök $attempt)';
  }

  @override
  String get retryStep => 'Försök steget igen';

  @override
  String stepOf(int step, int total) {
    return 'steg $step av $total';
  }

  @override
  String get cfAccessHelp =>
      'Behövs bara för ugc.ol1n.com (åtkomst utan Tailscale).';

  @override
  String get saveAndTest => 'Spara och testa';

  @override
  String connOk(int count) {
    return 'Anslutningen fungerar (laddade uppdrag: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Inte tillgänglig: $error';
  }
}
