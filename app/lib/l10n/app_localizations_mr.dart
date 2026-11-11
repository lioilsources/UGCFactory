// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get navQueue => 'रांग';

  @override
  String get navCharacters => 'पात्रे';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String nasUnavailable(String error) {
    return 'NAS उपलब्ध नाही: $error';
  }

  @override
  String get promptLabel => 'आयटमचा प्रॉम्प्ट';

  @override
  String get categoriesLabel => 'श्रेणी';

  @override
  String get catHelmet => 'हेल्मेट';

  @override
  String get catBack => 'पंख / पाठ';

  @override
  String get catSword => 'तलवार';

  @override
  String get catFront => 'छातीचे चिलखत';

  @override
  String get catHat => 'टोपी';

  @override
  String get catHair => 'केस (जोखमीचे)';

  @override
  String get styleLabel => 'शैली';

  @override
  String get collectionLabel => 'संग्रह';

  @override
  String get radialTitle => 'सभोवती सजावट';

  @override
  String get radialSubtitle => 'रेडियल सममिती – केक, मुकुट';

  @override
  String variantsPerCategory(int count) {
    return 'प्रत्येक श्रेणीसाठी प्रकार: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आयटम तयार करा',
      one: '$count आयटम तयार करा',
    );
    return '$_temp0 (~$minutes मिनिटे)';
  }

  @override
  String composerSent(int sent) {
    return 'पाठवलेली कामे: $sent – Spark तयार करत आहे (~प्रत्येकी 4 मिनिटे, एकामागून एक)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'पाठवले: $sent, त्रुटी: $errors';
  }

  @override
  String get queueEmpty => 'NAS वर अजून काहीही नाही – Composer मधून बॅच पाठवा.';

  @override
  String get stNew => 'ट्रायाजची वाट पाहत आहे';

  @override
  String get stRemeshing => 'TRELLIS मध्ये पुन्हा मोजले जात आहे (~4 मिनिटे)';

  @override
  String get stApproved => 'रूपांतरणाच्या रांगेत';

  @override
  String get stConverting => 'रूपांतर होत आहे';

  @override
  String get stConverted => 'रूपांतरित – 3D पुनरावलोकनाची वाट पाहत आहे';

  @override
  String get stPacked => 'Studio साठी पॅक केले';

  @override
  String get stFailed => 'अयशस्वी';

  @override
  String get stRejected => 'नाकारले';

  @override
  String get stRerolled => 'पुन्हा तयार केले';

  @override
  String get tapFor3d => '3D साठी टॅप करा';

  @override
  String get pack => 'पॅक करा';

  @override
  String sparkSection(int count) {
    return 'Spark वर तयार होत आहे ($count)';
  }

  @override
  String get sgQueued => 'रांगेत वाट पाहत आहे';

  @override
  String get sgConcept => 'संकल्पना रेखाटत आहे';

  @override
  String get sgCleanplate => 'पार्श्वभूमी काढत आहे';

  @override
  String get sgMesh => '3D मॉडेलिंग (~4 मिनिटे)';

  @override
  String get sgPush => 'NAS ला पाठवत आहे';

  @override
  String get sgDone => 'पूर्ण';

  @override
  String get sgFailed => 'अयशस्वी';

  @override
  String get reviewTris => 'त्रिकोण';

  @override
  String get reviewTexture => 'टेक्सचर';

  @override
  String get reviewSymmetry => 'सममिती';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (शिवणीचे शिरोबिंदू: $count)';
  }

  @override
  String get reconvertAgain => 'पुन्हा रूपांतर करा';

  @override
  String get reconvertSymmetry => 'सममितीसह पुन्हा';

  @override
  String get radialMenu => 'सभोवती सजावट (रेडियल)';

  @override
  String get noSymmetry => 'सममितीशिवाय';

  @override
  String get backToConcept => 'संकल्पनेकडे परत';

  @override
  String get show3d => '3D मॉडेल दाखवा';

  @override
  String get rejectedToast => 'नाकारले';

  @override
  String get rerollToast => 'रीरोल Spark ला पाठवला';

  @override
  String get approvedToast => 'मंजूर → रूपांतर';

  @override
  String errorPrefix(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get allSorted =>
      'सर्व वर्गीकृत झाले. Composer मधून नवीन बॅच पाठवायची?';

  @override
  String get newShort => 'नवे';

  @override
  String get charactersEmpty =>
      'अजून कोणतेही पात्र नाही.\nमानवसदृश पात्राच्या फोटोने किंवा चित्राने सुरुवात करा.';

  @override
  String get newCharacter => 'नवे पात्र';

  @override
  String get creating => 'तयार करत आहे…';

  @override
  String get generate => 'तयार करा';

  @override
  String get nameLabel => 'नाव';

  @override
  String get prepPhoto => 'फोटो तयार करा';

  @override
  String get prepPhotoHelp =>
      'पार्श्वभूमी काढते; हात शरीराला चिकटले असतील तर त्यांना A-पोजमध्ये वेगळे करते, आणि घोट्याखाली पाय नसतील तर ते पूर्ण करते. याशिवाय जोडलेल्या अवयवांवर रिग अनेकदा अयशस्वी होतो.';

  @override
  String get animationsLabel => 'अॅनिमेशन';

  @override
  String libraryLoadFailed(String error) {
    return 'लायब्ररी लोड करता आली नाही: $error';
  }

  @override
  String get libraryEmpty =>
      'लायब्ररी रिकामी आहे. क्लिप NAS वरील seed_animlib.py स्क्रिप्टने नोंदवल्या जातात.';

  @override
  String get gallery => 'गॅलरी';

  @override
  String get camera => 'कॅमेरा';

  @override
  String get characterFallback => 'पात्र';

  @override
  String get downloadGlb => 'GLB डाउनलोड करा';

  @override
  String get downloadFbx => 'FBX डाउनलोड करा';

  @override
  String get downloadZip => 'सर्व डाउनलोड करा (ZIP)';

  @override
  String get sendRoblox => 'Roblox ला पाठवा';

  @override
  String get sendLuanti => 'Luanti ला पाठवा';

  @override
  String exportQueued(String target) {
    return '$target साठी एक्सपोर्ट रांगेत टाकले';
  }

  @override
  String get clipsTitle => 'क्लिप';

  @override
  String get exportsTitle => 'एक्सपोर्ट';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (प्रयत्न $attempt)';
  }

  @override
  String get retryStep => 'पायरी पुन्हा करून पहा';

  @override
  String stepOf(int step, int total) {
    return 'पायरी $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'फक्त ugc.ol1n.com साठी आवश्यक (Tailscale शिवाय प्रवेश).';

  @override
  String get saveAndTest => 'जतन करा आणि तपासा';

  @override
  String connOk(int count) {
    return 'कनेक्शन ठीक (लोड झालेली कामे: $count)';
  }

  @override
  String connFailed(String error) {
    return 'उपलब्ध नाही: $error';
  }
}
