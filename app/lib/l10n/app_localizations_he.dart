// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get navQueue => 'תור';

  @override
  String get navCharacters => 'דמויות';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get retry => 'נסו שוב';

  @override
  String nasUnavailable(String error) {
    return 'ה-NAS אינו זמין: $error';
  }

  @override
  String get promptLabel => 'פרומפט הפריט';

  @override
  String get categoriesLabel => 'קטגוריות';

  @override
  String get catHelmet => 'קסדה';

  @override
  String get catBack => 'כנפיים / גב';

  @override
  String get catSword => 'חרב';

  @override
  String get catFront => 'שריון חזה';

  @override
  String get catHat => 'כובע';

  @override
  String get catHair => 'שיער (מסוכן)';

  @override
  String get styleLabel => 'סגנון';

  @override
  String get collectionLabel => 'קולקציה';

  @override
  String get radialTitle => 'עיטור מסביב';

  @override
  String get radialSubtitle => 'סימטריה רדיאלית – עוגות, כתרים';

  @override
  String variantsPerCategory(int count) {
    return 'גרסאות לכל קטגוריה: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'יצירת $count פריטים',
      many: 'יצירת $count פריטים',
      two: 'יצירת שני פריטים',
      one: 'יצירת פריט אחד',
    );
    return '$_temp0 (~$minutes דק\')';
  }

  @override
  String composerSent(int sent) {
    return 'משימות שנשלחו: $sent – Spark מייצר (~4 דקות לכל פריט, אחד אחרי השני)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'נשלחו: $sent, שגיאות: $errors';
  }

  @override
  String get queueEmpty => 'עדיין אין כלום ב-NAS – שלחו אצווה מה-Composer.';

  @override
  String get stNew => 'ממתין לטריאז\'';

  @override
  String get stRemeshing => 'מחושב מחדש ב-TRELLIS (~4 דקות)';

  @override
  String get stApproved => 'בתור להמרה';

  @override
  String get stConverting => 'בהמרה';

  @override
  String get stConverted => 'הומר – ממתין לבדיקת 3D';

  @override
  String get stPacked => 'ארוז עבור Studio';

  @override
  String get stFailed => 'נכשל';

  @override
  String get stRejected => 'נדחה';

  @override
  String get stRerolled => 'נוצר מחדש';

  @override
  String get tapFor3d => 'הקישו ל-3D';

  @override
  String get pack => 'אריזה';

  @override
  String sparkSection(int count) {
    return 'בהכנה ב-Spark ($count)';
  }

  @override
  String get sgQueued => 'ממתין בתור';

  @override
  String get sgConcept => 'מצייר את הקונספט';

  @override
  String get sgCleanplate => 'מסיר את הרקע';

  @override
  String get sgMesh => 'מדגם ב-3D (~4 דקות)';

  @override
  String get sgPush => 'נשלח ל-NAS';

  @override
  String get sgDone => 'הושלם';

  @override
  String get sgFailed => 'נכשל';

  @override
  String get reviewTris => 'משולשים';

  @override
  String get reviewTexture => 'טקסטורה';

  @override
  String get reviewSymmetry => 'סימטריה';

  @override
  String get yes => 'כן';

  @override
  String get no => 'לא';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (קודקודי תפר: $count)';
  }

  @override
  String get reconvertAgain => 'המרה מחדש';

  @override
  String get reconvertSymmetry => 'שוב עם סימטריה';

  @override
  String get radialMenu => 'עיטור מסביב (רדיאלי)';

  @override
  String get noSymmetry => 'בלי סימטריה';

  @override
  String get backToConcept => 'חזרה לקונספט';

  @override
  String get show3d => 'הצגת מודל ה-3D';

  @override
  String get rejectedToast => 'נדחה';

  @override
  String get rerollToast => 'ה-reroll נשלח ל-Spark';

  @override
  String get approvedToast => 'אושר ← המרה';

  @override
  String errorPrefix(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get allSorted => 'הכול מוין. לשלוח אצווה חדשה מה-Composer?';

  @override
  String get newShort => 'חדש';

  @override
  String get charactersEmpty =>
      'עדיין אין דמויות.\nהתחילו בתמונה או בציור של דמות דמוית אדם.';

  @override
  String get newCharacter => 'דמות חדשה';

  @override
  String get creating => 'יוצר…';

  @override
  String get generate => 'יצירה';

  @override
  String get nameLabel => 'שם';

  @override
  String get prepPhoto => 'הכנת התמונה';

  @override
  String get prepPhotoHelp =>
      'מסיר את הרקע; אם הידיים דבוקות לגוף, מרחיק אותן לתנוחת A, ואם חסרות רגליים מתחת לקרסוליים, משלים אותן. בלי זה ה-rig נכשל לעיתים קרובות באיברים מאוחים.';

  @override
  String get animationsLabel => 'אנימציות';

  @override
  String libraryLoadFailed(String error) {
    return 'טעינת הספרייה נכשלה: $error';
  }

  @override
  String get libraryEmpty =>
      'הספרייה ריקה. קליפים נרשמים בסקריפט seed_animlib.py ב-NAS.';

  @override
  String get gallery => 'גלריה';

  @override
  String get camera => 'מצלמה';

  @override
  String get characterFallback => 'דמות';

  @override
  String get downloadGlb => 'הורדת GLB';

  @override
  String get downloadFbx => 'הורדת FBX';

  @override
  String get downloadZip => 'הורדת הכול (ZIP)';

  @override
  String get sendRoblox => 'שליחה ל-Roblox';

  @override
  String get sendLuanti => 'שליחה ל-Luanti';

  @override
  String exportQueued(String target) {
    return 'הייצוא אל $target נכנס לתור';
  }

  @override
  String get clipsTitle => 'קליפים';

  @override
  String get exportsTitle => 'ייצואים';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (ניסיון $attempt)';
  }

  @override
  String get retryStep => 'ניסיון חוזר לשלב';

  @override
  String stepOf(int step, int total) {
    return 'שלב $step מתוך $total';
  }

  @override
  String get cfAccessHelp => 'נדרש רק עבור ugc.ol1n.com (גישה בלי Tailscale).';

  @override
  String get saveAndTest => 'שמירה ובדיקה';

  @override
  String connOk(int count) {
    return 'החיבור תקין (משימות שנטענו: $count)';
  }

  @override
  String connFailed(String error) {
    return 'לא זמין: $error';
  }
}
