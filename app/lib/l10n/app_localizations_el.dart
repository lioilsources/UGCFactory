// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get navQueue => 'Ουρά';

  @override
  String get navCharacters => 'Χαρακτήρες';

  @override
  String get navSettings => 'Ρυθμίσεις';

  @override
  String get retry => 'Δοκιμάστε ξανά';

  @override
  String nasUnavailable(String error) {
    return 'Το NAS δεν είναι διαθέσιμο: $error';
  }

  @override
  String get promptLabel => 'Prompt του αντικειμένου';

  @override
  String get categoriesLabel => 'Κατηγορίες';

  @override
  String get catHelmet => 'Κράνος';

  @override
  String get catBack => 'Φτερά / πλάτη';

  @override
  String get catSword => 'Σπαθί';

  @override
  String get catFront => 'Θώρακας';

  @override
  String get catHat => 'Σκουφί';

  @override
  String get catHair => 'Μαλλιά (επικίνδυνο)';

  @override
  String get styleLabel => 'Στιλ';

  @override
  String get collectionLabel => 'Συλλογή';

  @override
  String get radialTitle => 'Διακόσμηση περιμετρικά';

  @override
  String get radialSubtitle => 'ακτινική συμμετρία – τούρτες, στέμματα';

  @override
  String variantsPerCategory(int count) {
    return 'Παραλλαγές ανά κατηγορία: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Δημιουργία $count αντικειμένων',
      one: 'Δημιουργία $count αντικειμένου',
    );
    return '$_temp0 (~$minutes λεπτά)';
  }

  @override
  String composerSent(int sent) {
    return 'Εργασίες που στάλθηκαν: $sent – το Spark δημιουργεί (~4 λεπτά το καθένα, διαδοχικά)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Στάλθηκαν: $sent, σφάλματα: $errors';
  }

  @override
  String get queueEmpty =>
      'Δεν υπάρχει ακόμη τίποτα στο NAS – στείλτε μια παρτίδα από το Composer.';

  @override
  String get stNew => 'Αναμονή για triage';

  @override
  String get stRemeshing => 'Επαναϋπολογίζεται στο TRELLIS (~4 λεπτά)';

  @override
  String get stApproved => 'Στην ουρά μετατροπής';

  @override
  String get stConverting => 'Μετατροπή σε εξέλιξη';

  @override
  String get stConverted => 'Μετατράπηκε – αναμονή για 3D έλεγχο';

  @override
  String get stPacked => 'Συσκευάστηκε για το Studio';

  @override
  String get stFailed => 'Απέτυχε';

  @override
  String get stRejected => 'Απορρίφθηκε';

  @override
  String get stRerolled => 'Ξαναδημιουργήθηκε';

  @override
  String get tapFor3d => 'πατήστε για 3D';

  @override
  String get pack => 'Συσκευασία';

  @override
  String sparkSection(int count) {
    return 'Δημιουργούνται στο Spark ($count)';
  }

  @override
  String get sgQueued => 'περιμένει στην ουρά';

  @override
  String get sgConcept => 'σχεδιάζει το concept';

  @override
  String get sgCleanplate => 'αφαιρεί το φόντο';

  @override
  String get sgMesh => 'μοντελοποιεί σε 3D (~4 λεπτά)';

  @override
  String get sgPush => 'στέλνει στο NAS';

  @override
  String get sgDone => 'έτοιμο';

  @override
  String get sgFailed => 'απέτυχε';

  @override
  String get reviewTris => 'τρίγωνα';

  @override
  String get reviewTexture => 'υφή';

  @override
  String get reviewSymmetry => 'συμμετρία';

  @override
  String get yes => 'ναι';

  @override
  String get no => 'όχι';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (κορυφές ραφής: $count)';
  }

  @override
  String get reconvertAgain => 'Νέα μετατροπή';

  @override
  String get reconvertSymmetry => 'Ξανά με συμμετρία';

  @override
  String get radialMenu => 'Διακόσμηση περιμετρικά (ακτινική)';

  @override
  String get noSymmetry => 'Χωρίς συμμετρία';

  @override
  String get backToConcept => 'Πίσω στο concept';

  @override
  String get show3d => 'Εμφάνιση του 3D μοντέλου';

  @override
  String get rejectedToast => 'Απορρίφθηκε';

  @override
  String get rerollToast => 'Το reroll στάλθηκε στο Spark';

  @override
  String get approvedToast => 'Εγκρίθηκε → μετατροπή';

  @override
  String errorPrefix(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String get allSorted =>
      'Όλα ταξινομήθηκαν. Να σταλεί νέα παρτίδα από το Composer;';

  @override
  String get newShort => 'Νέος';

  @override
  String get charactersEmpty =>
      'Δεν υπάρχει ακόμη κανένας χαρακτήρας.\nΞεκινήστε με μια φωτογραφία ή εικόνα ανθρωποειδούς χαρακτήρα.';

  @override
  String get newCharacter => 'Νέος χαρακτήρας';

  @override
  String get creating => 'Δημιουργία…';

  @override
  String get generate => 'Δημιουργία';

  @override
  String get nameLabel => 'Όνομα';

  @override
  String get prepPhoto => 'Προετοιμασία φωτογραφίας';

  @override
  String get prepPhotoHelp =>
      'Αφαιρεί το φόντο· αν τα χέρια είναι κολλημένα στο σώμα, τα απομακρύνει σε A-pose, και αν λείπουν τα πόδια κάτω από τους αστραγάλους, τα συμπληρώνει. Χωρίς αυτό το rig αποτυγχάνει συχνά σε ενωμένα άκρα.';

  @override
  String get animationsLabel => 'Κινούμενα σχέδια';

  @override
  String libraryLoadFailed(String error) {
    return 'Η βιβλιοθήκη δεν φορτώθηκε: $error';
  }

  @override
  String get libraryEmpty =>
      'Η βιβλιοθήκη είναι άδεια. Τα κλιπ καταχωρούνται με το script seed_animlib.py στο NAS.';

  @override
  String get gallery => 'Συλλογή';

  @override
  String get camera => 'Κάμερα';

  @override
  String get characterFallback => 'Χαρακτήρας';

  @override
  String get downloadGlb => 'Λήψη GLB';

  @override
  String get downloadFbx => 'Λήψη FBX';

  @override
  String get downloadZip => 'Λήψη όλων (ZIP)';

  @override
  String get sendRoblox => 'Αποστολή στο Roblox';

  @override
  String get sendLuanti => 'Αποστολή στο Luanti';

  @override
  String exportQueued(String target) {
    return 'Η εξαγωγή προς $target μπήκε στην ουρά';
  }

  @override
  String get clipsTitle => 'Κλιπ';

  @override
  String get exportsTitle => 'Εξαγωγές';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (προσπάθεια $attempt)';
  }

  @override
  String get retryStep => 'Επανάληψη του βήματος';

  @override
  String stepOf(int step, int total) {
    return 'βήμα $step από $total';
  }

  @override
  String get cfAccessHelp =>
      'Χρειάζεται μόνο για το ugc.ol1n.com (πρόσβαση χωρίς Tailscale).';

  @override
  String get saveAndTest => 'Αποθήκευση και δοκιμή';

  @override
  String connOk(int count) {
    return 'Η σύνδεση λειτουργεί (εργασίες που φορτώθηκαν: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Μη διαθέσιμο: $error';
  }
}
