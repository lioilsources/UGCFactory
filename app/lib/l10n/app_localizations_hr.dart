// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get navQueue => 'Red';

  @override
  String get navCharacters => 'Likovi';

  @override
  String get navSettings => 'Postavke';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String nasUnavailable(String error) {
    return 'NAS nije dostupan: $error';
  }

  @override
  String get promptLabel => 'Prompt predmeta';

  @override
  String get categoriesLabel => 'Kategorije';

  @override
  String get catHelmet => 'Kaciga';

  @override
  String get catBack => 'Krila / leđa';

  @override
  String get catSword => 'Mač';

  @override
  String get catFront => 'Prsni oklop';

  @override
  String get catHat => 'Kapa';

  @override
  String get catHair => 'Kosa (rizično)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Kolekcija';

  @override
  String get radialTitle => 'Ukras uokolo';

  @override
  String get radialSubtitle => 'radijalna simetrija – torte, krune';

  @override
  String variantsPerCategory(int count) {
    return 'Varijanti po kategoriji: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generiraj $count predmeta',
      few: 'Generiraj $count predmeta',
      one: 'Generiraj $count predmet',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Poslani zadaci: $sent – Spark generira (~4 min po komadu, jedan po jedan)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Poslano: $sent, pogreške: $errors';
  }

  @override
  String get queueEmpty =>
      'Na NAS-u još nema ničega – pošaljite batch iz Composera.';

  @override
  String get stNew => 'Čeka triažu';

  @override
  String get stRemeshing => 'Ponovno se računa u TRELLIS-u (~4 min)';

  @override
  String get stApproved => 'U redu za pretvorbu';

  @override
  String get stConverting => 'Pretvara se';

  @override
  String get stConverted => 'Pretvoreno – čeka 3D pregled';

  @override
  String get stPacked => 'Zapakirano za Studio';

  @override
  String get stFailed => 'Nije uspjelo';

  @override
  String get stRejected => 'Odbijeno';

  @override
  String get stRerolled => 'Ponovno generirano';

  @override
  String get tapFor3d => 'dodirnite za 3D';

  @override
  String get pack => 'Zapakiraj';

  @override
  String sparkSection(int count) {
    return 'Izrađuje se na Sparku ($count)';
  }

  @override
  String get sgQueued => 'čeka u redu';

  @override
  String get sgConcept => 'crta koncept';

  @override
  String get sgCleanplate => 'uklanja pozadinu';

  @override
  String get sgMesh => 'modelira u 3D-u (~4 min)';

  @override
  String get sgPush => 'šalje na NAS';

  @override
  String get sgDone => 'gotovo';

  @override
  String get sgFailed => 'nije uspjelo';

  @override
  String get reviewTris => 'trokuti';

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
    return '$symmetry (vrhovi šava: $count)';
  }

  @override
  String get reconvertAgain => 'Pretvori ponovno';

  @override
  String get reconvertSymmetry => 'Ponovno sa simetrijom';

  @override
  String get radialMenu => 'Ukras uokolo (radijalno)';

  @override
  String get noSymmetry => 'Bez simetrije';

  @override
  String get backToConcept => 'Natrag na koncept';

  @override
  String get show3d => 'Prikaži 3D model';

  @override
  String get rejectedToast => 'Odbijeno';

  @override
  String get rerollToast => 'Reroll poslan na Spark';

  @override
  String get approvedToast => 'Odobreno → pretvorba';

  @override
  String errorPrefix(String error) {
    return 'Pogreška: $error';
  }

  @override
  String get allSorted => 'Sve razvrstano. Poslati novi batch iz Composera?';

  @override
  String get newShort => 'Novi';

  @override
  String get charactersEmpty =>
      'Još nema nijednog lika.\nZapočnite fotografijom ili slikom humanoidnog lika.';

  @override
  String get newCharacter => 'Novi lik';

  @override
  String get creating => 'Stvaram…';

  @override
  String get generate => 'Generiraj';

  @override
  String get nameLabel => 'Ime';

  @override
  String get prepPhoto => 'Pripremi fotografiju';

  @override
  String get prepPhotoHelp =>
      'Uklanja pozadinu; ako su ruke slijepljene uz tijelo, odmiče ih u A-pozu, a ako nedostaju noge ispod gležnjeva, nadopunjuje ih. Bez toga rig često ne uspije na sraslim udovima.';

  @override
  String get animationsLabel => 'Animacije';

  @override
  String libraryLoadFailed(String error) {
    return 'Knjižnicu nije bilo moguće učitati: $error';
  }

  @override
  String get libraryEmpty =>
      'Knjižnica je prazna. Klipovi se registriraju skriptom seed_animlib.py na NAS-u.';

  @override
  String get gallery => 'Galerija';

  @override
  String get camera => 'Kamera';

  @override
  String get characterFallback => 'Lik';

  @override
  String get downloadGlb => 'Preuzmi GLB';

  @override
  String get downloadFbx => 'Preuzmi FBX';

  @override
  String get downloadZip => 'Preuzmi sve (ZIP)';

  @override
  String get sendRoblox => 'Pošalji u Roblox';

  @override
  String get sendLuanti => 'Pošalji u Luanti';

  @override
  String exportQueued(String target) {
    return 'Izvoz u $target stavljen u red';
  }

  @override
  String get clipsTitle => 'Klipovi';

  @override
  String get exportsTitle => 'Izvozi';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (pokušaj $attempt)';
  }

  @override
  String get retryStep => 'Ponovi korak';

  @override
  String stepOf(int step, int total) {
    return 'korak $step od $total';
  }

  @override
  String get cfAccessHelp =>
      'Potrebno samo za ugc.ol1n.com (pristup bez Tailscalea).';

  @override
  String get saveAndTest => 'Spremi i testiraj';

  @override
  String connOk(int count) {
    return 'Veza je u redu (učitani zadaci: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Nedostupno: $error';
  }
}
