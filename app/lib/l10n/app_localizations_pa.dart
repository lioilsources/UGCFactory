// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get navQueue => 'ਕਤਾਰ';

  @override
  String get navCharacters => 'ਪਾਤਰ';

  @override
  String get navSettings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String nasUnavailable(String error) {
    return 'NAS ਉਪਲਬਧ ਨਹੀਂ: $error';
  }

  @override
  String get promptLabel => 'ਆਈਟਮ ਦਾ ਪ੍ਰੌਂਪਟ';

  @override
  String get categoriesLabel => 'ਸ਼੍ਰੇਣੀਆਂ';

  @override
  String get catHelmet => 'ਹੈਲਮਟ';

  @override
  String get catBack => 'ਖੰਭ / ਪਿੱਠ';

  @override
  String get catSword => 'ਤਲਵਾਰ';

  @override
  String get catFront => 'ਛਾਤੀ ਦਾ ਕਵਚ';

  @override
  String get catHat => 'ਟੋਪੀ';

  @override
  String get catHair => 'ਵਾਲ (ਜੋਖਮ ਵਾਲੇ)';

  @override
  String get styleLabel => 'ਸ਼ੈਲੀ';

  @override
  String get collectionLabel => 'ਸੰਗ੍ਰਹਿ';

  @override
  String get radialTitle => 'ਚਾਰੇ ਪਾਸੇ ਸਜਾਵਟ';

  @override
  String get radialSubtitle => 'ਰੇਡੀਅਲ ਸਮਮਿਤੀ – ਕੇਕ, ਤਾਜ';

  @override
  String variantsPerCategory(int count) {
    return 'ਹਰ ਸ਼੍ਰੇਣੀ ਦੇ ਵੇਰੀਐਂਟ: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਆਈਟਮਾਂ ਬਣਾਓ',
      one: '$count ਆਈਟਮ ਬਣਾਓ',
    );
    return '$_temp0 (~$minutes ਮਿੰਟ)';
  }

  @override
  String composerSent(int sent) {
    return 'ਭੇਜੇ ਕੰਮ: $sent – Spark ਬਣਾ ਰਿਹਾ ਹੈ (~ਹਰ ਇੱਕ 4 ਮਿੰਟ, ਇੱਕ ਤੋਂ ਬਾਅਦ ਇੱਕ)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'ਭੇਜੇ: $sent, ਗਲਤੀਆਂ: $errors';
  }

  @override
  String get queueEmpty => 'NAS ’ਤੇ ਹਾਲੇ ਕੁਝ ਨਹੀਂ – Composer ਤੋਂ ਬੈਚ ਭੇਜੋ।';

  @override
  String get stNew => 'ਟ੍ਰਾਇਏਜ ਦੀ ਉਡੀਕ ਵਿੱਚ';

  @override
  String get stRemeshing => 'TRELLIS ਵਿੱਚ ਦੁਬਾਰਾ ਗਿਣਿਆ ਜਾ ਰਿਹਾ ਹੈ (~4 ਮਿੰਟ)';

  @override
  String get stApproved => 'ਤਬਦੀਲੀ ਦੀ ਕਤਾਰ ਵਿੱਚ';

  @override
  String get stConverting => 'ਤਬਦੀਲ ਹੋ ਰਿਹਾ ਹੈ';

  @override
  String get stConverted => 'ਤਬਦੀਲ ਹੋਇਆ – 3D ਸਮੀਖਿਆ ਦੀ ਉਡੀਕ ਵਿੱਚ';

  @override
  String get stPacked => 'Studio ਲਈ ਪੈਕ ਕੀਤਾ';

  @override
  String get stFailed => 'ਅਸਫਲ';

  @override
  String get stRejected => 'ਰੱਦ ਕੀਤਾ';

  @override
  String get stRerolled => 'ਦੁਬਾਰਾ ਬਣਾਇਆ';

  @override
  String get tapFor3d => '3D ਲਈ ਟੈਪ ਕਰੋ';

  @override
  String get pack => 'ਪੈਕ ਕਰੋ';

  @override
  String sparkSection(int count) {
    return 'Spark ’ਤੇ ਬਣ ਰਹੇ ਹਨ ($count)';
  }

  @override
  String get sgQueued => 'ਕਤਾਰ ਵਿੱਚ ਉਡੀਕ ਰਿਹਾ ਹੈ';

  @override
  String get sgConcept => 'ਸੰਕਲਪ ਵਾਹ ਰਿਹਾ ਹੈ';

  @override
  String get sgCleanplate => 'ਪਿਛੋਕੜ ਹਟਾ ਰਿਹਾ ਹੈ';

  @override
  String get sgMesh => '3D ਮਾਡਲਿੰਗ (~4 ਮਿੰਟ)';

  @override
  String get sgPush => 'NAS ਨੂੰ ਭੇਜ ਰਿਹਾ ਹੈ';

  @override
  String get sgDone => 'ਹੋ ਗਿਆ';

  @override
  String get sgFailed => 'ਅਸਫਲ';

  @override
  String get reviewTris => 'ਤਿਕੋਣ';

  @override
  String get reviewTexture => 'ਟੈਕਸਚਰ';

  @override
  String get reviewSymmetry => 'ਸਮਮਿਤੀ';

  @override
  String get yes => 'ਹਾਂ';

  @override
  String get no => 'ਨਹੀਂ';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (ਸੀਵਨ ਦੇ ਸਿਰੇ: $count)';
  }

  @override
  String get reconvertAgain => 'ਦੁਬਾਰਾ ਤਬਦੀਲ ਕਰੋ';

  @override
  String get reconvertSymmetry => 'ਸਮਮਿਤੀ ਨਾਲ ਦੁਬਾਰਾ';

  @override
  String get radialMenu => 'ਚਾਰੇ ਪਾਸੇ ਸਜਾਵਟ (ਰੇਡੀਅਲ)';

  @override
  String get noSymmetry => 'ਬਿਨਾਂ ਸਮਮਿਤੀ';

  @override
  String get backToConcept => 'ਸੰਕਲਪ ’ਤੇ ਵਾਪਸ';

  @override
  String get show3d => '3D ਮਾਡਲ ਦਿਖਾਓ';

  @override
  String get rejectedToast => 'ਰੱਦ ਕੀਤਾ';

  @override
  String get rerollToast => 'ਰੀਰੋਲ Spark ਨੂੰ ਭੇਜਿਆ';

  @override
  String get approvedToast => 'ਮਨਜ਼ੂਰ → ਤਬਦੀਲੀ';

  @override
  String errorPrefix(String error) {
    return 'ਗਲਤੀ: $error';
  }

  @override
  String get allSorted => 'ਸਭ ਛਾਂਟ ਲਿਆ ਗਿਆ। Composer ਤੋਂ ਨਵਾਂ ਬੈਚ ਭੇਜਣਾ ਹੈ?';

  @override
  String get newShort => 'ਨਵਾਂ';

  @override
  String get charactersEmpty =>
      'ਹਾਲੇ ਕੋਈ ਪਾਤਰ ਨਹੀਂ।\nਮਨੁੱਖੀ ਆਕਾਰ ਵਾਲੇ ਪਾਤਰ ਦੀ ਫ਼ੋਟੋ ਜਾਂ ਤਸਵੀਰ ਨਾਲ ਸ਼ੁਰੂ ਕਰੋ।';

  @override
  String get newCharacter => 'ਨਵਾਂ ਪਾਤਰ';

  @override
  String get creating => 'ਬਣਾਇਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get generate => 'ਬਣਾਓ';

  @override
  String get nameLabel => 'ਨਾਂ';

  @override
  String get prepPhoto => 'ਫ਼ੋਟੋ ਤਿਆਰ ਕਰੋ';

  @override
  String get prepPhotoHelp =>
      'ਪਿਛੋਕੜ ਹਟਾਉਂਦਾ ਹੈ; ਜੇ ਬਾਂਹਾਂ ਸਰੀਰ ਨਾਲ ਚਿਪਕੀਆਂ ਹੋਣ ਤਾਂ ਉਨ੍ਹਾਂ ਨੂੰ A-ਪੋਜ਼ ਵਿੱਚ ਵੱਖ ਕਰਦਾ ਹੈ, ਅਤੇ ਗਿੱਟਿਆਂ ਤੋਂ ਹੇਠਾਂ ਲੱਤਾਂ ਨਾ ਹੋਣ ਤਾਂ ਉਨ੍ਹਾਂ ਨੂੰ ਪੂਰਾ ਕਰਦਾ ਹੈ। ਇਸ ਤੋਂ ਬਿਨਾਂ ਜੁੜੇ ਅੰਗਾਂ ’ਤੇ ਰਿਗ ਅਕਸਰ ਅਸਫਲ ਹੋ ਜਾਂਦਾ ਹੈ।';

  @override
  String get animationsLabel => 'ਐਨੀਮੇਸ਼ਨ';

  @override
  String libraryLoadFailed(String error) {
    return 'ਲਾਇਬ੍ਰੇਰੀ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ: $error';
  }

  @override
  String get libraryEmpty =>
      'ਲਾਇਬ੍ਰੇਰੀ ਖਾਲੀ ਹੈ। ਕਲਿੱਪ NAS ’ਤੇ seed_animlib.py ਸਕ੍ਰਿਪਟ ਨਾਲ ਦਰਜ ਹੁੰਦੇ ਹਨ।';

  @override
  String get gallery => 'ਗੈਲਰੀ';

  @override
  String get camera => 'ਕੈਮਰਾ';

  @override
  String get characterFallback => 'ਪਾਤਰ';

  @override
  String get downloadGlb => 'GLB ਡਾਊਨਲੋਡ ਕਰੋ';

  @override
  String get downloadFbx => 'FBX ਡਾਊਨਲੋਡ ਕਰੋ';

  @override
  String get downloadZip => 'ਸਭ ਡਾਊਨਲੋਡ ਕਰੋ (ZIP)';

  @override
  String get sendRoblox => 'Roblox ਨੂੰ ਭੇਜੋ';

  @override
  String get sendLuanti => 'Luanti ਨੂੰ ਭੇਜੋ';

  @override
  String exportQueued(String target) {
    return '$target ਵਿੱਚ ਐਕਸਪੋਰਟ ਕਤਾਰ ਵਿੱਚ ਪਾਇਆ';
  }

  @override
  String get clipsTitle => 'ਕਲਿੱਪ';

  @override
  String get exportsTitle => 'ਐਕਸਪੋਰਟ';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ਕੋਸ਼ਿਸ਼ $attempt)';
  }

  @override
  String get retryStep => 'ਕਦਮ ਦੁਬਾਰਾ ਅਜ਼ਮਾਓ';

  @override
  String stepOf(int step, int total) {
    return 'ਕਦਮ $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ਸਿਰਫ਼ ugc.ol1n.com ਲਈ ਲੋੜੀਂਦਾ (Tailscale ਤੋਂ ਬਿਨਾਂ ਪਹੁੰਚ)।';

  @override
  String get saveAndTest => 'ਸੰਭਾਲੋ ਅਤੇ ਜਾਂਚੋ';

  @override
  String connOk(int count) {
    return 'ਕਨੈਕਸ਼ਨ ਠੀਕ ਹੈ (ਲੋਡ ਹੋਏ ਕੰਮ: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ਉਪਲਬਧ ਨਹੀਂ: $error';
  }
}
