// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get navQueue => 'Coadă';

  @override
  String get navCharacters => 'Personaje';

  @override
  String get navSettings => 'Setări';

  @override
  String get retry => 'Încearcă din nou';

  @override
  String nasUnavailable(String error) {
    return 'NAS indisponibil: $error';
  }

  @override
  String get promptLabel => 'Promptul obiectului';

  @override
  String get categoriesLabel => 'Categorii';

  @override
  String get catHelmet => 'Coif';

  @override
  String get catBack => 'Aripi / spate';

  @override
  String get catSword => 'Sabie';

  @override
  String get catFront => 'Platoșă';

  @override
  String get catHat => 'Căciulă';

  @override
  String get catHair => 'Păr (riscant)';

  @override
  String get styleLabel => 'Stil';

  @override
  String get collectionLabel => 'Colecție';

  @override
  String get radialTitle => 'Ornament de jur împrejur';

  @override
  String get radialSubtitle => 'simetrie radială – torturi, coroane';

  @override
  String variantsPerCategory(int count) {
    return 'Variante pe categorie: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generează $count de obiecte',
      few: 'Generează $count obiecte',
      one: 'Generează $count obiect',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Sarcini trimise: $sent – Spark generează (~4 min pe bucată, pe rând)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Trimise: $sent, erori: $errors';
  }

  @override
  String get queueEmpty =>
      'Încă nu este nimic pe NAS – trimite un lot din Composer.';

  @override
  String get stNew => 'Așteaptă triajul';

  @override
  String get stRemeshing => 'Se recalculează în TRELLIS (~4 min)';

  @override
  String get stApproved => 'În coada de conversie';

  @override
  String get stConverting => 'Se convertește';

  @override
  String get stConverted => 'Convertit – așteaptă revizuirea 3D';

  @override
  String get stPacked => 'Împachetat pentru Studio';

  @override
  String get stFailed => 'Eșuat';

  @override
  String get stRejected => 'Respins';

  @override
  String get stRerolled => 'Regenerat';

  @override
  String get tapFor3d => 'atinge pentru 3D';

  @override
  String get pack => 'Împachetează';

  @override
  String sparkSection(int count) {
    return 'Se realizează pe Spark ($count)';
  }

  @override
  String get sgQueued => 'așteaptă în coadă';

  @override
  String get sgConcept => 'desenează conceptul';

  @override
  String get sgCleanplate => 'elimină fundalul';

  @override
  String get sgMesh => 'modelează în 3D (~4 min)';

  @override
  String get sgPush => 'trimite pe NAS';

  @override
  String get sgDone => 'gata';

  @override
  String get sgFailed => 'eșuat';

  @override
  String get reviewTris => 'triunghiuri';

  @override
  String get reviewTexture => 'textură';

  @override
  String get reviewSymmetry => 'simetrie';

  @override
  String get yes => 'da';

  @override
  String get no => 'nu';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vârfuri de cusătură: $count)';
  }

  @override
  String get reconvertAgain => 'Convertește din nou';

  @override
  String get reconvertSymmetry => 'Din nou cu simetrie';

  @override
  String get radialMenu => 'Ornament de jur împrejur (radial)';

  @override
  String get noSymmetry => 'Fără simetrie';

  @override
  String get backToConcept => 'Înapoi la concept';

  @override
  String get show3d => 'Arată modelul 3D';

  @override
  String get rejectedToast => 'Respins';

  @override
  String get rerollToast => 'Reroll trimis la Spark';

  @override
  String get approvedToast => 'Aprobat → conversie';

  @override
  String errorPrefix(String error) {
    return 'Eroare: $error';
  }

  @override
  String get allSorted => 'Totul e sortat. Trimit un lot nou din Composer?';

  @override
  String get newShort => 'Nou';

  @override
  String get charactersEmpty =>
      'Încă nu există niciun personaj.\nÎncepe cu o fotografie sau o imagine a unui personaj umanoid.';

  @override
  String get newCharacter => 'Personaj nou';

  @override
  String get creating => 'Se creează…';

  @override
  String get generate => 'Generează';

  @override
  String get nameLabel => 'Nume';

  @override
  String get prepPhoto => 'Pregătește fotografia';

  @override
  String get prepPhotoHelp =>
      'Elimină fundalul; dacă brațele sunt lipite de corp, le desprinde într-o poziție A, iar dacă lipsesc picioarele sub glezne, le completează. Fără asta, rig-ul eșuează adesea la membre contopite.';

  @override
  String get animationsLabel => 'Animații';

  @override
  String libraryLoadFailed(String error) {
    return 'Biblioteca nu a putut fi încărcată: $error';
  }

  @override
  String get libraryEmpty =>
      'Biblioteca este goală. Clipurile se înregistrează cu scriptul seed_animlib.py pe NAS.';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Cameră';

  @override
  String get characterFallback => 'Personaj';

  @override
  String get downloadGlb => 'Descarcă GLB';

  @override
  String get downloadFbx => 'Descarcă FBX';

  @override
  String get downloadZip => 'Descarcă tot (ZIP)';

  @override
  String get sendRoblox => 'Trimite în Roblox';

  @override
  String get sendLuanti => 'Trimite în Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportul către $target a fost pus în coadă';
  }

  @override
  String get clipsTitle => 'Clipuri';

  @override
  String get exportsTitle => 'Exporturi';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (încercarea $attempt)';
  }

  @override
  String get retryStep => 'Reîncearcă pasul';

  @override
  String stepOf(int step, int total) {
    return 'pasul $step din $total';
  }

  @override
  String get cfAccessHelp =>
      'Necesar doar pentru ugc.ol1n.com (acces fără Tailscale).';

  @override
  String get saveAndTest => 'Salvează și testează';

  @override
  String connOk(int count) {
    return 'Conexiune OK (sarcini încărcate: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Indisponibil: $error';
  }
}
