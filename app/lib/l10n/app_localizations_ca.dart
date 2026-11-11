// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get navQueue => 'Cua';

  @override
  String get navCharacters => 'Personatges';

  @override
  String get navSettings => 'Configuració';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String nasUnavailable(String error) {
    return 'NAS no disponible: $error';
  }

  @override
  String get promptLabel => 'Prompt de l\'ítem';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get catHelmet => 'Casc';

  @override
  String get catBack => 'Ales / esquena';

  @override
  String get catSword => 'Espasa';

  @override
  String get catFront => 'Pitrera';

  @override
  String get catHat => 'Gorra';

  @override
  String get catHair => 'Cabell (risc)';

  @override
  String get styleLabel => 'Estil';

  @override
  String get collectionLabel => 'Col·lecció';

  @override
  String get radialTitle => 'Decoració envoltant';

  @override
  String get radialSubtitle => 'simetria radial – pastissos, corones';

  @override
  String variantsPerCategory(int count) {
    return 'Variants per categoria: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Genera $count ítems',
      one: 'Genera $count ítem',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tasques enviades: $sent – Spark està generant (~4 min per peça, una darrere l\'altra)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Enviades: $sent, errors: $errors';
  }

  @override
  String get queueEmpty =>
      'Encara no hi ha res al NAS – envia un lot des del Composer.';

  @override
  String get stNew => 'Pendent de triatge';

  @override
  String get stRemeshing => 'Recalculant-se a TRELLIS (~4 min)';

  @override
  String get stApproved => 'A la cua de conversió';

  @override
  String get stConverting => 'Convertint';

  @override
  String get stConverted => 'Convertit – pendent de revisió 3D';

  @override
  String get stPacked => 'Empaquetat per a Studio';

  @override
  String get stFailed => 'Ha fallat';

  @override
  String get stRejected => 'Rebutjat';

  @override
  String get stRerolled => 'Regenerat';

  @override
  String get tapFor3d => 'toca per veure en 3D';

  @override
  String get pack => 'Empaqueta';

  @override
  String sparkSection(int count) {
    return 'Es fabrica a Spark ($count)';
  }

  @override
  String get sgQueued => 'esperant a la cua';

  @override
  String get sgConcept => 'dibuixant el concepte';

  @override
  String get sgCleanplate => 'traient el fons';

  @override
  String get sgMesh => 'modelant en 3D (~4 min)';

  @override
  String get sgPush => 'enviant al NAS';

  @override
  String get sgDone => 'fet';

  @override
  String get sgFailed => 'ha fallat';

  @override
  String get reviewTris => 'triangles';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'simetria';

  @override
  String get yes => 'sí';

  @override
  String get no => 'no';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vèrtexs de costura: $count)';
  }

  @override
  String get reconvertAgain => 'Torna a convertir';

  @override
  String get reconvertSymmetry => 'Un altre cop amb simetria';

  @override
  String get radialMenu => 'Decoració envoltant (radial)';

  @override
  String get noSymmetry => 'Sense simetria';

  @override
  String get backToConcept => 'Torna al concepte';

  @override
  String get show3d => 'Mostra el model 3D';

  @override
  String get rejectedToast => 'Rebutjat';

  @override
  String get rerollToast => 'Reroll enviat a Spark';

  @override
  String get approvedToast => 'Aprovat → conversió';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get allSorted => 'Tot triat. Vols enviar un lot nou des del Composer?';

  @override
  String get newShort => 'Nou';

  @override
  String get charactersEmpty =>
      'Encara no hi ha cap personatge.\nComença amb una foto o una imatge d\'un personatge humanoide.';

  @override
  String get newCharacter => 'Personatge nou';

  @override
  String get creating => 'Creant…';

  @override
  String get generate => 'Genera';

  @override
  String get nameLabel => 'Nom';

  @override
  String get prepPhoto => 'Prepara la foto';

  @override
  String get prepPhotoHelp =>
      'Treu el fons; si els braços estan enganxats al cos, els separa a una A-pose, i si falten les cames per sota dels turmells, les completa. Sense això, el rig sovint falla amb extremitats fusionades.';

  @override
  String get animationsLabel => 'Animacions';

  @override
  String libraryLoadFailed(String error) {
    return 'No s\'ha pogut carregar la biblioteca: $error';
  }

  @override
  String get libraryEmpty =>
      'La biblioteca és buida. Els clips es registren amb l\'script seed_animlib.py al NAS.';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Càmera';

  @override
  String get characterFallback => 'Personatge';

  @override
  String get downloadGlb => 'Baixa GLB';

  @override
  String get downloadFbx => 'Baixa FBX';

  @override
  String get downloadZip => 'Baixa-ho tot (ZIP)';

  @override
  String get sendRoblox => 'Envia a Roblox';

  @override
  String get sendLuanti => 'Envia a Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportació a $target afegida a la cua';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exportacions';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (intent $attempt)';
  }

  @override
  String get retryStep => 'Reintenta el pas';

  @override
  String stepOf(int step, int total) {
    return 'pas $step de $total';
  }

  @override
  String get cfAccessHelp =>
      'Només cal per a ugc.ol1n.com (accés sense Tailscale).';

  @override
  String get saveAndTest => 'Desa i prova';

  @override
  String connOk(int count) {
    return 'Connexió correcta (tasques carregades: $count)';
  }

  @override
  String connFailed(String error) {
    return 'No disponible: $error';
  }
}
