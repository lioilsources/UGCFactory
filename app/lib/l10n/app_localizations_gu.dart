// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get navQueue => 'કતાર';

  @override
  String get navCharacters => 'પાત્રો';

  @override
  String get navSettings => 'સેટિંગ્સ';

  @override
  String get retry => 'ફરી પ્રયત્ન કરો';

  @override
  String nasUnavailable(String error) {
    return 'NAS ઉપલબ્ધ નથી: $error';
  }

  @override
  String get promptLabel => 'આઇટમનો પ્રૉમ્પ્ટ';

  @override
  String get categoriesLabel => 'શ્રેણીઓ';

  @override
  String get catHelmet => 'હેલ્મેટ';

  @override
  String get catBack => 'પાંખો / પીઠ';

  @override
  String get catSword => 'તલવાર';

  @override
  String get catFront => 'છાતીનું બખ્તર';

  @override
  String get catHat => 'ટોપી';

  @override
  String get catHair => 'વાળ (જોખમી)';

  @override
  String get styleLabel => 'શૈલી';

  @override
  String get collectionLabel => 'સંગ્રહ';

  @override
  String get radialTitle => 'ચારેબાજુ સજાવટ';

  @override
  String get radialSubtitle => 'રેડિયલ સમમિતિ – કેક, મુગટ';

  @override
  String variantsPerCategory(int count) {
    return 'દરેક શ્રેણી દીઠ વેરિઅન્ટ: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઇટમ બનાવો',
      one: '$count આઇટમ બનાવો',
    );
    return '$_temp0 (~$minutes મિનિટ)';
  }

  @override
  String composerSent(int sent) {
    return 'મોકલેલા કાર્યો: $sent – Spark બનાવી રહ્યું છે (~દરેક 4 મિનિટ, એક પછી એક)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'મોકલ્યા: $sent, ભૂલો: $errors';
  }

  @override
  String get queueEmpty => 'NAS પર હજી કશું નથી – Composer માંથી બૅચ મોકલો.';

  @override
  String get stNew => 'ટ્રાયાજની રાહમાં';

  @override
  String get stRemeshing => 'TRELLIS માં ફરી ગણાય છે (~4 મિનિટ)';

  @override
  String get stApproved => 'રૂપાંતરની કતારમાં';

  @override
  String get stConverting => 'રૂપાંતર થઈ રહ્યું છે';

  @override
  String get stConverted => 'રૂપાંતરિત – 3D સમીક્ષાની રાહમાં';

  @override
  String get stPacked => 'Studio માટે પૅક કર્યું';

  @override
  String get stFailed => 'નિષ્ફળ';

  @override
  String get stRejected => 'નકારાયું';

  @override
  String get stRerolled => 'ફરી બનાવાયું';

  @override
  String get tapFor3d => '3D માટે ટૅપ કરો';

  @override
  String get pack => 'પૅક કરો';

  @override
  String sparkSection(int count) {
    return 'Spark પર બની રહ્યા છે ($count)';
  }

  @override
  String get sgQueued => 'કતારમાં રાહ જુએ છે';

  @override
  String get sgConcept => 'કન્સેપ્ટ દોરે છે';

  @override
  String get sgCleanplate => 'બૅકગ્રાઉન્ડ કાઢે છે';

  @override
  String get sgMesh => '3D માં મૉડેલ બનાવે છે (~4 મિનિટ)';

  @override
  String get sgPush => 'NAS ને મોકલે છે';

  @override
  String get sgDone => 'પૂર્ણ';

  @override
  String get sgFailed => 'નિષ્ફળ';

  @override
  String get reviewTris => 'ત્રિકોણ';

  @override
  String get reviewTexture => 'ટેક્સચર';

  @override
  String get reviewSymmetry => 'સમમિતિ';

  @override
  String get yes => 'હા';

  @override
  String get no => 'ના';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (સીમના શિરોબિંદુ: $count)';
  }

  @override
  String get reconvertAgain => 'ફરી રૂપાંતર કરો';

  @override
  String get reconvertSymmetry => 'સમમિતિ સાથે ફરી';

  @override
  String get radialMenu => 'ચારેબાજુ સજાવટ (રેડિયલ)';

  @override
  String get noSymmetry => 'સમમિતિ વગર';

  @override
  String get backToConcept => 'કન્સેપ્ટ પર પાછા';

  @override
  String get show3d => '3D મૉડેલ બતાવો';

  @override
  String get rejectedToast => 'નકારાયું';

  @override
  String get rerollToast => 'રીરોલ Spark ને મોકલાયું';

  @override
  String get approvedToast => 'મંજૂર → રૂપાંતર';

  @override
  String errorPrefix(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String get allSorted =>
      'બધું વર્ગીકૃત થયું. Composer માંથી નવી બૅચ મોકલવી છે?';

  @override
  String get newShort => 'નવું';

  @override
  String get charactersEmpty =>
      'હજી કોઈ પાત્ર નથી.\nમાનવ-આકારના પાત્રના ફોટા અથવા ચિત્રથી શરૂ કરો.';

  @override
  String get newCharacter => 'નવું પાત્ર';

  @override
  String get creating => 'બનાવી રહ્યા છીએ…';

  @override
  String get generate => 'બનાવો';

  @override
  String get nameLabel => 'નામ';

  @override
  String get prepPhoto => 'ફોટો તૈયાર કરો';

  @override
  String get prepPhotoHelp =>
      'બૅકગ્રાઉન્ડ કાઢે છે; હાથ શરીર સાથે ચોંટેલા હોય તો તેમને A-પોઝમાં ખેંચી લાવે છે, અને ઘૂંટણ નીચે પગ ન હોય તો પૂરા કરે છે. આ વગર જોડાયેલા અંગો પર રિગ ઘણીવાર નિષ્ફળ જાય છે.';

  @override
  String get animationsLabel => 'ઍનિમેશન';

  @override
  String libraryLoadFailed(String error) {
    return 'લાઇબ્રેરી લોડ થઈ શકી નહીં: $error';
  }

  @override
  String get libraryEmpty =>
      'લાઇબ્રેરી ખાલી છે. ક્લિપ NAS પર seed_animlib.py સ્ક્રિપ્ટથી નોંધાય છે.';

  @override
  String get gallery => 'ગૅલેરી';

  @override
  String get camera => 'કૅમેરા';

  @override
  String get characterFallback => 'પાત્ર';

  @override
  String get downloadGlb => 'GLB ડાઉનલોડ કરો';

  @override
  String get downloadFbx => 'FBX ડાઉનલોડ કરો';

  @override
  String get downloadZip => 'બધું ડાઉનલોડ કરો (ZIP)';

  @override
  String get sendRoblox => 'Roblox ને મોકલો';

  @override
  String get sendLuanti => 'Luanti ને મોકલો';

  @override
  String exportQueued(String target) {
    return '$target માં નિકાસ કતારમાં મૂકી';
  }

  @override
  String get clipsTitle => 'ક્લિપ';

  @override
  String get exportsTitle => 'નિકાસ';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (પ્રયત્ન $attempt)';
  }

  @override
  String get retryStep => 'પગલું ફરી અજમાવો';

  @override
  String stepOf(int step, int total) {
    return 'પગલું $step / $total';
  }

  @override
  String get cfAccessHelp =>
      'ફક્ત ugc.ol1n.com માટે જરૂરી (Tailscale વગર ઍક્સેસ).';

  @override
  String get saveAndTest => 'સાચવો અને ચકાસો';

  @override
  String connOk(int count) {
    return 'જોડાણ બરાબર (લોડ થયેલા કાર્યો: $count)';
  }

  @override
  String connFailed(String error) {
    return 'ઉપલબ્ધ નથી: $error';
  }
}
