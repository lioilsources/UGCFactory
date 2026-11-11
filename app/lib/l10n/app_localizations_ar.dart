// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navQueue => 'الطابور';

  @override
  String get navCharacters => 'الشخصيات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String nasUnavailable(String error) {
    return 'خادم NAS غير متاح: $error';
  }

  @override
  String get promptLabel => 'وصف العنصر';

  @override
  String get categoriesLabel => 'الفئات';

  @override
  String get catHelmet => 'خوذة';

  @override
  String get catBack => 'أجنحة / ظهر';

  @override
  String get catSword => 'سيف';

  @override
  String get catFront => 'درع الصدر';

  @override
  String get catHat => 'قبعة';

  @override
  String get catHair => 'شعر (محفوف بالمخاطر)';

  @override
  String get styleLabel => 'النمط';

  @override
  String get collectionLabel => 'المجموعة';

  @override
  String get radialTitle => 'زخرفة على الجوانب كلها';

  @override
  String get radialSubtitle => 'تماثل شعاعي – كعكات وتيجان';

  @override
  String variantsPerCategory(int count) {
    return 'عدد النسخ لكل فئة: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'توليد $count عنصر',
      many: 'توليد $count عنصراً',
      few: 'توليد $count عناصر',
      two: 'توليد عنصرين',
      one: 'توليد عنصر واحد',
      zero: 'توليد $count عنصر',
    );
    return '$_temp0 (~$minutes د)';
  }

  @override
  String composerSent(int sent) {
    return 'المهام المرسلة: $sent – يعمل Spark على التوليد (~4 دقائق للقطعة، واحدة تلو الأخرى)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'المرسل: $sent، الأخطاء: $errors';
  }

  @override
  String get queueEmpty => 'لا شيء على NAS بعد – أرسل دفعة من Composer.';

  @override
  String get stNew => 'بانتظار الفرز';

  @override
  String get stRemeshing => 'تُعاد حسابه في TRELLIS (~4 دقائق)';

  @override
  String get stApproved => 'في طابور التحويل';

  @override
  String get stConverting => 'قيد التحويل';

  @override
  String get stConverted => 'تم التحويل – بانتظار مراجعة 3D';

  @override
  String get stPacked => 'معبّأ لـ Studio';

  @override
  String get stFailed => 'فشل';

  @override
  String get stRejected => 'مرفوض';

  @override
  String get stRerolled => 'أُعيد توليده';

  @override
  String get tapFor3d => 'اضغط لعرض 3D';

  @override
  String get pack => 'تعبئة';

  @override
  String sparkSection(int count) {
    return 'قيد الإنتاج على Spark ($count)';
  }

  @override
  String get sgQueued => 'في الطابور';

  @override
  String get sgConcept => 'يرسم التصور';

  @override
  String get sgCleanplate => 'يزيل الخلفية';

  @override
  String get sgMesh => 'يبني النموذج 3D (~4 دقائق)';

  @override
  String get sgPush => 'يُرسل إلى NAS';

  @override
  String get sgDone => 'تم';

  @override
  String get sgFailed => 'فشل';

  @override
  String get reviewTris => 'المثلثات';

  @override
  String get reviewTexture => 'الخامة';

  @override
  String get reviewSymmetry => 'التماثل';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (رؤوس الدرزات: $count)';
  }

  @override
  String get reconvertAgain => 'تحويل مرة أخرى';

  @override
  String get reconvertSymmetry => 'مرة أخرى مع التماثل';

  @override
  String get radialMenu => 'زخرفة على الجوانب كلها (شعاعي)';

  @override
  String get noSymmetry => 'بدون تماثل';

  @override
  String get backToConcept => 'العودة إلى التصور';

  @override
  String get show3d => 'عرض نموذج 3D';

  @override
  String get rejectedToast => 'مرفوض';

  @override
  String get rerollToast => 'أُرسلت إعادة التوليد إلى Spark';

  @override
  String get approvedToast => 'تمت الموافقة ← التحويل';

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String get allSorted => 'تم فرز كل شيء. هل ترسل دفعة جديدة من Composer؟';

  @override
  String get newShort => 'جديد';

  @override
  String get charactersEmpty =>
      'لا توجد شخصيات بعد.\nابدأ بصورة أو رسم لشخصية بشرية الشكل.';

  @override
  String get newCharacter => 'شخصية جديدة';

  @override
  String get creating => 'جارٍ الإنشاء…';

  @override
  String get generate => 'توليد';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get prepPhoto => 'تجهيز الصورة';

  @override
  String get prepPhotoHelp =>
      'يزيل الخلفية؛ وإذا كانت الذراعان ملتصقتين بالجسم يبعدهما إلى وضعية A، وإذا كانت الساقان ناقصتين تحت الكاحلين يكمّلهما. دون ذلك يفشل الهيكل (rig) غالباً مع الأطراف الملتصقة.';

  @override
  String get animationsLabel => 'الرسوم المتحركة';

  @override
  String libraryLoadFailed(String error) {
    return 'تعذّر تحميل المكتبة: $error';
  }

  @override
  String get libraryEmpty =>
      'المكتبة فارغة. تُسجَّل المقاطع بالسكربت seed_animlib.py على NAS.';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get characterFallback => 'شخصية';

  @override
  String get downloadGlb => 'تنزيل GLB';

  @override
  String get downloadFbx => 'تنزيل FBX';

  @override
  String get downloadZip => 'تنزيل الكل (ZIP)';

  @override
  String get sendRoblox => 'إرسال إلى Roblox';

  @override
  String get sendLuanti => 'إرسال إلى Luanti';

  @override
  String exportQueued(String target) {
    return 'أُضيف التصدير إلى $target إلى الطابور';
  }

  @override
  String get clipsTitle => 'المقاطع';

  @override
  String get exportsTitle => 'عمليات التصدير';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (المحاولة $attempt)';
  }

  @override
  String get retryStep => 'إعادة محاولة الخطوة';

  @override
  String stepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get cfAccessHelp =>
      'مطلوب فقط لـ ugc.ol1n.com (الوصول دون Tailscale).';

  @override
  String get saveAndTest => 'حفظ واختبار';

  @override
  String connOk(int count) {
    return 'الاتصال سليم (المهام المحمّلة: $count)';
  }

  @override
  String connFailed(String error) {
    return 'غير متاح: $error';
  }
}
