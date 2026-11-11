// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get navQueue => 'ಸರತಿ';

  @override
  String get navCharacters => 'ಪಾತ್ರಗಳು';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String nasUnavailable(String error) {
    return 'NAS ಲಭ್ಯವಿಲ್ಲ: $error';
  }

  @override
  String get promptLabel => 'ವಸ್ತುವಿನ ಪ್ರಾಂಪ್ಟ್';

  @override
  String get categoriesLabel => 'ವರ್ಗಗಳು';

  @override
  String get catHelmet => 'ಹೆಲ್ಮೆಟ್';

  @override
  String get catBack => 'ರೆಕ್ಕೆ / ಬೆನ್ನು';

  @override
  String get catSword => 'ಖಡ್ಗ';

  @override
  String get catFront => 'ಎದೆ ಕವಚ';

  @override
  String get catHat => 'ಟೋಪಿ';

  @override
  String get catHair => 'ಕೂದಲು (ಅಪಾಯಕಾರಿ)';

  @override
  String get styleLabel => 'ಶೈಲಿ';

  @override
  String get collectionLabel => 'ಸಂಗ್ರಹ';

  @override
  String get radialTitle => 'ಸುತ್ತಲೂ ಅಲಂಕಾರ';

  @override
  String get radialSubtitle => 'ರೇಡಿಯಲ್ ಸಮಮಿತಿ – ಕೇಕ್, ಕಿರೀಟ';

  @override
  String variantsPerCategory(int count) {
    return 'ಪ್ರತಿ ವರ್ಗಕ್ಕೆ ರೂಪಾಂತರಗಳು: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವಸ್ತುಗಳನ್ನು ರಚಿಸಿ',
      one: '$count ವಸ್ತು ರಚಿಸಿ',
    );
    return '$_temp0 (~$minutes ನಿಮಿ)';
  }

  @override
  String composerSent(int sent) {
    return 'ಕಳುಹಿಸಿದ ಕೆಲಸಗಳು: $sent – Spark ರಚಿಸುತ್ತಿದೆ (~ಪ್ರತಿಯೊಂದಕ್ಕೆ 4 ನಿಮಿಷ, ಒಂದರ ನಂತರ ಒಂದು)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'ಕಳುಹಿಸಿದ್ದು: $sent, ದೋಷಗಳು: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS ನಲ್ಲಿ ಇನ್ನೂ ಏನೂ ಇಲ್ಲ – Composer ನಿಂದ ಬ್ಯಾಚ್ ಕಳುಹಿಸಿ.';

  @override
  String get stNew => 'ಟ್ರಯಾಜ್‌ಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get stRemeshing => 'TRELLIS ನಲ್ಲಿ ಮರುಲೆಕ್ಕಹಾಕಲಾಗುತ್ತಿದೆ (~4 ನಿಮಿಷ)';

  @override
  String get stApproved => 'ಪರಿವರ್ತನೆಯ ಸರತಿಯಲ್ಲಿ';

  @override
  String get stConverting => 'ಪರಿವರ್ತಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get stConverted => 'ಪರಿವರ್ತಿತ – 3D ಪರಿಶೀಲನೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get stPacked => 'Studio ಗಾಗಿ ಪ್ಯಾಕ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get stFailed => 'ವಿಫಲ';

  @override
  String get stRejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get stRerolled => 'ಮತ್ತೆ ರಚಿಸಲಾಗಿದೆ';

  @override
  String get tapFor3d => '3D ಗಾಗಿ ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get pack => 'ಪ್ಯಾಕ್ ಮಾಡಿ';

  @override
  String sparkSection(int count) {
    return 'Spark ನಲ್ಲಿ ತಯಾರಾಗುತ್ತಿದೆ ($count)';
  }

  @override
  String get sgQueued => 'ಸರತಿಯಲ್ಲಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get sgConcept => 'ಕಲ್ಪನೆಯನ್ನು ಬರೆಯುತ್ತಿದೆ';

  @override
  String get sgCleanplate => 'ಹಿನ್ನೆಲೆ ತೆಗೆಯುತ್ತಿದೆ';

  @override
  String get sgMesh => '3D ಮಾದರಿ ರಚಿಸುತ್ತಿದೆ (~4 ನಿಮಿಷ)';

  @override
  String get sgPush => 'NAS ಗೆ ಕಳುಹಿಸುತ್ತಿದೆ';

  @override
  String get sgDone => 'ಮುಗಿದಿದೆ';

  @override
  String get sgFailed => 'ವಿಫಲ';

  @override
  String get reviewTris => 'ತ್ರಿಕೋನಗಳು';

  @override
  String get reviewTexture => 'ಟೆಕ್ಸ್ಚರ್';

  @override
  String get reviewSymmetry => 'ಸಮಮಿತಿ';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (ಹೊಲಿಗೆ ಶೃಂಗಗಳು: $count)';
  }

  @override
  String get reconvertAgain => 'ಮತ್ತೆ ಪರಿವರ್ತಿಸಿ';

  @override
  String get reconvertSymmetry => 'ಸಮಮಿತಿಯೊಂದಿಗೆ ಮತ್ತೆ';

  @override
  String get radialMenu => 'ಸುತ್ತಲೂ ಅಲಂಕಾರ (ರೇಡಿಯಲ್)';

  @override
  String get noSymmetry => 'ಸಮಮಿತಿ ಇಲ್ಲದೆ';

  @override
  String get backToConcept => 'ಕಲ್ಪನೆಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get show3d => '3D ಮಾದರಿ ತೋರಿಸಿ';

  @override
  String get rejectedToast => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get rerollToast => 'ರೀರೋಲ್ Spark ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get approvedToast => 'ಅನುಮೋದಿಸಲಾಗಿದೆ → ಪರಿವರ್ತನೆ';

  @override
  String errorPrefix(String error) {
    return 'ದೋಷ: $error';
  }

  @override
  String get allSorted =>
      'ಎಲ್ಲವೂ ವಿಂಗಡಣೆಯಾಗಿದೆ. Composer ನಿಂದ ಹೊಸ ಬ್ಯಾಚ್ ಕಳುಹಿಸಬೇಕೆ?';

  @override
  String get newShort => 'ಹೊಸದು';

  @override
  String get charactersEmpty =>
      'ಇನ್ನೂ ಯಾವುದೇ ಪಾತ್ರವಿಲ್ಲ.\nಮಾನವಾಕೃತಿಯ ಪಾತ್ರದ ಫೋಟೋ ಅಥವಾ ಚಿತ್ರದಿಂದ ಪ್ರಾರಂಭಿಸಿ.';

  @override
  String get newCharacter => 'ಹೊಸ ಪಾತ್ರ';

  @override
  String get creating => 'ರಚಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get generate => 'ರಚಿಸಿ';

  @override
  String get nameLabel => 'ಹೆಸರು';

  @override
  String get prepPhoto => 'ಫೋಟೋ ಸಿದ್ಧಪಡಿಸಿ';

  @override
  String get prepPhotoHelp =>
      'ಹಿನ್ನೆಲೆಯನ್ನು ತೆಗೆಯುತ್ತದೆ; ಕೈಗಳು ದೇಹಕ್ಕೆ ಅಂಟಿಕೊಂಡಿದ್ದರೆ A-ಪೋಸ್‌ಗೆ ಎಳೆಯುತ್ತದೆ, ಹಾಗೂ ಹಿಮ್ಮಡಿಯ ಕೆಳಗೆ ಕಾಲುಗಳಿಲ್ಲದಿದ್ದರೆ ಅವನ್ನು ಪೂರ್ಣಗೊಳಿಸುತ್ತದೆ. ಇದಿಲ್ಲದೆ ಜೋಡಿಕೊಂಡ ಅಂಗಗಳಲ್ಲಿ ರಿಗ್ ಆಗಾಗ ವಿಫಲವಾಗುತ್ತದೆ.';

  @override
  String get animationsLabel => 'ಅನಿಮೇಷನ್‌ಗಳು';

  @override
  String libraryLoadFailed(String error) {
    return 'ಲೈಬ್ರರಿಯನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get libraryEmpty =>
      'ಲೈಬ್ರರಿ ಖಾಲಿಯಾಗಿದೆ. ಕ್ಲಿಪ್‌ಗಳನ್ನು NAS ನಲ್ಲಿ seed_animlib.py ಸ್ಕ್ರಿಪ್ಟ್ ಮೂಲಕ ನೋಂದಾಯಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get gallery => 'ಗ್ಯಾಲರಿ';

  @override
  String get camera => 'ಕ್ಯಾಮೆರಾ';

  @override
  String get characterFallback => 'ಪಾತ್ರ';

  @override
  String get downloadGlb => 'GLB ಡೌನ್‌ಲೋಡ್';

  @override
  String get downloadFbx => 'FBX ಡೌನ್‌ಲೋಡ್';

  @override
  String get downloadZip => 'ಎಲ್ಲವನ್ನೂ ಡೌನ್‌ಲೋಡ್ (ZIP)';

  @override
  String get sendRoblox => 'Roblox ಗೆ ಕಳುಹಿಸಿ';

  @override
  String get sendLuanti => 'Luanti ಗೆ ಕಳುಹಿಸಿ';

  @override
  String exportQueued(String target) {
    return '$target ಗೆ ರಫ್ತು ಸರತಿಗೆ ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get clipsTitle => 'ಕ್ಲಿಪ್‌ಗಳು';

  @override
  String get exportsTitle => 'ರಫ್ತುಗಳು';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ಪ್ರಯತ್ನ $attempt)';
  }

  @override
  String get retryStep => 'ಹಂತವನ್ನು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String stepOf(int step, int total) {
    return 'ಹಂತ $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ugc.ol1n.com ಗೆ ಮಾತ್ರ ಅಗತ್ಯ (Tailscale ಇಲ್ಲದೆ ಪ್ರವೇಶ).';

  @override
  String get saveAndTest => 'ಉಳಿಸಿ ಮತ್ತು ಪರೀಕ್ಷಿಸಿ';

  @override
  String connOk(int count) {
    return 'ಸಂಪರ್ಕ ಸರಿ (ಲೋಡ್ ಆದ ಕೆಲಸಗಳು: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ಲಭ್ಯವಿಲ್ಲ: $error';
  }
}
