// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navQueue => 'File';

  @override
  String get navCharacters => 'Personnages';

  @override
  String get navSettings => 'Réglages';

  @override
  String get retry => 'Réessayer';

  @override
  String nasUnavailable(String error) {
    return 'NAS indisponible : $error';
  }

  @override
  String get promptLabel => 'Prompt de l\'item';

  @override
  String get categoriesLabel => 'Catégories';

  @override
  String get catHelmet => 'Casque';

  @override
  String get catBack => 'Ailes / dos';

  @override
  String get catSword => 'Épée';

  @override
  String get catFront => 'Plastron';

  @override
  String get catHat => 'Bonnet';

  @override
  String get catHair => 'Cheveux (risqué)';

  @override
  String get styleLabel => 'Style';

  @override
  String get collectionLabel => 'Collection';

  @override
  String get radialTitle => 'Décor tout autour';

  @override
  String get radialSubtitle => 'symétrie radiale – gâteaux, couronnes';

  @override
  String variantsPerCategory(int count) {
    return 'Variantes par catégorie : $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Générer $count items',
      one: 'Générer $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tâches envoyées : $sent – Spark génère (~4 min par pièce, l\'une après l\'autre)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Envoyées : $sent, erreurs : $errors';
  }

  @override
  String get queueEmpty =>
      'Rien sur le NAS pour l\'instant – envoyez un lot depuis le Composer.';

  @override
  String get stNew => 'En attente de triage';

  @override
  String get stRemeshing => 'Recalcul dans TRELLIS (~4 min)';

  @override
  String get stApproved => 'En file pour la conversion';

  @override
  String get stConverting => 'Conversion en cours';

  @override
  String get stConverted => 'Converti – en attente de la revue 3D';

  @override
  String get stPacked => 'Emballé pour Studio';

  @override
  String get stFailed => 'Échec';

  @override
  String get stRejected => 'Rejeté';

  @override
  String get stRerolled => 'Regénéré';

  @override
  String get tapFor3d => 'touchez pour la 3D';

  @override
  String get pack => 'Emballer';

  @override
  String sparkSection(int count) {
    return 'En cours de fabrication sur Spark ($count)';
  }

  @override
  String get sgQueued => 'attend dans la file';

  @override
  String get sgConcept => 'dessine le concept';

  @override
  String get sgCleanplate => 'retire l\'arrière-plan';

  @override
  String get sgMesh => 'modélise en 3D (~4 min)';

  @override
  String get sgPush => 'envoie au NAS';

  @override
  String get sgDone => 'terminé';

  @override
  String get sgFailed => 'échec';

  @override
  String get reviewTris => 'triangles';

  @override
  String get reviewTexture => 'texture';

  @override
  String get reviewSymmetry => 'symétrie';

  @override
  String get yes => 'oui';

  @override
  String get no => 'non';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (sommets de couture : $count)';
  }

  @override
  String get reconvertAgain => 'Convertir à nouveau';

  @override
  String get reconvertSymmetry => 'De nouveau avec symétrie';

  @override
  String get radialMenu => 'Décor tout autour (radial)';

  @override
  String get noSymmetry => 'Sans symétrie';

  @override
  String get backToConcept => 'Retour au concept';

  @override
  String get show3d => 'Afficher le modèle 3D';

  @override
  String get rejectedToast => 'Rejeté';

  @override
  String get rerollToast => 'Reroll envoyé à Spark';

  @override
  String get approvedToast => 'Approuvé → conversion';

  @override
  String errorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get allSorted =>
      'Tout est trié. Envoyer un nouveau lot depuis le Composer ?';

  @override
  String get newShort => 'Nouveau';

  @override
  String get charactersEmpty =>
      'Aucun personnage pour l\'instant.\nCommencez avec une photo ou une image d\'un personnage humanoïde.';

  @override
  String get newCharacter => 'Nouveau personnage';

  @override
  String get creating => 'Création…';

  @override
  String get generate => 'Générer';

  @override
  String get nameLabel => 'Nom';

  @override
  String get prepPhoto => 'Préparer la photo';

  @override
  String get prepPhotoHelp =>
      'Retire l\'arrière-plan ; si les bras sont collés au corps, il les écarte en A-pose, et si les jambes manquent sous les chevilles, il les complète. Sans cela, le rig échoue souvent sur des membres soudés.';

  @override
  String get animationsLabel => 'Animations';

  @override
  String libraryLoadFailed(String error) {
    return 'Impossible de charger la bibliothèque : $error';
  }

  @override
  String get libraryEmpty =>
      'La bibliothèque est vide. Les clips sont enregistrés avec le script seed_animlib.py sur le NAS.';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Appareil photo';

  @override
  String get characterFallback => 'Personnage';

  @override
  String get downloadGlb => 'Télécharger le GLB';

  @override
  String get downloadFbx => 'Télécharger le FBX';

  @override
  String get downloadZip => 'Tout télécharger (ZIP)';

  @override
  String get sendRoblox => 'Envoyer vers Roblox';

  @override
  String get sendLuanti => 'Envoyer vers Luanti';

  @override
  String exportQueued(String target) {
    return 'Export vers $target mis en file';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exports';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (essai $attempt)';
  }

  @override
  String get retryStep => 'Réessayer l\'étape';

  @override
  String stepOf(int step, int total) {
    return 'étape $step sur $total';
  }

  @override
  String get cfAccessHelp =>
      'Nécessaire seulement pour ugc.ol1n.com (accès sans Tailscale).';

  @override
  String get saveAndTest => 'Enregistrer et tester';

  @override
  String connOk(int count) {
    return 'Connexion OK (tâches chargées : $count)';
  }

  @override
  String connFailed(String error) {
    return 'Indisponible : $error';
  }
}
