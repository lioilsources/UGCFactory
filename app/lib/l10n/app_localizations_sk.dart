// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get navQueue => 'Fronta';

  @override
  String get navCharacters => 'Postavy';

  @override
  String get navSettings => 'Nastavenia';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String nasUnavailable(String error) {
    return 'NAS nedostupný: $error';
  }

  @override
  String get promptLabel => 'Prompt itemu';

  @override
  String get categoriesLabel => 'Kategórie';

  @override
  String get catHelmet => 'Prilba';

  @override
  String get catBack => 'Krídla / chrbát';

  @override
  String get catSword => 'Meč';

  @override
  String get catFront => 'Hrudný plát';

  @override
  String get catHat => 'Čiapka';

  @override
  String get catHair => 'Vlasy (riziko)';

  @override
  String get styleLabel => 'Štýl';

  @override
  String get collectionLabel => 'Kolekcia';

  @override
  String get radialTitle => 'Zdobenie dokola';

  @override
  String get radialSubtitle => 'radiálna symetria – torty, korunky';

  @override
  String variantsPerCategory(int count) {
    return 'Varianty na kategóriu: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vygenerovať $count itemov',
      many: 'Vygenerovať $count itemu',
      few: 'Vygenerovať $count itemy',
      one: 'Vygenerovať $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Odoslané úlohy: $sent – Spark generuje (~4 min/kus, sériovo)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Odoslané: $sent, chyby: $errors';
  }

  @override
  String get queueEmpty =>
      'Na NAS-e zatiaľ nič nie je – pošli batch z Composera.';

  @override
  String get stNew => 'Čaká na triage';

  @override
  String get stRemeshing => 'Prepočítava sa v TRELLIS (~4 min)';

  @override
  String get stApproved => 'Vo fronte na konverziu';

  @override
  String get stConverting => 'Konvertuje sa';

  @override
  String get stConverted => 'Zkonvertované – čaká na 3D review';

  @override
  String get stPacked => 'Zabalené pre Studio';

  @override
  String get stFailed => 'Zlyhalo';

  @override
  String get stRejected => 'Zamietnuté';

  @override
  String get stRerolled => 'Rerollnuté';

  @override
  String get tapFor3d => 'klepni pre 3D';

  @override
  String get pack => 'Zabaliť';

  @override
  String sparkSection(int count) {
    return 'Vyrába sa na Sparku ($count)';
  }

  @override
  String get sgQueued => 'čaká vo fronte';

  @override
  String get sgConcept => 'kreslí koncept';

  @override
  String get sgCleanplate => 'odmazáva pozadie';

  @override
  String get sgMesh => 'modeluje 3D (~4 min)';

  @override
  String get sgPush => 'posiela na NAS';

  @override
  String get sgDone => 'hotovo';

  @override
  String get sgFailed => 'zlyhalo';

  @override
  String get reviewTris => 'trojuholníky';

  @override
  String get reviewTexture => 'textúra';

  @override
  String get reviewSymmetry => 'symetria';

  @override
  String get yes => 'áno';

  @override
  String get no => 'nie';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (švové vrcholy: $count)';
  }

  @override
  String get reconvertAgain => 'Konvertovať znova';

  @override
  String get reconvertSymmetry => 'Znova so symetriou';

  @override
  String get radialMenu => 'Zdobenie dokola (radiálne)';

  @override
  String get noSymmetry => 'Bez symetrie';

  @override
  String get backToConcept => 'Späť na koncept';

  @override
  String get show3d => 'Ukáž 3D model';

  @override
  String get rejectedToast => 'Zamietnuté';

  @override
  String get rerollToast => 'Reroll poslaný na Spark';

  @override
  String get approvedToast => 'Schválené → konverzia';

  @override
  String errorPrefix(String error) {
    return 'Chyba: $error';
  }

  @override
  String get allSorted => 'Všetko roztriedené. Poslať nový batch z Composera?';

  @override
  String get newShort => 'Nová';

  @override
  String get charactersEmpty =>
      'Zatiaľ žiadna postava.\nZačni fotkou alebo obrázkom humanoidnej postavy.';

  @override
  String get newCharacter => 'Nová postava';

  @override
  String get creating => 'Zakladám…';

  @override
  String get generate => 'Vygenerovať';

  @override
  String get nameLabel => 'Meno';

  @override
  String get prepPhoto => 'Pripraviť fotku';

  @override
  String get prepPhotoHelp =>
      'Odstráni pozadie; keď sú ruky prilepené k telu, odtiahne ich do A-pózy, a keď chýbajú nohy pod členkami, domyslí ich. Bez toho rig pri zrastených končatinách často zlyhá.';

  @override
  String get animationsLabel => 'Animácie';

  @override
  String libraryLoadFailed(String error) {
    return 'Knižnicu sa nepodarilo načítať: $error';
  }

  @override
  String get libraryEmpty =>
      'Knižnica je prázdna. Klipy sa registrujú skriptom seed_animlib.py na NAS-e.';

  @override
  String get gallery => 'Galéria';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get characterFallback => 'Postava';

  @override
  String get downloadGlb => 'Stiahnuť GLB';

  @override
  String get downloadFbx => 'Stiahnuť FBX';

  @override
  String get downloadZip => 'Stiahnuť všetko (ZIP)';

  @override
  String get sendRoblox => 'Poslať do Robloxu';

  @override
  String get sendLuanti => 'Poslať do Luanti';

  @override
  String exportQueued(String target) {
    return 'Export do $target zaradený';
  }

  @override
  String get clipsTitle => 'Klipy';

  @override
  String get exportsTitle => 'Exporty';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (pokus $attempt)';
  }

  @override
  String get retryStep => 'Skúsiť krok znova';

  @override
  String stepOf(int step, int total) {
    return 'krok $step z $total';
  }

  @override
  String get cfAccessHelp =>
      'Potrebné len pre ugc.ol1n.com (prístup bez Tailscale).';

  @override
  String get saveAndTest => 'Uložiť a otestovať';

  @override
  String connOk(int count) {
    return 'Spojenie OK (načítané úlohy: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Nedostupné: $error';
  }
}
