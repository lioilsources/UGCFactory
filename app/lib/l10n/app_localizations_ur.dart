// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get navQueue => 'قطار';

  @override
  String get navCharacters => 'کردار';

  @override
  String get navSettings => 'سیٹنگز';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String nasUnavailable(String error) {
    return 'NAS دستیاب نہیں: $error';
  }

  @override
  String get promptLabel => 'آئٹم کا پرامپٹ';

  @override
  String get categoriesLabel => 'زمرے';

  @override
  String get catHelmet => 'ہیلمٹ';

  @override
  String get catBack => 'پر / پیٹھ';

  @override
  String get catSword => 'تلوار';

  @override
  String get catFront => 'سینے کا زرہ';

  @override
  String get catHat => 'ٹوپی';

  @override
  String get catHair => 'بال (خطرناک)';

  @override
  String get styleLabel => 'انداز';

  @override
  String get collectionLabel => 'مجموعہ';

  @override
  String get radialTitle => 'چاروں طرف سجاوٹ';

  @override
  String get radialSubtitle => 'شعاعی تشاکل – کیک، تاج';

  @override
  String variantsPerCategory(int count) {
    return 'ہر زمرے کے ویریئنٹ: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آئٹمز بنائیں',
      one: '$count آئٹم بنائیں',
    );
    return '$_temp0 (~$minutes منٹ)';
  }

  @override
  String composerSent(int sent) {
    return 'بھیجے گئے کام: $sent – Spark بنا رہا ہے (~ہر ایک 4 منٹ، ایک کے بعد ایک)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'بھیجے گئے: $sent، غلطیاں: $errors';
  }

  @override
  String get queueEmpty => 'NAS پر ابھی کچھ نہیں – Composer سے بیچ بھیجیں۔';

  @override
  String get stNew => 'ٹرائیاج کے انتظار میں';

  @override
  String get stRemeshing => 'TRELLIS میں دوبارہ حساب ہو رہا ہے (~4 منٹ)';

  @override
  String get stApproved => 'تبدیلی کی قطار میں';

  @override
  String get stConverting => 'تبدیل ہو رہا ہے';

  @override
  String get stConverted => 'تبدیل ہو گیا – 3D جائزے کے انتظار میں';

  @override
  String get stPacked => 'Studio کے لیے پیک کیا گیا';

  @override
  String get stFailed => 'ناکام';

  @override
  String get stRejected => 'مسترد';

  @override
  String get stRerolled => 'دوبارہ بنایا گیا';

  @override
  String get tapFor3d => '3D کے لیے ٹیپ کریں';

  @override
  String get pack => 'پیک کریں';

  @override
  String sparkSection(int count) {
    return 'Spark پر بن رہے ہیں ($count)';
  }

  @override
  String get sgQueued => 'قطار میں انتظار کر رہا ہے';

  @override
  String get sgConcept => 'تصور بنا رہا ہے';

  @override
  String get sgCleanplate => 'پس منظر ہٹا رہا ہے';

  @override
  String get sgMesh => '3D ماڈلنگ (~4 منٹ)';

  @override
  String get sgPush => 'NAS کو بھیج رہا ہے';

  @override
  String get sgDone => 'مکمل';

  @override
  String get sgFailed => 'ناکام';

  @override
  String get reviewTris => 'تکون';

  @override
  String get reviewTexture => 'ٹیکسچر';

  @override
  String get reviewSymmetry => 'تشاکل';

  @override
  String get yes => 'ہاں';

  @override
  String get no => 'نہیں';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (سلائی کے سرے: $count)';
  }

  @override
  String get reconvertAgain => 'دوبارہ تبدیل کریں';

  @override
  String get reconvertSymmetry => 'تشاکل کے ساتھ دوبارہ';

  @override
  String get radialMenu => 'چاروں طرف سجاوٹ (شعاعی)';

  @override
  String get noSymmetry => 'بغیر تشاکل';

  @override
  String get backToConcept => 'تصور پر واپس';

  @override
  String get show3d => '3D ماڈل دکھائیں';

  @override
  String get rejectedToast => 'مسترد';

  @override
  String get rerollToast => 'ری رول Spark کو بھیجا گیا';

  @override
  String get approvedToast => 'منظور ← تبدیلی';

  @override
  String errorPrefix(String error) {
    return 'خرابی: $error';
  }

  @override
  String get allSorted => 'سب چھانٹ لیا گیا۔ Composer سے نیا بیچ بھیجیں؟';

  @override
  String get newShort => 'نیا';

  @override
  String get charactersEmpty =>
      'ابھی کوئی کردار نہیں۔\nانسان نما کردار کی تصویر یا فوٹو سے شروع کریں۔';

  @override
  String get newCharacter => 'نیا کردار';

  @override
  String get creating => 'بنایا جا رہا ہے…';

  @override
  String get generate => 'بنائیں';

  @override
  String get nameLabel => 'نام';

  @override
  String get prepPhoto => 'تصویر تیار کریں';

  @override
  String get prepPhotoHelp =>
      'پس منظر ہٹاتا ہے؛ اگر بازو جسم سے چپکے ہوں تو انہیں A-پوز میں الگ کرتا ہے، اور ٹخنوں کے نیچے ٹانگیں نہ ہوں تو انہیں مکمل کرتا ہے۔ اس کے بغیر جڑے ہوئے اعضا پر رگ اکثر ناکام ہو جاتا ہے۔';

  @override
  String get animationsLabel => 'اینیمیشنز';

  @override
  String libraryLoadFailed(String error) {
    return 'لائبریری لوڈ نہیں ہو سکی: $error';
  }

  @override
  String get libraryEmpty =>
      'لائبریری خالی ہے۔ کلپس NAS پر seed_animlib.py اسکرپٹ سے رجسٹر ہوتے ہیں۔';

  @override
  String get gallery => 'گیلری';

  @override
  String get camera => 'کیمرا';

  @override
  String get characterFallback => 'کردار';

  @override
  String get downloadGlb => 'GLB ڈاؤن لوڈ کریں';

  @override
  String get downloadFbx => 'FBX ڈاؤن لوڈ کریں';

  @override
  String get downloadZip => 'سب ڈاؤن لوڈ کریں (ZIP)';

  @override
  String get sendRoblox => 'Roblox کو بھیجیں';

  @override
  String get sendLuanti => 'Luanti کو بھیجیں';

  @override
  String exportQueued(String target) {
    return '$target کی ایکسپورٹ قطار میں ڈال دی گئی';
  }

  @override
  String get clipsTitle => 'کلپس';

  @override
  String get exportsTitle => 'ایکسپورٹس';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (کوشش $attempt)';
  }

  @override
  String get retryStep => 'مرحلہ دوبارہ آزمائیں';

  @override
  String stepOf(int step, int total) {
    return 'مرحلہ $step از $total';
  }

  @override
  String get cfAccessHelp =>
      'صرف ugc.ol1n.com کے لیے ضروری (Tailscale کے بغیر رسائی)۔';

  @override
  String get saveAndTest => 'محفوظ کریں اور جانچیں';

  @override
  String connOk(int count) {
    return 'کنکشن ٹھیک ہے (لوڈ شدہ کام: $count)';
  }

  @override
  String connFailed(String error) {
    return 'دستیاب نہیں: $error';
  }
}
