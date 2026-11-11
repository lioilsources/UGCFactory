// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get navQueue => 'வரிசை';

  @override
  String get navCharacters => 'கதாபாத்திரங்கள்';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get retry => 'மீண்டும் முயல்';

  @override
  String nasUnavailable(String error) {
    return 'NAS கிடைக்கவில்லை: $error';
  }

  @override
  String get promptLabel => 'பொருளின் ப்ராம்ப்ட்';

  @override
  String get categoriesLabel => 'வகைகள்';

  @override
  String get catHelmet => 'தலைக்கவசம்';

  @override
  String get catBack => 'இறக்கைகள் / முதுகு';

  @override
  String get catSword => 'வாள்';

  @override
  String get catFront => 'மார்புக் கவசம்';

  @override
  String get catHat => 'தொப்பி';

  @override
  String get catHair => 'முடி (ஆபத்து)';

  @override
  String get styleLabel => 'பாணி';

  @override
  String get collectionLabel => 'தொகுப்பு';

  @override
  String get radialTitle => 'சுற்றிலும் அலங்காரம்';

  @override
  String get radialSubtitle => 'ஆரச் சமச்சீர் – கேக்குகள், கிரீடங்கள்';

  @override
  String variantsPerCategory(int count) {
    return 'ஒவ்வொரு வகைக்கும் மாறுபாடுகள்: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்களை உருவாக்கு',
      one: '$count பொருளை உருவாக்கு',
    );
    return '$_temp0 (~$minutes நிமி)';
  }

  @override
  String composerSent(int sent) {
    return 'அனுப்பிய பணிகள்: $sent – Spark உருவாக்குகிறது (~ஒவ்வொன்றுக்கும் 4 நிமிடம், ஒன்றன்பின் ஒன்று)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'அனுப்பியவை: $sent, பிழைகள்: $errors';
  }

  @override
  String get queueEmpty =>
      'NAS-இல் இன்னும் எதுவும் இல்லை – Composer-இலிருந்து தொகுதியை அனுப்புங்கள்.';

  @override
  String get stNew => 'டிரையாஜுக்காகக் காத்திருக்கிறது';

  @override
  String get stRemeshing =>
      'TRELLIS-இல் மீண்டும் கணக்கிடப்படுகிறது (~4 நிமிடம்)';

  @override
  String get stApproved => 'மாற்ற வரிசையில்';

  @override
  String get stConverting => 'மாற்றப்படுகிறது';

  @override
  String get stConverted =>
      'மாற்றப்பட்டது – 3D மதிப்பாய்வுக்காகக் காத்திருக்கிறது';

  @override
  String get stPacked => 'Studio-க்காகப் பொதியப்பட்டது';

  @override
  String get stFailed => 'தோல்வி';

  @override
  String get stRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get stRerolled => 'மீண்டும் உருவாக்கப்பட்டது';

  @override
  String get tapFor3d => '3D பார்க்கத் தட்டுங்கள்';

  @override
  String get pack => 'பொதி செய்';

  @override
  String sparkSection(int count) {
    return 'Spark-இல் உருவாக்கப்படுகிறது ($count)';
  }

  @override
  String get sgQueued => 'வரிசையில் காத்திருக்கிறது';

  @override
  String get sgConcept => 'கருத்துருவை வரைகிறது';

  @override
  String get sgCleanplate => 'பின்னணியை நீக்குகிறது';

  @override
  String get sgMesh => '3D மாதிரி உருவாக்குகிறது (~4 நிமிடம்)';

  @override
  String get sgPush => 'NAS-க்கு அனுப்புகிறது';

  @override
  String get sgDone => 'முடிந்தது';

  @override
  String get sgFailed => 'தோல்வி';

  @override
  String get reviewTris => 'முக்கோணங்கள்';

  @override
  String get reviewTexture => 'அமைப்பு';

  @override
  String get reviewSymmetry => 'சமச்சீர்';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (தையல் முனைகள்: $count)';
  }

  @override
  String get reconvertAgain => 'மீண்டும் மாற்று';

  @override
  String get reconvertSymmetry => 'சமச்சீருடன் மீண்டும்';

  @override
  String get radialMenu => 'சுற்றிலும் அலங்காரம் (ஆரம்)';

  @override
  String get noSymmetry => 'சமச்சீர் இல்லாமல்';

  @override
  String get backToConcept => 'கருத்துருவுக்குத் திரும்பு';

  @override
  String get show3d => '3D மாதிரியைக் காட்டு';

  @override
  String get rejectedToast => 'நிராகரிக்கப்பட்டது';

  @override
  String get rerollToast => 'ரீரோல் Spark-க்கு அனுப்பப்பட்டது';

  @override
  String get approvedToast => 'அங்கீகரிக்கப்பட்டது → மாற்றம்';

  @override
  String errorPrefix(String error) {
    return 'பிழை: $error';
  }

  @override
  String get allSorted =>
      'அனைத்தும் தரம்பிரிக்கப்பட்டன. Composer-இலிருந்து புதிய தொகுதியை அனுப்பவா?';

  @override
  String get newShort => 'புதிய';

  @override
  String get charactersEmpty =>
      'இன்னும் கதாபாத்திரம் எதுவும் இல்லை.\nமனித வடிவ கதாபாத்திரத்தின் புகைப்படம் அல்லது படத்துடன் தொடங்குங்கள்.';

  @override
  String get newCharacter => 'புதிய கதாபாத்திரம்';

  @override
  String get creating => 'உருவாக்குகிறது…';

  @override
  String get generate => 'உருவாக்கு';

  @override
  String get nameLabel => 'பெயர்';

  @override
  String get prepPhoto => 'புகைப்படத்தைத் தயார் செய்';

  @override
  String get prepPhotoHelp =>
      'பின்னணியை நீக்கும்; கைகள் உடலோடு ஒட்டியிருந்தால் அவற்றை A-நிலைக்கு இழுக்கும், கணுக்காலுக்குக் கீழே கால்கள் இல்லையெனில் அவற்றை நிரப்பும். இது இல்லாமல் இணைந்த உறுப்புகளில் ரிக் அடிக்கடி தோல்வியடையும்.';

  @override
  String get animationsLabel => 'அனிமேஷன்கள்';

  @override
  String libraryLoadFailed(String error) {
    return 'நூலகத்தை ஏற்ற முடியவில்லை: $error';
  }

  @override
  String get libraryEmpty =>
      'நூலகம் காலியாக உள்ளது. கிளிப்கள் NAS-இல் seed_animlib.py ஸ்கிரிப்ட் மூலம் பதிவு செய்யப்படுகின்றன.';

  @override
  String get gallery => 'படத்தொகுப்பு';

  @override
  String get camera => 'கேமரா';

  @override
  String get characterFallback => 'கதாபாத்திரம்';

  @override
  String get downloadGlb => 'GLB பதிவிறக்கு';

  @override
  String get downloadFbx => 'FBX பதிவிறக்கு';

  @override
  String get downloadZip => 'அனைத்தையும் பதிவிறக்கு (ZIP)';

  @override
  String get sendRoblox => 'Roblox-க்கு அனுப்பு';

  @override
  String get sendLuanti => 'Luanti-க்கு அனுப்பு';

  @override
  String exportQueued(String target) {
    return '$target-க்கான ஏற்றுமதி வரிசையில் சேர்க்கப்பட்டது';
  }

  @override
  String get clipsTitle => 'கிளிப்கள்';

  @override
  String get exportsTitle => 'ஏற்றுமதிகள்';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (முயற்சி $attempt)';
  }

  @override
  String get retryStep => 'படியை மீண்டும் முயல்';

  @override
  String stepOf(int step, int total) {
    return 'படி $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ugc.ol1n.com-க்கு மட்டும் தேவை (Tailscale இல்லாத அணுகல்).';

  @override
  String get saveAndTest => 'சேமித்துச் சோதி';

  @override
  String connOk(int count) {
    return 'இணைப்பு சரி (ஏற்றப்பட்ட பணிகள்: $count)';
  }

  @override
  String connFailed(String error) {
    return 'கிடைக்கவில்லை: $error';
  }
}
