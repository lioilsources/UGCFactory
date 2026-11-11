// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navQueue => 'Queue';

  @override
  String get navCharacters => 'Characters';

  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Try again';

  @override
  String nasUnavailable(String error) {
    return 'NAS unavailable: $error';
  }

  @override
  String get promptLabel => 'Item prompt';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get catHelmet => 'Helmet';

  @override
  String get catBack => 'Wings / back';

  @override
  String get catSword => 'Sword';

  @override
  String get catFront => 'Chest plate';

  @override
  String get catHat => 'Cap';

  @override
  String get catHair => 'Hair (risky)';

  @override
  String get styleLabel => 'Style';

  @override
  String get collectionLabel => 'Collection';

  @override
  String get radialTitle => 'Decoration all around';

  @override
  String get radialSubtitle => 'radial symmetry – cakes, crowns';

  @override
  String variantsPerCategory(int count) {
    return 'Variants per category: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generate $count items',
      one: 'Generate $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Jobs sent: $sent – Spark is generating (~4 min each, one at a time)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Sent: $sent, errors: $errors';
  }

  @override
  String get queueEmpty =>
      'Nothing on the NAS yet – send a batch from the Composer.';

  @override
  String get stNew => 'Waiting for triage';

  @override
  String get stRemeshing => 'Being recomputed in TRELLIS (~4 min)';

  @override
  String get stApproved => 'Queued for conversion';

  @override
  String get stConverting => 'Converting';

  @override
  String get stConverted => 'Converted – waiting for 3D review';

  @override
  String get stPacked => 'Packed for Studio';

  @override
  String get stFailed => 'Failed';

  @override
  String get stRejected => 'Rejected';

  @override
  String get stRerolled => 'Rerolled';

  @override
  String get tapFor3d => 'tap for 3D';

  @override
  String get pack => 'Pack';

  @override
  String sparkSection(int count) {
    return 'Being made on Spark ($count)';
  }

  @override
  String get sgQueued => 'waiting in the queue';

  @override
  String get sgConcept => 'drawing the concept';

  @override
  String get sgCleanplate => 'removing the background';

  @override
  String get sgMesh => 'modelling in 3D (~4 min)';

  @override
  String get sgPush => 'sending to the NAS';

  @override
  String get sgDone => 'done';

  @override
  String get sgFailed => 'failed';

  @override
  String get reviewTris => 'triangles';

  @override
  String get reviewTexture => 'texture';

  @override
  String get reviewSymmetry => 'symmetry';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (seam vertices: $count)';
  }

  @override
  String get reconvertAgain => 'Convert again';

  @override
  String get reconvertSymmetry => 'Again with symmetry';

  @override
  String get radialMenu => 'Decoration all around (radial)';

  @override
  String get noSymmetry => 'No symmetry';

  @override
  String get backToConcept => 'Back to the concept';

  @override
  String get show3d => 'Show the 3D model';

  @override
  String get rejectedToast => 'Rejected';

  @override
  String get rerollToast => 'Reroll sent to Spark';

  @override
  String get approvedToast => 'Approved → conversion';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get allSorted => 'All sorted. Send a new batch from the Composer?';

  @override
  String get newShort => 'New';

  @override
  String get charactersEmpty =>
      'No characters yet.\nStart with a photo or an image of a humanoid character.';

  @override
  String get newCharacter => 'New character';

  @override
  String get creating => 'Creating…';

  @override
  String get generate => 'Generate';

  @override
  String get nameLabel => 'Name';

  @override
  String get prepPhoto => 'Prepare the photo';

  @override
  String get prepPhotoHelp =>
      'Removes the background; if the arms are stuck to the body it pulls them out into an A-pose, and if the legs are missing below the ankles it fills them in. Without this the rig often fails on fused limbs.';

  @override
  String get animationsLabel => 'Animations';

  @override
  String libraryLoadFailed(String error) {
    return 'The library could not be loaded: $error';
  }

  @override
  String get libraryEmpty =>
      'The library is empty. Clips are registered with the seed_animlib.py script on the NAS.';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get characterFallback => 'Character';

  @override
  String get downloadGlb => 'Download GLB';

  @override
  String get downloadFbx => 'Download FBX';

  @override
  String get downloadZip => 'Download all (ZIP)';

  @override
  String get sendRoblox => 'Send to Roblox';

  @override
  String get sendLuanti => 'Send to Luanti';

  @override
  String exportQueued(String target) {
    return 'Export to $target queued';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exports';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (attempt $attempt)';
  }

  @override
  String get retryStep => 'Retry the step';

  @override
  String stepOf(int step, int total) {
    return 'step $step of $total';
  }

  @override
  String get cfAccessHelp =>
      'Needed only for ugc.ol1n.com (access without Tailscale).';

  @override
  String get saveAndTest => 'Save and test';

  @override
  String connOk(int count) {
    return 'Connection OK (jobs loaded: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Unavailable: $error';
  }
}
