// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navQueue => 'कतार';

  @override
  String get navCharacters => 'किरदार';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String nasUnavailable(String error) {
    return 'NAS उपलब्ध नहीं है: $error';
  }

  @override
  String get promptLabel => 'आइटम का प्रॉम्प्ट';

  @override
  String get categoriesLabel => 'श्रेणियाँ';

  @override
  String get catHelmet => 'हेलमेट';

  @override
  String get catBack => 'पंख / पीठ';

  @override
  String get catSword => 'तलवार';

  @override
  String get catFront => 'सीने का कवच';

  @override
  String get catHat => 'टोपी';

  @override
  String get catHair => 'बाल (जोखिम भरा)';

  @override
  String get styleLabel => 'शैली';

  @override
  String get collectionLabel => 'संग्रह';

  @override
  String get radialTitle => 'चारों ओर सजावट';

  @override
  String get radialSubtitle => 'रेडियल समरूपता – केक, मुकुट';

  @override
  String variantsPerCategory(int count) {
    return 'प्रति श्रेणी वेरिएंट: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम बनाएँ',
      one: '$count आइटम बनाएँ',
    );
    return '$_temp0 (~$minutes मिनट)';
  }

  @override
  String composerSent(int sent) {
    return 'भेजे गए काम: $sent – Spark बना रहा है (~हर एक 4 मिनट, एक के बाद एक)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'भेजे गए: $sent, त्रुटियाँ: $errors';
  }

  @override
  String get queueEmpty => 'NAS पर अभी कुछ नहीं है – Composer से बैच भेजें।';

  @override
  String get stNew => 'ट्रायाज की प्रतीक्षा में';

  @override
  String get stRemeshing => 'TRELLIS में दोबारा गणना हो रही है (~4 मिनट)';

  @override
  String get stApproved => 'रूपांतरण की कतार में';

  @override
  String get stConverting => 'रूपांतरण हो रहा है';

  @override
  String get stConverted => 'रूपांतरित – 3D समीक्षा की प्रतीक्षा में';

  @override
  String get stPacked => 'Studio के लिए पैक किया गया';

  @override
  String get stFailed => 'विफल';

  @override
  String get stRejected => 'अस्वीकृत';

  @override
  String get stRerolled => 'दोबारा बनाया गया';

  @override
  String get tapFor3d => '3D के लिए टैप करें';

  @override
  String get pack => 'पैक करें';

  @override
  String sparkSection(int count) {
    return 'Spark पर बन रहे हैं ($count)';
  }

  @override
  String get sgQueued => 'कतार में इंतज़ार कर रहा है';

  @override
  String get sgConcept => 'कॉन्सेप्ट बना रहा है';

  @override
  String get sgCleanplate => 'बैकग्राउंड हटा रहा है';

  @override
  String get sgMesh => '3D मॉडल बना रहा है (~4 मिनट)';

  @override
  String get sgPush => 'NAS को भेज रहा है';

  @override
  String get sgDone => 'पूरा';

  @override
  String get sgFailed => 'विफल';

  @override
  String get reviewTris => 'त्रिभुज';

  @override
  String get reviewTexture => 'टेक्सचर';

  @override
  String get reviewSymmetry => 'समरूपता';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (सीम वर्टेक्स: $count)';
  }

  @override
  String get reconvertAgain => 'फिर से रूपांतरित करें';

  @override
  String get reconvertSymmetry => 'समरूपता के साथ फिर से';

  @override
  String get radialMenu => 'चारों ओर सजावट (रेडियल)';

  @override
  String get noSymmetry => 'बिना समरूपता';

  @override
  String get backToConcept => 'कॉन्सेप्ट पर लौटें';

  @override
  String get show3d => '3D मॉडल दिखाएँ';

  @override
  String get rejectedToast => 'अस्वीकृत';

  @override
  String get rerollToast => 'रीरोल Spark को भेजा गया';

  @override
  String get approvedToast => 'स्वीकृत → रूपांतरण';

  @override
  String errorPrefix(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get allSorted => 'सब छँट गया। Composer से नया बैच भेजें?';

  @override
  String get newShort => 'नया';

  @override
  String get charactersEmpty =>
      'अभी कोई किरदार नहीं है।\nमानव-जैसे किरदार की फ़ोटो या तस्वीर से शुरू करें।';

  @override
  String get newCharacter => 'नया किरदार';

  @override
  String get creating => 'बन रहा है…';

  @override
  String get generate => 'बनाएँ';

  @override
  String get nameLabel => 'नाम';

  @override
  String get prepPhoto => 'फ़ोटो तैयार करें';

  @override
  String get prepPhotoHelp =>
      'बैकग्राउंड हटाता है; अगर हाथ शरीर से चिपके हों तो उन्हें A-पोज़ में अलग करता है, और टखनों के नीचे पैर न हों तो उन्हें पूरा करता है। इसके बिना जुड़े अंगों पर रिग अक्सर विफल हो जाता है।';

  @override
  String get animationsLabel => 'एनिमेशन';

  @override
  String libraryLoadFailed(String error) {
    return 'लाइब्रेरी लोड नहीं हो सकी: $error';
  }

  @override
  String get libraryEmpty =>
      'लाइब्रेरी खाली है। क्लिप NAS पर seed_animlib.py स्क्रिप्ट से दर्ज होते हैं।';

  @override
  String get gallery => 'गैलरी';

  @override
  String get camera => 'कैमरा';

  @override
  String get characterFallback => 'किरदार';

  @override
  String get downloadGlb => 'GLB डाउनलोड करें';

  @override
  String get downloadFbx => 'FBX डाउनलोड करें';

  @override
  String get downloadZip => 'सब डाउनलोड करें (ZIP)';

  @override
  String get sendRoblox => 'Roblox को भेजें';

  @override
  String get sendLuanti => 'Luanti को भेजें';

  @override
  String exportQueued(String target) {
    return '$target में एक्सपोर्ट कतार में जोड़ा गया';
  }

  @override
  String get clipsTitle => 'क्लिप';

  @override
  String get exportsTitle => 'एक्सपोर्ट';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (प्रयास $attempt)';
  }

  @override
  String get retryStep => 'चरण फिर से आज़माएँ';

  @override
  String stepOf(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'केवल ugc.ol1n.com के लिए ज़रूरी (Tailscale के बिना पहुँच)।';

  @override
  String get saveAndTest => 'सहेजें और जाँचें';

  @override
  String connOk(int count) {
    return 'कनेक्शन ठीक है (लोड हुए काम: $count)';
  }

  @override
  String connFailed(String error) {
    return 'उपलब्ध नहीं: $error';
  }
}
