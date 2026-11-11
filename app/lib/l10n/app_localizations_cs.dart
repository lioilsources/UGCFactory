// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get navQueue => 'Fronta';

  @override
  String get navCharacters => 'Postavy';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String nasUnavailable(String error) {
    return 'NAS nedostupný: $error';
  }

  @override
  String get promptLabel => 'Prompt itemu';

  @override
  String get categoriesLabel => 'Kategorie';

  @override
  String get catHelmet => 'Helma';

  @override
  String get catBack => 'Křídla / záda';

  @override
  String get catSword => 'Meč';

  @override
  String get catFront => 'Hrudní plát';

  @override
  String get catHat => 'Čepice';

  @override
  String get catHair => 'Vlasy (riziko)';

  @override
  String get styleLabel => 'Styl';

  @override
  String get collectionLabel => 'Kolekce';

  @override
  String get radialTitle => 'Zdobení dokola';

  @override
  String get radialSubtitle => 'radiální symetrie – dorty, korunky';

  @override
  String variantsPerCategory(int count) {
    return 'Varianty na kategorii: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vygenerovat $count itemů',
      many: 'Vygenerovat $count itemu',
      few: 'Vygenerovat $count itemy',
      one: 'Vygenerovat $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Odesláno úloh: $sent – Spark generuje (~4 min/kus, sériově)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Odesláno: $sent, chyby: $errors';
  }

  @override
  String get queueEmpty => 'Na NASu zatím nic – pošli batch v Composeru.';

  @override
  String get stNew => 'Čeká na triage';

  @override
  String get stRemeshing => 'Přepočítává se v TRELLIS (~4 min)';

  @override
  String get stApproved => 'Ve frontě na konverzi';

  @override
  String get stConverting => 'Konvertuje se';

  @override
  String get stConverted => 'Zkonvertováno – čeká na 3D review';

  @override
  String get stPacked => 'Zabaleno pro Studio';

  @override
  String get stFailed => 'Selhalo';

  @override
  String get stRejected => 'Zamítnuto';

  @override
  String get stRerolled => 'Rerollnuto';

  @override
  String get tapFor3d => 'klepni pro 3D';

  @override
  String get pack => 'Zabalit';

  @override
  String sparkSection(int count) {
    return 'Vyrábí se na Sparku ($count)';
  }

  @override
  String get sgQueued => 'čeká ve frontě';

  @override
  String get sgConcept => 'kreslí koncept';

  @override
  String get sgCleanplate => 'odmazává pozadí';

  @override
  String get sgMesh => 'modeluje 3D (~4 min)';

  @override
  String get sgPush => 'posílá na NAS';

  @override
  String get sgDone => 'hotovo';

  @override
  String get sgFailed => 'selhalo';

  @override
  String get reviewTris => 'trojúhelníky';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'symetrie';

  @override
  String get yes => 'ano';

  @override
  String get no => 'ne';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (švů: $count)';
  }

  @override
  String get reconvertAgain => 'Konvertovat znovu';

  @override
  String get reconvertSymmetry => 'Znovu se symetrií';

  @override
  String get radialMenu => 'Zdobení dokola (radiální)';

  @override
  String get noSymmetry => 'Bez symetrie';

  @override
  String get backToConcept => 'Zpět na koncept';

  @override
  String get show3d => 'Ukaž 3D model';

  @override
  String get rejectedToast => 'Zamítnuto';

  @override
  String get rerollToast => 'Reroll poslán na Spark';

  @override
  String get approvedToast => 'Schváleno → konverze';

  @override
  String errorPrefix(String error) {
    return 'Chyba: $error';
  }

  @override
  String get allSorted => 'Vše roztříděno. Poslat nový batch v Composeru?';

  @override
  String get newShort => 'Nová';

  @override
  String get charactersEmpty =>
      'Zatím žádná postava.\nZačni fotkou nebo obrázkem humanoidní postavy.';

  @override
  String get newCharacter => 'Nová postava';

  @override
  String get creating => 'Zakládám…';

  @override
  String get generate => 'Vygenerovat';

  @override
  String get nameLabel => 'Jméno';

  @override
  String get prepPhoto => 'Připravit fotku';

  @override
  String get prepPhotoHelp =>
      'Odstraní pozadí; když jsou ruce přilepené k tělu, odtáhne je do A-pózy, a když chybí nohy pod kotníky, domyslí je. Bez toho rig u srostlých končetin často selže.';

  @override
  String get animationsLabel => 'Animace';

  @override
  String libraryLoadFailed(String error) {
    return 'Knihovnu se nepodařilo načíst: $error';
  }

  @override
  String get libraryEmpty =>
      'Knihovna je prázdná. Klipy se registrují skriptem seed_animlib.py na NASu.';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get characterFallback => 'Postava';

  @override
  String get downloadGlb => 'Stáhnout GLB';

  @override
  String get downloadFbx => 'Stáhnout FBX';

  @override
  String get downloadZip => 'Stáhnout vše (ZIP)';

  @override
  String get sendRoblox => 'Poslat do Robloxu';

  @override
  String get sendLuanti => 'Poslat do Luanti';

  @override
  String exportQueued(String target) {
    return 'Export do $target zařazen';
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
  String get retryStep => 'Zkusit krok znovu';

  @override
  String stepOf(int step, int total) {
    return 'krok $step z $total';
  }

  @override
  String get cfAccessHelp =>
      'Potřeba jen pro ugc.ol1n.com (přístup bez Tailscale).';

  @override
  String get saveAndTest => 'Uložit a otestovat';

  @override
  String connOk(int count) {
    return 'Spojení OK (načteno úloh: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Nedostupné: $error';
  }
}
