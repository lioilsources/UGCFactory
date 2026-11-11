// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get navQueue => 'Wachtrij';

  @override
  String get navCharacters => 'Personages';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String nasUnavailable(String error) {
    return 'NAS niet beschikbaar: $error';
  }

  @override
  String get promptLabel => 'Prompt van het item';

  @override
  String get categoriesLabel => 'Categorieën';

  @override
  String get catHelmet => 'Helm';

  @override
  String get catBack => 'Vleugels / rug';

  @override
  String get catSword => 'Zwaard';

  @override
  String get catFront => 'Borstplaat';

  @override
  String get catHat => 'Muts';

  @override
  String get catHair => 'Haar (risicovol)';

  @override
  String get styleLabel => 'Stijl';

  @override
  String get collectionLabel => 'Collectie';

  @override
  String get radialTitle => 'Versiering rondom';

  @override
  String get radialSubtitle => 'radiale symmetrie – taarten, kronen';

  @override
  String variantsPerCategory(int count) {
    return 'Varianten per categorie: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items genereren',
      one: '$count item genereren',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Verzonden taken: $sent – Spark genereert (~4 min per stuk, een voor een)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Verzonden: $sent, fouten: $errors';
  }

  @override
  String get queueEmpty =>
      'Nog niets op de NAS – stuur een batch vanuit de Composer.';

  @override
  String get stNew => 'Wacht op triage';

  @override
  String get stRemeshing => 'Wordt opnieuw berekend in TRELLIS (~4 min)';

  @override
  String get stApproved => 'In de wachtrij voor conversie';

  @override
  String get stConverting => 'Wordt geconverteerd';

  @override
  String get stConverted => 'Geconverteerd – wacht op 3D-review';

  @override
  String get stPacked => 'Ingepakt voor Studio';

  @override
  String get stFailed => 'Mislukt';

  @override
  String get stRejected => 'Afgewezen';

  @override
  String get stRerolled => 'Opnieuw gegenereerd';

  @override
  String get tapFor3d => 'tik voor 3D';

  @override
  String get pack => 'Inpakken';

  @override
  String sparkSection(int count) {
    return 'Wordt gemaakt op Spark ($count)';
  }

  @override
  String get sgQueued => 'wacht in de rij';

  @override
  String get sgConcept => 'tekent het concept';

  @override
  String get sgCleanplate => 'verwijdert de achtergrond';

  @override
  String get sgMesh => 'modelleert in 3D (~4 min)';

  @override
  String get sgPush => 'stuurt naar de NAS';

  @override
  String get sgDone => 'klaar';

  @override
  String get sgFailed => 'mislukt';

  @override
  String get reviewTris => 'driehoeken';

  @override
  String get reviewTexture => 'textuur';

  @override
  String get reviewSymmetry => 'symmetrie';

  @override
  String get yes => 'ja';

  @override
  String get no => 'nee';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (naadpunten: $count)';
  }

  @override
  String get reconvertAgain => 'Opnieuw converteren';

  @override
  String get reconvertSymmetry => 'Opnieuw met symmetrie';

  @override
  String get radialMenu => 'Versiering rondom (radiaal)';

  @override
  String get noSymmetry => 'Zonder symmetrie';

  @override
  String get backToConcept => 'Terug naar het concept';

  @override
  String get show3d => '3D-model tonen';

  @override
  String get rejectedToast => 'Afgewezen';

  @override
  String get rerollToast => 'Reroll naar Spark gestuurd';

  @override
  String get approvedToast => 'Goedgekeurd → conversie';

  @override
  String errorPrefix(String error) {
    return 'Fout: $error';
  }

  @override
  String get allSorted =>
      'Alles gesorteerd. Een nieuwe batch sturen vanuit de Composer?';

  @override
  String get newShort => 'Nieuw';

  @override
  String get charactersEmpty =>
      'Nog geen personages.\nBegin met een foto of afbeelding van een humanoïde personage.';

  @override
  String get newCharacter => 'Nieuw personage';

  @override
  String get creating => 'Aanmaken…';

  @override
  String get generate => 'Genereren';

  @override
  String get nameLabel => 'Naam';

  @override
  String get prepPhoto => 'Foto voorbereiden';

  @override
  String get prepPhotoHelp =>
      'Verwijdert de achtergrond; zitten de armen vast aan het lichaam, dan trekt het ze in een A-pose, en ontbreken de benen onder de enkels, dan vult het ze aan. Zonder dit faalt de rig vaak bij vergroeide ledematen.';

  @override
  String get animationsLabel => 'Animaties';

  @override
  String libraryLoadFailed(String error) {
    return 'De bibliotheek kon niet worden geladen: $error';
  }

  @override
  String get libraryEmpty =>
      'De bibliotheek is leeg. Clips worden geregistreerd met het script seed_animlib.py op de NAS.';

  @override
  String get gallery => 'Galerij';

  @override
  String get camera => 'Camera';

  @override
  String get characterFallback => 'Personage';

  @override
  String get downloadGlb => 'GLB downloaden';

  @override
  String get downloadFbx => 'FBX downloaden';

  @override
  String get downloadZip => 'Alles downloaden (ZIP)';

  @override
  String get sendRoblox => 'Naar Roblox sturen';

  @override
  String get sendLuanti => 'Naar Luanti sturen';

  @override
  String exportQueued(String target) {
    return 'Export naar $target in de wachtrij gezet';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exports';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (poging $attempt)';
  }

  @override
  String get retryStep => 'Stap opnieuw proberen';

  @override
  String stepOf(int step, int total) {
    return 'stap $step van $total';
  }

  @override
  String get cfAccessHelp =>
      'Alleen nodig voor ugc.ol1n.com (toegang zonder Tailscale).';

  @override
  String get saveAndTest => 'Opslaan en testen';

  @override
  String connOk(int count) {
    return 'Verbinding OK (geladen taken: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Niet beschikbaar: $error';
  }
}
